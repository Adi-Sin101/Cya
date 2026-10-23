import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../domain/entities/focus_timer.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/routine_providers.dart';
import '../memories/memory_composer.dart';
import '../capture/capture_hub.dart';

class FocusRoomScreen extends ConsumerStatefulWidget {
  const FocusRoomScreen({super.key, required this.priority, this.occurrence});
  final String priority;
  final RoutineOccurrence? occurrence;
  @override
  ConsumerState<FocusRoomScreen> createState() => _FocusRoomState();
}

class _FocusRoomState extends ConsumerState<FocusRoomScreen>
    with WidgetsBindingObserver {
  FocusTimerSnapshot? _timer;
  RoutineOccurrence? _focusedOccurrence;
  late final _priority = TextEditingController(text: widget.priority);
  Timer? _tick;
  int _minutes = 25;
  bool _loading = true, _busy = false;
  String? _error;
  DateTime get _now => ref.read(clockProvider)();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startTick();
  }

  void _startTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _timer?.running == true) {
        setState(() {});
        if (_timer!.remainingAt(_now) == 0) _tick?.cancel();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
      _startTick();
    } else {
      _tick?.cancel();
    }
  }

  @override
  void dispose() {
    _priority.dispose();
    _tick?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final timer = await ref.read(focusTimerRepositoryProvider).load();
      final linked = timer?.occurrenceId == null
          ? null
          : await ref
                .read(routineRepositoryProvider)
                .occurrenceById(timer!.occurrenceId!);
      if (mounted) {
        setState(() {
          _timer = timer;
          _focusedOccurrence = linked?.open == true ? linked : null;
          _loading = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not read your focus. Reopen to retry.';
        });
      }
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'Your focus may have changed. Reopen before retrying.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start() => _run(() async {
    final old = await ref.read(focusTimerRepositoryProvider).load();
    if (old != null) {
      if (!mounted) return;
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start a new focus?'),
          content: Text(
            'Your current focus is “${old.priority}”. Its history will be kept.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep current'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Start new focus'),
            ),
          ],
        ),
      );
      if (replace != true) return;
    }
    final timer = await ref
        .read(focusTimerRepositoryProvider)
        .start(
          _priority.text,
          _minutes,
          _now,
          occurrenceId: widget.occurrence?.id,
        );
    if (mounted) {
      setState(() {
        _timer = timer;
        _focusedOccurrence = widget.occurrence;
      });
      _startTick();
    }
  });
  Future<void> _toggle() => _run(() async {
    final timer = await ref
        .read(focusTimerRepositoryProvider)
        .toggle(_timer!.sessionId, _now);
    if (mounted) setState(() => _timer = timer);
  });
  Future<void> _end({bool complete = false}) => _run(() async {
    final timer = _timer!;
    final occurrence = _focusedOccurrence;
    final db = ref.read(databaseProvider);
    await db.transaction(() async {
      if (complete &&
          occurrence != null &&
          timer.occurrenceId == occurrence.id) {
        await ref
            .read(routineRepositoryProvider)
            .change(
              occurrence.id,
              _now,
              expectedVersion: occurrence.version,
              state: 'completed',
            );
      }
      await ref.read(focusTimerRepositoryProvider).stop(timer.sessionId, _now);
    });
    if (mounted) {
      setState(() => _timer = null);
      Navigator.pop(context);
    }
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), timer = _timer;
    final occurrence = timer == null ? widget.occurrence : _focusedOccurrence;
    final remaining = timer?.remainingAt(_now) ?? _minutes * 60;
    final duration = timer?.durationSeconds ?? _minutes * 60;
    final label =
        '${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
        actions: [
          IconButton(
            tooltip: 'Save a thought',
            icon: const Icon(Icons.note_add_outlined),
            onPressed: _busy
                ? null
                : () async {
                    if (await showMemoryComposer(context, ref) &&
                        context.mounted) {
                      await showSavedMemoryNotice(context, ref);
                    }
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 36),
                child: Column(
                  children: [
                    Text(
                      timer == null
                          ? 'Make a little space.'
                          : remaining == 0
                          ? 'A moment to choose.'
                          : timer.running
                          ? 'Just this, for now.'
                          : 'Room to breathe.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    if (timer == null && widget.priority.isEmpty)
                      TextField(
                        controller: _priority,
                        maxLength: 500,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'What matters right now?',
                          hintText: 'One thing to return to',
                        ),
                      )
                    else
                      Text(
                        timer?.priority ?? widget.priority,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    const SizedBox(height: 28),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            RepaintBoundary(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0,
                                  end: 1 - remaining / duration,
                                ),
                                duration: AppMotion.of(
                                  context,
                                  AppMotion.gentle,
                                ),
                                curve: AppMotion.standard,
                                builder: (context, value, _) => CustomPaint(
                                  size: const Size.square(320),
                                  painter: _FocusOrbit(
                                    value,
                                    theme.colorScheme.primary,
                                    theme.brightness == Brightness.dark,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  timer?.running == true
                                      ? Icons.spa_outlined
                                      : Icons.wb_twilight_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 30,
                                ),
                                const SizedBox(height: 12),
                                Semantics(
                                  label:
                                      '${remaining ~/ 60} minutes ${remaining % 60} seconds remaining',
                                  child: ExcludeSemantics(
                                    child: Text(
                                      label,
                                      style: theme.textTheme.displayLarge
                                          ?.copyWith(
                                            fontSize: 54,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -2,
                                          ),
                                    ),
                                  ),
                                ),
                                Text(
                                  timer == null
                                      ? 'your time'
                                      : remaining == 0
                                      ? 'time is up'
                                      : timer.running
                                      ? 'one thing at a time'
                                      : 'paused',
                                  style: theme.textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (timer == null) ...[
                      Wrap(
                        spacing: 10,
                        children: [
                          for (final minutes in [15, 25, 45])
                            ChoiceChip(
                              label: Text('$minutes min'),
                              selected: _minutes == minutes,
                              onSelected: _busy
                                  ? null
                                  : (_) => setState(() => _minutes = minutes),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _busy || _priority.text.trim().isEmpty
                            ? null
                            : _start,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Begin focus'),
                      ),
                    ] else ...[
                      if (remaining > 0)
                        FilledButton.icon(
                          onPressed: _busy ? null : _toggle,
                          icon: Icon(
                            timer.running
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(timer.running ? 'Pause' : 'Resume'),
                        ),
                      const SizedBox(height: 10),
                      if (occurrence != null &&
                          timer.occurrenceId == occurrence.id)
                        OutlinedButton.icon(
                          onPressed: _busy ? null : () => _end(complete: true),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Complete routine & finish'),
                        ),
                      TextButton(
                        onPressed: _busy ? null : () => _end(),
                        child: const Text('End focus'),
                      ),
                    ],
                    if (timer != null &&
                        widget.priority.isNotEmpty &&
                        timer.priority != widget.priority)
                      TextButton(
                        onPressed: _busy ? null : _start,
                        child: const Text('Focus on this routine instead'),
                      ),
                    if (occurrence?.steps.isNotEmpty == true &&
                        (timer == null || timer.occurrenceId == occurrence?.id))
                      Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your steps',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 10),
                            for (var i = 0; i < occurrence!.steps.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${i + 1}.',
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(occurrence.steps[i])),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => openMemoryCapture(
                              context,
                              ref,
                              CaptureKind.voice,
                            ),
                      icon: const Icon(Icons.mic_rounded),
                      label: const Text('Record a voice thought'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'A timer holds space. Only you mark a routine done.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (_busy)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    if (_error != null) Text(_error!),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FocusOrbit extends CustomPainter {
  _FocusOrbit(this.progress, this.ink, this.dark);
  final double progress;
  final Color ink;
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero), radius = size.shortestSide * .43;
    canvas.drawCircle(
      center,
      radius - 14,
      Paint()..color = ink.withValues(alpha: dark ? 0.09 : 0.045),
    );
    canvas.drawCircle(
      center,
      radius + 8,
      Paint()
        ..color = ink.withValues(alpha: .04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = ink.withValues(alpha: .13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < 48; i++) {
      final angle = i / 48 * 2 * math.pi - math.pi / 2;
      final a =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius + 19);
      final b =
          center +
          Offset(math.cos(angle), math.sin(angle)) *
              (radius + (i % 4 == 0 ? 25 : 22));
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = ink.withValues(alpha: i % 4 == 0 ? 0.5 : 0.18)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
    final end =
        center +
        Offset(
              math.cos(progress * 2 * math.pi - math.pi / 2),
              math.sin(progress * 2 * math.pi - math.pi / 2),
            ) *
            radius;
    canvas.drawCircle(end, 6, Paint()..color = AppColors.softSage);
  }

  @override
  bool shouldRepaint(_FocusOrbit old) =>
      old.progress != progress || old.ink != ink || old.dark != dark;
}
