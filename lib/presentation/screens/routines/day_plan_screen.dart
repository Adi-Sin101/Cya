import 'dart:convert';
import '../../widgets/motion/entrance.dart';
import 'rhythm_visuals.dart';
import 'focus_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/memory_providers.dart';
import '../../providers/routine_providers.dart';
import '../../providers/today_provider.dart';
import 'routine_editor.dart';
import 'routines_screen.dart';
import 'review_screen.dart';

class DayPlanScreen extends ConsumerStatefulWidget {
  const DayPlanScreen({super.key});
  @override
  ConsumerState<DayPlanScreen> createState() => _DayPlanState();
}

class _DayPlanState extends ConsumerState<DayPlanScreen> {
  DateTime? _chosenDay;
  Future<void> _run(Future<void> Function() operation) async {
    try {
      await operation();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not change this plan. Reopen it if it changed elsewhere. Your history is preserved.',
            ),
          ),
        );
      }
    }
  }

  Future<DateTime?> _day(DateTime initial) => showDatePicker(
    context: context,
    initialDate: initial.year < 1900 || initial.year > 2100
        ? ref.read(clockProvider)()
        : initial,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100, 12, 31),
  );
  Future<void> _select(Routine routine, DateTime day) => _run(() async {
    await ref
        .read(routineRepositoryProvider)
        .select(routine.id, day, ref.read(clockProvider)());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selected for ${localDayKey(day)}. Your other plans stay as chosen.',
          ),
        ),
      );
    }
  });
  Future<void> _adjust(RoutineOccurrence occurrence) async {
    final steps = TextEditingController(text: occurrence.steps.join('\n'));
    var start = occurrence.start, end = occurrence.end, busy = false;
    String? error;
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialog) {
          Future<void> time(bool first) async {
            final current = first ? start : end;
            final value = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: current == null ? 9 : current ~/ 60,
                minute: current == null ? 0 : current % 60,
              ),
            );
            if (value != null && dialogContext.mounted) {
              setDialog(() {
                if (first) {
                  start = value.hour * 60 + value.minute;
                } else {
                  end = value.hour * 60 + value.minute;
                }
              });
            }
          }

          return PopScope(
            canPop: !busy,
            child: AlertDialog(
              title: const Text('Make this occurrence fit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Only this selected occurrence changes. Its original routine version and earlier plan stay in history.',
                    ),
                    TextField(
                      controller: steps,
                      minLines: 3,
                      maxLines: 7,
                      maxLength: 25000,
                      decoration: const InputDecoration(
                        labelText: 'Your adjusted steps, one per line',
                      ),
                    ),
                    if (occurrence.fallback != null)
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => steps.text = occurrence.fallback!,
                        child: const Text('Use my lighter fallback'),
                      ),
                    Text(preferredWindow(start, end)),
                    Wrap(
                      children: [
                        TextButton(
                          onPressed: busy ? null : () => time(true),
                          child: const Text('Start'),
                        ),
                        TextButton(
                          onPressed: busy ? null : () => time(false),
                          child: const Text('End'),
                        ),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => setDialog(() {
                                  start = null;
                                  end = null;
                                }),
                          child: const Text('Flexible'),
                        ),
                      ],
                    ),
                    if (error != null) Text(error!),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          setDialog(() {
                            busy = true;
                            error = null;
                          });
                          try {
                            await ref
                                .read(routineRepositoryProvider)
                                .change(
                                  occurrence.id,
                                  ref.read(clockProvider)(),
                                  expectedVersion: occurrence.version,
                                  steps: stepsFromInput(steps.text),
                                  window: (start: start, end: end),
                                );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } on Object {
                            if (dialogContext.mounted) {
                              setDialog(() {
                                busy = false;
                                error =
                                    'Check your steps and window. Reopen if this occurrence changed.';
                              });
                            }
                          }
                        },
                  child: const Text('Save this plan'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await Navigator.of(context).push(route);
    await route.completed;
    steps.dispose();
  }

  Future<void> _action(
    RoutineOccurrence item,
    String action,
    DateTime viewDay,
  ) async {
    final repo = ref.read(routineRepositoryProvider),
        at = ref.read(clockProvider)();
    if (action == 'adjust') {
      await _adjust(item);
      return;
    }
    if (action == 'history') {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .7,
            child: Consumer(
              builder: (context, ref, _) => ref
                  .watch(routineOccurrenceEventsProvider(item.id))
                  .when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Center(
                      child: Text('Could not read occurrence history.'),
                    ),
                    data: (events) => ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Originally selected for ${item.selectedDay}. Version and original plan are preserved.',
                        ),
                        for (final event in events)
                          Builder(
                            builder: (context) {
                              final after =
                                  (jsonDecode(event.metadata) as Map)['after']
                                      as Map;
                              return ListTile(
                                title: Text(event.type.replaceAll('_', ' ')),
                                subtitle: Text(
                                  '${event.occurredAt.toLocal()} · ${after['state']}\nPlanned for ${after['targetDay']} · ${routineSteps(after['steps'] as String).length} steps',
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      );
      return;
    }
    if (action == 'focus') {
      _openFocus(item.title, occurrence: item);
      return;
    }
    if (action == 'defer' || action == 'pause') {
      final target = await _day(
        DateTime(viewDay.year, viewDay.month, viewDay.day + 1),
      );
      if (target == null) return;
      await _run(
        () => action == 'pause'
            ? repo.pauseAfterDisruption(
                item.id,
                target,
                at,
                expectedVersion: item.version,
              )
            : repo.change(
                item.id,
                at,
                expectedVersion: item.version,
                state: 'deferred',
                day: target,
              ),
      );
      return;
    }
    if (action == 'today') {
      await _run(
        () => repo.change(
          item.id,
          at,
          expectedVersion: item.version,
          state: 'planned',
          day: viewDay,
        ),
      );
      return;
    }
    if (action == 'up' || action == 'down') {
      await _run(
        () => repo.moveOccurrence(
          item.id,
          action == 'up' ? -1 : 1,
          at,
          expectedVersion: item.version,
        ),
      );
      return;
    }
    await _run(
      () => repo.change(
        item.id,
        at,
        expectedVersion: item.version,
        state: action,
      ),
    );
  }

  Widget _occurrence(RoutineOccurrence item, DateTime day, int index) =>
      RoutineVisualCard(
        key: ValueKey(item.id),
        item: item,
        index: index,
        onAction: (action) => _action(item, action, day),
      );

  void _openFocus(String priority, {RoutineOccurrence? occurrence}) =>
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              FocusRoomScreen(priority: priority, occurrence: occurrence),
        ),
      );

  Widget _week(DateTime day) {
    final monday = DateTime(day.year, day.month, day.day - day.weekday + 1);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Builder(
              builder: (context) {
                final date = DateTime(
                      monday.year,
                      monday.month,
                      monday.day + i,
                    ),
                    key = localDayKey(date),
                    chosen = key == localDayKey(day);
                final records =
                    ref.watch(dayRoutinesProvider(key)).valueOrNull ?? [];
                final completed = records
                    .where((r) => r.state == 'completed')
                    .length;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Semantics(
                    selected: chosen,
                    label:
                        '${MaterialLocalizations.of(context).formatFullDate(date)}, ${records.length} selected, $completed completed',
                    child: Material(
                      color: chosen
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => setState(() => _chosenDay = date),
                        child: SizedBox(
                          width: 48,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                Text(
                                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: chosen
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${date.day}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: chosen
                                        ? theme.colorScheme.onPrimary
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: records.isEmpty
                                        ? Colors.transparent
                                        : chosen
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _chooseRoutine(
    DateTime day,
    List<Routine> rows,
    Set<String> selected,
  ) async {
    final all = rows.where((r) => !r.paused && !r.deleted).toList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .65,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Text(
                'Choose your rhythm',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Choose a little. Adjust as you go.'),
              const SizedBox(height: 20),
              if (all.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Icon(Icons.wb_twilight_rounded, size: 64),
                ),
              for (final routine in all)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      routine.eligible(day)
                          ? Icons.spa_outlined
                          : Icons.event_repeat_rounded,
                    ),
                  ),
                  title: Text(routine.title),
                  subtitle: Text(
                    routine.eligible(day)
                        ? preferredWindow(routine.start, routine.end)
                        : 'Outside usual weekdays',
                  ),
                  trailing: Icon(
                    selected.contains(routine.id)
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline,
                  ),
                  enabled: !selected.contains(routine.id),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _select(routine, day);
                  },
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await editRoutine(context, ref);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create a routine'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime day = _chosenDay ?? ref.watch(todayProvider);
    final key = localDayKey(day), theme = Theme.of(context);
    final selected = ref.watch(dayRoutinesProvider(key));
    final items = selected.valueOrNull ?? <RoutineOccurrence>[];
    final rows = ref.watch(routinesProvider(false)).valueOrNull ?? <Routine>[];
    final storedPriority = ref.watch(focusPriorityProvider).valueOrNull;
    final priority = storedPriority?.isNotEmpty == true ? storedPriority : null;
    final timer = ref.watch(focusTimerSnapshotProvider).valueOrNull;
    final open = items.where((i) => i.open).toList();
    final next = open.isEmpty ? null : open.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your rhythm'),
        actions: [
          IconButton(
            tooltip: 'Choose day',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () async {
              final chosen = await _day(day);
              if (chosen != null && mounted) {
                setState(() => _chosenDay = chosen);
              }
            },
          ),
          IconButton(
            tooltip: 'Manage routines',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(builder: (_) => const RoutinesScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  MaterialLocalizations.of(context).formatMediumDate(day),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (_chosenDay != null)
                TextButton(
                  onPressed: () => setState(() => _chosenDay = null),
                  child: const Text('Today'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _week(day),
          const SizedBox(height: 24),
          Entrance(child: RhythmDayPath(items: items)),
          const SizedBox(height: 20),
          if (timer == null && priority == null && next == null)
            OutlinedButton.icon(
              onPressed: () => _openFocus(''),
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: const Text('Focus on one thing'),
            ),
          if (timer != null || (priority?.isNotEmpty ?? false) || next != null)
            Entrance(
              delay: const Duration(milliseconds: 70),
              child: Material(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _openFocus(
                    timer?.priority ?? priority ?? next!.title,
                    occurrence: timer == null && priority == null ? next : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timer == null
                                    ? 'A LITTLE FOCUS'
                                    : 'YOUR FOCUS IS HERE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary.withValues(
                                    alpha: .8,
                                  ),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                timer?.priority ?? priority ?? next!.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                timer == null
                                    ? 'Enter focus mode'
                                    : 'Return to focus',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 48,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Text('In your day', style: theme.textTheme.titleLarge),
              ),
              IconButton.filledTonal(
                tooltip: 'Add routines to this day',
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _chooseRoutine(
                  day,
                  rows,
                  items.map((i) => i.routineId).toSet(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (selected.isLoading) const LinearProgressIndicator(),
          if (selected.hasError)
            const Text('Could not read your day. Reopen to retry.'),
          if (items.isEmpty && !selected.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const Icon(Icons.wb_twilight_rounded, size: 38),
                  const SizedBox(height: 12),
                  const Text('Keep the day yours.'),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => _chooseRoutine(day, rows, {}),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Choose a routine'),
                  ),
                ],
              ),
            ),
          for (var i = 0; i < items.length; i++)
            Entrance(
              key: ValueKey(items[i].id),
              child: _occurrence(items[i], day, i + 1),
            ),
          ref
              .watch(earlierRoutinesProvider(key))
              .when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) =>
                    const Text('Earlier selections could not be read.'),
                data: (earlier) => earlier.isEmpty
                    ? const SizedBox.shrink()
                    : ExpansionTile(
                        title: Text('Room to reset · ${earlier.length}'),
                        subtitle: const Text('Move, lighten or let go.'),
                        children: [
                          for (var i = 0; i < earlier.length; i++)
                            _occurrence(earlier[i], day, i + 1),
                        ],
                      ),
              ),
          const SizedBox(height: 18),
          Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              leading: Icon(
                Icons.auto_stories_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Look back, gently'),
              subtitle: const Text('Your day or week, in perspective.'),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(builder: (_) => ReviewScreen(day: day)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
