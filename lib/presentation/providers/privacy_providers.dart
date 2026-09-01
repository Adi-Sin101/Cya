import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/result.dart';
import '../../core/utils/clock.dart';
import '../../data/dao/preference_dao.dart';
import '../../domain/repositories/intention_repository.dart';
import '../../domain/services/data_export.dart';
import '../../native/reminder_port.dart';
import '../../native/system_share_port.dart';

/// The two controls PRD §9.3 requires: take everything with you, and leave
/// nothing behind.
///
/// Both are the same promise from opposite ends — the data is the user's, not
/// the app's. Neither touches a network, because there is none.
class PrivacyController {
  const PrivacyController(
    this._repository,
    this._preferences,
    this._reminders,
    this._share,
    this._clock,
  );

  final IntentionRepository _repository;
  final PreferenceDao _preferences;
  final ReminderPort _reminders;
  final SystemSharePort _share;
  final Clock _clock;

  /// Builds the export and offers it to the share sheet.
  ///
  /// Returns how many promises it contained, so the UI can say something true
  /// ("47 promises exported") rather than a generic success.
  Future<Result<int>> exportEverything() async {
    try {
      final now = _clock();
      final document = DataExport.build(
        exportedAt: now,
        intentions: await _repository.allForExport(),
        events: await _repository.allEventsForExport(),
        preferences: await _preferences.all(),
      );
      final shown = await _share.shareDocument(
        fileName: DataExport.fileNameFor(now),
        content: DataExport.encode(document),
      );
      if (!shown) {
        return const Result<int>.failure(
          ValidationError(
            "Couldn't open the share sheet. Nothing on this device seems able "
            'to receive a file.',
          ),
        );
      }
      return Result<int>.success(
        (document['counts']! as Map<String, Object?>)['intentions']! as int,
      );
    } on Object catch (error, stackTrace) {
      return Result<int>.failure(StorageError(error, stackTrace));
    }
  }

  /// Erases every promise, every event and every setting (PRD §9.3).
  ///
  /// Alarms are cancelled **before** the rows go, because an alarm is
  /// identified by an intention id and there is no way to find it again once
  /// the row is gone — the OS would keep firing at a database that no longer
  /// remembers why ([L-006] with the evidence deleted).
  Future<Result<int>> eraseEverything() async {
    try {
      final all = await _repository.allForExport();
      for (final intention in all) {
        if (intention.status.isPending) {
          await _reminders.cancel(intention.id);
        }
      }
      await _repository.eraseEverything();
      await _preferences.clearAll();
      return Result<int>.success(all.length);
    } on Object catch (error, stackTrace) {
      return Result<int>.failure(StorageError(error, stackTrace));
    }
  }
}

final systemSharePortProvider = Provider<SystemSharePort>(
  (ref) => const SystemSharePort(),
);

final privacyControllerProvider = Provider<PrivacyController>(
  (ref) => PrivacyController(
    ref.watch(intentionRepositoryProvider),
    ref.watch(preferenceDaoProvider),
    ref.watch(reminderPortProvider),
    ref.watch(systemSharePortProvider),
    ref.watch(clockProvider),
  ),
);
