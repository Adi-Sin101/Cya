import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/routine_providers.dart';

String preferredWindow(int? start, int? end) {
  String clock(int v) =>
      '${(v ~/ 60).toString().padLeft(2, '0')}:${(v % 60).toString().padLeft(2, '0')}';
  return start == null
      ? 'Flexible time'
      : '${clock(start)}${end == null ? '' : '–${clock(end)}'}';
}

List<String> stepsFromInput(String text) =>
    text.split('\n').where((s) => s.trim().isNotEmpty).toList();

Future<bool?> editRoutine(
  BuildContext context,
  WidgetRef ref, [
  Routine? routine,
]) => Navigator.of(context, rootNavigator: true).push<bool>(
  MaterialPageRoute(builder: (_) => _RoutineEditor(routine: routine)),
);

class _RoutineEditor extends ConsumerStatefulWidget {
  const _RoutineEditor({this.routine});
  final Routine? routine;
  @override
  ConsumerState<_RoutineEditor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_RoutineEditor> {
  late final _title = TextEditingController(text: widget.routine?.title ?? '');
  late final _steps = TextEditingController(
    text: widget.routine?.steps.join('\n') ?? '',
  );
  late final _fallback = TextEditingController(
    text: widget.routine?.fallback ?? '',
  );
  late int _mask = widget.routine?.weekdays ?? 0;
  late int? _start = widget.routine?.start, _end = widget.routine?.end;
  bool _busy = false, _dirty = false;
  String? _error;
  @override
  void dispose() {
    _title.dispose();
    _steps.dispose();
    _fallback.dispose();
    super.dispose();
  }

  Future<void> _time(bool first) async {
    final minute = first ? _start : _end;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: minute == null ? 9 : minute ~/ 60,
        minute: minute == null ? 0 : minute % 60,
      ),
    );
    if (time != null && mounted) {
      setState(() {
        if (first) {
          _start = time.hour * 60 + time.minute;
        } else {
          _end = time.hour * 60 + time.minute;
        }
        _dirty = true;
      });
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(routineRepositoryProvider)
          .save(
            id: widget.routine?.id,
            expectedRevision: widget.routine?.revision ?? 0,
            title: _title.text,
            steps: stepsFromInput(_steps.text),
            weekdays: _mask == 0 ? null : _mask,
            start: _start,
            end: _end,
            fallback: _fallback.text.trim().isEmpty ? null : _fallback.text,
            at: ref.read(clockProvider)(),
          );
      if (mounted) {
        setState(() => _dirty = false);
        Navigator.pop(context, true);
      }
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Check the name, step lengths and same-day window. Reopen if this routine changed.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave() async {
    if (_busy) return;
    if (_dirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Leave this draft?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard draft'),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    if (mounted) {
      setState(() => _dirty = false);
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    InputDecoration field(String label, {String? hint}) => InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
    return PopScope(
      canPop: !_dirty && !_busy,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.routine == null ? 'A new rhythm' : 'Shape your routine',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Icon(
              Icons.spa_outlined,
              size: 44,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Small steps. Your way.',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _title,
              enabled: !_busy,
              maxLength: 160,
              onChanged: (_) => setState(() => _dirty = true),
              decoration: field(
                'Routine name',
                hint: 'A calm start, reading, winding down…',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _steps,
              enabled: !_busy,
              minLines: 3,
              maxLines: 8,
              maxLength: 25000,
              onChanged: (_) => setState(() => _dirty = true),
              decoration: field(
                'Steps, one per line',
                hint: 'Open the book\nRead a page\nKeep one thought',
              ),
            ),
            const SizedBox(height: 20),
            Text('Usual days', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (var i = 0; i < 7; i++)
                  FilterChip(
                    label: Text(
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
                    ),
                    selected: _mask & (1 << i) != 0,
                    onSelected: _busy
                        ? null
                        : (selected) => setState(() {
                            _mask = selected
                                ? _mask | (1 << i)
                                : _mask & ~(1 << i);
                            _dirty = true;
                          }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _mask == 0
                  ? 'Any day that works.'
                  : 'Availability only. You choose each day’s plan.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: const Icon(Icons.tune_rounded),
              title: const Text('A little flexibility'),
              subtitle: Text(preferredWindow(_start, _end)),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _busy ? null : () => _time(true),
                        icon: const Icon(Icons.schedule_rounded),
                        label: const Text('Start'),
                      ),
                      OutlinedButton(
                        onPressed: _busy ? null : () => _time(false),
                        child: const Text('End'),
                      ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                _start = null;
                                _end = null;
                                _dirty = true;
                              }),
                        child: const Text('Flexible'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preferred same-day window only; no automatic routine alarm.',
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _fallback,
                  enabled: !_busy,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 1000,
                  onChanged: (_) => setState(() => _dirty = true),
                  decoration: field(
                    'My lighter version',
                    hint: 'On a busy day, just one page.',
                  ),
                ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_error!),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save routine'),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(12),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
