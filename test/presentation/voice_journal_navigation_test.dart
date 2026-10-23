import 'package:cya/core/di/providers.dart';
import 'package:cya/core/theme/app_theme.dart';
import 'package:cya/data/dao/preference_dao.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/audio/audio_attachments.dart';
import 'package:cya/domain/audio/captured_audio.dart';
import 'package:cya/domain/audio/pcm_wave.dart';
import 'package:cya/domain/services/embedding_runtime.dart';
import 'package:cya/presentation/providers/memory_providers.dart';
import 'package:cya/presentation/app/cya_app.dart';
import 'package:cya/presentation/screens/memories/memories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Attachments implements AudioAttachments {
  @override
  Future<void> verify(CapturedAudio audio) async => audio.validate();
  @override
  Future<Uint8List> segment(CapturedAudio audio, int segment) async =>
      PcmWave.wrap(Uint8List(PcmWave.bytesPerSecond));
  @override
  Future<void> delete(String fileName) async {}
  @override
  Future<void> eraseAll() async {}
}

class _Runtime implements EmbeddingRuntime {
  _Runtime(this.db);
  final CyaDatabase db;
  int embedded = 0;
  @override
  Future<bool> installed() async => true;
  @override
  Future<bool> install() async => true;
  @override
  Future<void> unload() async {}
  @override
  Future<List<double>> text(String input) async {
    expect(
      await db.select(db.memoryEvents).get(),
      isNotEmpty,
      reason: 'Inference must happen after the durable source/event commit',
    );
    embedded++;
    return List.generate(256, (i) => i == 0 ? 1.0 : 0.0);
  }

  @override
  Future<List<double>> audio(Uint8List wav) async => text('raw audio');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CyaDatabase db;
  late List<MethodCall> calls;
  var deny = false;
  var interrupted = false;
  late _Runtime runtime;
  const id = '12345678-1234-4234-8234-123456789abc';
  final at = DateTime(2026, 10, 16, 12);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() async {
    db = CyaDatabase.memory();
    calls = [];
    deny = false;
    interrupted = false;
    runtime = _Runtime(db);
    await db.preferenceDao.write(PreferenceDao.keyOnboardingComplete, 'true');
    messenger.setMockMethodCallHandler(const MethodChannel('cya/audio'), (
      call,
    ) async {
      calls.add(call);
      if (call.method == 'pending') {
        return interrupted
            ? [
                {
                  'id': id,
                  'durationMillis': 1000,
                  'capturedAtMillis': at.millisecondsSinceEpoch,
                },
              ]
            : <Object>[];
      }
      if (call.method == 'start') {
        if (deny) throw PlatformException(code: 'permission_denied');
        return {'id': id};
      }
      if (call.method == 'stop' || call.method == 'recover') {
        return {
          'id': id,
          'fileName': '$id.wav',
          'sha256': 'a' * 64,
          'byteLength': PcmWave.bytesPerSecond + 44,
          'durationMillis': 1000,
          'capturedAtMillis': at.millisecondsSinceEpoch,
        };
      }
      if (call.method == 'play') return true;
      return null;
    });
    messenger.setMockMethodCallHandler(
      const MethodChannel('cya/reminders'),
      (call) async => switch (call.method) {
        'canScheduleExact' => true,
        'rescheduleAll' => 0,
        'biometricAvailability' => 'unavailable',
        _ => null,
      },
    );
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(const MethodChannel('cya/audio'), null);
    messenger.setMockMethodCallHandler(
      const MethodChannel('cya/reminders'),
      null,
    );
    await db.close();
  });
  Future<void> pump(
    WidgetTester tester, {
    bool standalone = false,
    bool dark = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          audioAttachmentsProvider.overrideWithValue(_Attachments()),
          embeddingRuntimeProvider.overrideWithValue(runtime),
          clockProvider.overrideWithValue(() => at),
          appStartupProvider.overrideWith((ref) async {}),
        ],
        child: standalone
            ? MaterialApp(
                theme: dark ? AppTheme.dark : AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.35),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
                home: const MemoriesScreen(),
              )
            : const CyaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  Future<void> reveal(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target.hitTestable(),
      160,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Home exposes voice; opening recorder never starts the mic', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Record voice'));
    await tester.pumpAndSettle();
    expect(find.text('Your voice journal'), findsOneWidget);
    expect(find.text('Start recording'), findsOneWidget);
    expect(calls.where((c) => c.method == 'start'), isEmpty);
    await dispose(tester);
  });

  testWidgets(
    'main Memories tab records, durably saves and plays original without a model',
    (tester) async {
      await pump(tester);
      await tester.tap(find.text('Memories'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record voice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start recording'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await reveal(tester, find.text('Stop and save'));
      await tester.tap(find.text('Stop and save'));
      await tester.pumpAndSettle();
      expect(await db.select(db.memories).get(), hasLength(1));
      expect((await db.select(db.memories).get()).single.kind, 'audio');
      expect(await db.select(db.memoryAttachments).get(), hasLength(1));
      expect(await db.select(db.memoryEvents).get(), hasLength(1));
      expect(await db.select(db.memoryJobs).get(), hasLength(1));
      expect(await db.select(db.intentions).get(), isEmpty);
      await reveal(tester, find.byTooltip('Play original audio'));
      await tester.tap(find.byTooltip('Play original audio'));
      await tester.pumpAndSettle();
      expect(calls.where((c) => c.method == 'play').single.arguments, {
        'id': id,
        'offsetMillis': 0,
      });
      await tester.tap(find.byTooltip('Stop audio playback'));
      await tester.pumpAndSettle();
      expect(calls.where((c) => c.method == 'stopPlayback'), isNotEmpty);
      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Memories'));
      await tester.pumpAndSettle();
      expect(find.text('Voice thought'), findsOneWidget);
      await dispose(tester);
    },
  );

  testWidgets(
    'corner capture chooser reaches voice and text with denial fallback',
    (tester) async {
      deny = true;
      await pump(tester);
      await tester.tap(find.bySemanticsLabel('Capture'));
      await tester.pumpAndSettle();
      expect(find.text('Capture a promise'), findsOneWidget);
      await tester.tap(find.text('Record voice').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start recording'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Check microphone permission'),
        findsOneWidget,
      );
      expect(await db.select(db.memories).get(), isEmpty);
      await reveal(tester, find.text('Microphone permission settings'));
      await tester.tap(find.text('Microphone permission settings'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Open Android Settings'), findsOneWidget);
      await reveal(tester, find.text('Close'));
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Capture'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Write a thought').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'My exact original thought',
      );
      await tester.tap(find.text('Save thought'));
      await tester.pumpAndSettle();
      expect(
        (await db.select(db.memoryRevisions).get()).single.body,
        'My exact original thought',
      );
      await dispose(tester);
    },
  );

  testWidgets(
    'Home save wakes local indexing after commit without visiting Memories',
    (tester) async {
      await db.preferenceDao.write('semantic_enabled', 'true');
      await pump(tester);
      expect(runtime.embedded, 0);
      await tester.tap(find.text('Write a thought'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'A thought captured from Home',
      );
      await tester.tap(find.text('Save thought'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 10 && runtime.embedded == 0; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(runtime.embedded, 1);
      expect((await db.select(db.memoryJobs).get()).single.state, 'complete');
      expect(await db.select(db.memoryVectors).get(), hasLength(1));
      await dispose(tester);
    },
  );

  testWidgets(
    'unfinished audio recovery is visible and never starts a new mic',
    (tester) async {
      interrupted = true;
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pump(tester, standalone: true, dark: true);
      await tester.tap(find.text('Record voice'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Recover'));
      await tester.tap(find.text('Recover'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Save voice thought'));
      await tester.tap(find.text('Save voice thought'));
      await tester.pumpAndSettle();
      expect(await db.select(db.memoryAttachments).get(), hasLength(1));
      expect(calls.where((c) => c.method == 'start'), isEmpty);
      expect(tester.takeException(), isNull);
      await dispose(tester);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'narrow ${dark ? 'dark' : 'light'} journal and recorder stay usable with large text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await pump(tester, standalone: true, dark: dark);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Record voice'));
        await tester.pumpAndSettle();
        await reveal(tester, find.text('Start recording'));
        expect(find.text('Start recording').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await dispose(tester);
      },
    );
  }
}
