import 'package:cya/core/result.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_intention_repository.dart';
import 'package:cya/domain/enums/intention_status.dart';
import 'package:cya/domain/enums/reminder_preset.dart';
import 'package:cya/domain/policies/snooze_policy.dart';
import 'package:cya/domain/repositories/intention_repository.dart';
import 'package:cya/domain/usecases/capture_intention.dart';
import 'package:cya/domain/usecases/manage_intention.dart';
import 'package:cya/domain/usecases/resolve_intention.dart';
import 'package:cya/domain/usecases/snooze_intention.dart';
import 'package:flutter_test/flutter_test.dart';

/// Use-case rules, exercised against a real store with a frozen clock.
void main() {
  late CyaDatabase db;
  late IntentionRepository repository;
  var now = DateTime(2026, 3, 4, 14);
  DateTime clock() => now;

  setUp(() {
    now = DateTime(2026, 3, 4, 14);
    db = CyaDatabase.memory();
    repository = DriftIntentionRepository(db.intentionDao);
  });
  tearDown(() => db.close());

  group('CaptureIntention', () {
    test('refuses empty content instead of storing a blank promise', () async {
      final result = await CaptureIntention(
        repository,
        clock,
      ).call(rawContent: '   ');
      expect(result.errorOrNull, isA<ValidationError>());
      expect(await repository.count(), 0);
    });

    test('applies the zero-tap default reminder when none is chosen', () async {
      final result = await CaptureIntention(
        repository,
        clock,
      ).call(rawContent: 'Read the AI paper');

      final id = result.valueOrNull;
      expect(id, isNotNull);
      final stored = (await repository.findById(id!))!;
      expect(stored.reminderAt, ReminderPreset.defaultPreset.resolve(now));
      expect(stored.sourceApp, CaptureIntention.inAppSource);
      expect(stored.status, IntentionStatus.open);
    });

    test('an explicit time wins over the preset', () async {
      final explicit = DateTime(2026, 3, 9, 7, 30);
      final result = await CaptureIntention(repository, clock).call(
        rawContent: 'Call the dentist',
        preset: ReminderPreset.tonight,
        reminderAt: explicit,
      );
      final stored = (await repository.findById(result.valueOrNull!))!;
      expect(stored.reminderAt, explicit);
    });

    test('trims what it stores but keeps the content otherwise raw', () async {
      final result = await CaptureIntention(
        repository,
        clock,
      ).call(rawContent: '  Reply to Sarah\nabout Saturday  ');
      final stored = (await repository.findById(result.valueOrNull!))!;
      expect(stored.rawContent, 'Reply to Sarah\nabout Saturday');
      expect(stored.title, 'Reply to Sarah');
    });
  });

  group('ResolveIntention', () {
    test('toggle closes an open promise and reopens a resolved one', () async {
      final id = (await CaptureIntention(
        repository,
        clock,
      ).call(rawContent: 'Review PR #128')).valueOrNull!;
      final resolve = ResolveIntention(repository, clock);

      await resolve.toggle(id);
      expect((await repository.findById(id))!.status, IntentionStatus.resolved);

      await resolve.toggle(id);
      expect((await repository.findById(id))!.status, IntentionStatus.open);
    });

    test('reports a missing promise instead of failing silently', () async {
      final result = await ResolveIntention(repository, clock).toggle(999);
      expect(result.errorOrNull, isA<NotFoundError>());
    });
  });

  group('SnoozeIntention (PRD 5.6 snooze limit)', () {
    Future<int> capture() async => (await CaptureIntention(
      repository,
      clock,
    ).call(rawContent: 'Buy an HDMI cable')).valueOrNull!;

    test('the default snooze pushes the reminder out by the policy', () async {
      final id = await capture();
      final result = await SnoozeIntention(repository, clock).call(id);
      expect(result.valueOrNull, now.add(SnoozePolicy.defaultSnooze));
      expect((await repository.findById(id))!.status, IntentionStatus.snoozed);
    });

    test('refuses the snooze that would exceed the limit', () async {
      final id = await capture();
      final snooze = SnoozeIntention(repository, clock);

      for (var i = 0; i < SnoozePolicy.maxSnoozes; i++) {
        expect((await snooze.call(id)).isSuccess, isTrue);
      }
      final blocked = await snooze.call(id);

      expect(blocked.errorOrNull, isA<SnoozeLimitError>());
      // The refusal must not have moved the reminder or the counter.
      expect(
        (await repository.findById(id))!.snoozeCount,
        SnoozePolicy.maxSnoozes,
      );
    });

    test('a promise at the limit asks to be closed, and can be', () async {
      final id = await capture();
      final snooze = SnoozeIntention(repository, clock);
      for (var i = 0; i < SnoozePolicy.maxSnoozes; i++) {
        await snooze.call(id);
      }

      final stalled = (await repository.findById(id))!;
      expect(SnoozePolicy.canSnooze(stalled), isFalse);
      expect(SnoozePolicy.requiresResolutionPrompt(stalled), isTrue);
      expect(SnoozePolicy.tierFor(stalled), EscalationTier.digest);

      expect(
        (await ManageIntention(repository, clock).archive(id)).isSuccess,
        isTrue,
      );
      expect((await repository.findById(id))!.status, IntentionStatus.archived);
    });

    test('escalation rises with each push-back', () async {
      final id = await capture();
      final snooze = SnoozeIntention(repository, clock);

      expect(
        SnoozePolicy.tierFor((await repository.findById(id))!),
        EscalationTier.quiet,
      );
      await snooze.call(id);
      expect(
        SnoozePolicy.tierFor((await repository.findById(id))!),
        EscalationTier.banner,
      );
    });
  });

  group('ManageIntention', () {
    test('rescheduling reopens a snoozed promise at the new time', () async {
      final id = (await CaptureIntention(
        repository,
        clock,
      ).call(rawContent: 'Water the plants')).valueOrNull!;
      await SnoozeIntention(repository, clock).call(id);

      final newTime = DateTime(2026, 3, 6, 8);
      await ManageIntention(repository, clock).reschedule(id, newTime);

      final stored = (await repository.findById(id))!;
      expect(stored.reminderAt, newTime);
      expect(stored.status, IntentionStatus.open);
    });

    test('editing to empty content is refused', () async {
      final id = (await CaptureIntention(
        repository,
        clock,
      ).call(rawContent: 'Original')).valueOrNull!;
      final result = await ManageIntention(repository, clock).edit(id, '  ');
      expect(result.errorOrNull, isA<ValidationError>());
      expect((await repository.findById(id))!.rawContent, 'Original');
    });
  });
}
