import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/intention_providers.dart';
import '../../providers/routine_providers.dart';
import 'routines_screen.dart';
import 'rhythm_visuals.dart';
import 'rhythm_week_chart.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.day});
  final DateTime day;
  @override
  ConsumerState<ReviewScreen> createState() => _ReviewState();
}

class _ReviewState extends ConsumerState<ReviewScreen> {
  late DateTime _day;
  final _note = TextEditingController();
  String _period = 'daily';
  String? _loaded, _message;
  int _revision = 0;
  bool _dirty = false, _busy = false, _leaving = false;
  @override
  void initState() {
    super.initState();
    _day = widget.day;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<bool> _mayDiscard() async {
    if (!_dirty) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave this unsaved note?'),
            content: const Text(
              'Saved review history stays intact. This new draft has not been saved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep writing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave draft'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _change({String? period, DateTime? day}) async {
    if (_busy || !await _mayDiscard() || !mounted) return;
    setState(() {
      _period = period ?? _period;
      _day = day ?? _day;
      _dirty = false;
      _loaded = null;
      _message = null;
      _revision = 0;
      _note.clear();
    });
  }

  Future<void> _save(ReviewFilter filter) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final repo = ref.read(routineRepositoryProvider);
      await repo.saveReview(
        _day,
        _period,
        _note.text,
        ref.read(clockProvider)(),
        expectedRevision: _revision,
      );
      final saved = await repo.reviewNote(_day, _period);
      if (mounted) {
        setState(() {
          _dirty = false;
          _revision = saved!.revision;
          _message = 'Saved. Your plan stays yours.';
        });
      }
      ref.invalidate(reviewNoteProvider(filter));
    } on Object {
      if (mounted) {
        setState(
          () => _message =
              'Could not save the note. It may have changed elsewhere. Keep this draft and reopen before retrying.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = (day: localDayKey(_day), period: _period),
        loadedKey = '$_period:${localDayKey(_day)}';
    final note = ref.watch(reviewNoteProvider(filter));
    if (note.hasValue && _loaded != loadedKey && !_dirty) {
      _note.text = note.valueOrNull?.text ?? '';
      _revision = note.valueOrNull?.revision ?? 0;
      _loaded = loadedKey;
    }
    final range = ref
        .read(routineRepositoryProvider)
        .reviewPeriod(_day, _period);
    final now = ref.read(clockProvider)();
    final upcoming =
        (ref.watch(allIntentionsProvider).valueOrNull ?? [])
            .where(
              (p) =>
                  p.status.isPending &&
                  p.reminderAt != null &&
                  !p.reminderAt!.isBefore(now),
            )
            .toList()
          ..sort((a, b) => a.reminderAt!.compareTo(b.reminderAt!));
    return PopScope(
      canPop: !_dirty && !_busy,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _busy || _leaving) return;
        _leaving = true;
        final leave = await _mayDiscard();
        _leaving = false;
        if (leave && context.mounted) {
          setState(() => _dirty = false);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('A little perspective')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Look back, gently.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('An optional moment to notice what helped.'),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [
                for (final period in ['daily', 'weekly'])
                  ChoiceChip(
                    label: Text(
                      period == 'daily' ? 'Daily review' : 'Weekly review',
                    ),
                    selected: _period == period,
                    onSelected: _busy ? null : (_) => _change(period: period),
                  ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${range.key}${_period == 'weekly' ? ' · week beginning' : ''}',
              ),
              onPressed: _busy
                  ? null
                  : () async {
                      final day = await showDatePicker(
                        context: context,
                        initialDate: _day,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100, 12, 31),
                      );
                      if (day != null) await _change(day: day);
                    },
            ),
            if (_period == 'weekly')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: RhythmWeekChart(day: _day),
              ),
            ref
                .watch(reviewFactsProvider(filter))
                .when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text(
                    'Could not read recorded outcomes. Reopen this review to retry.',
                  ),
                  data: (facts) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your recorded rhythm',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${facts.routinesSelected} occurrences explicitly selected in this period.',
                      ),
                      const SizedBox(height: 18),
                      ReviewOutcomeChart(states: facts.routineStates),
                      const SizedBox(height: 24),
                      Text(
                        'Promises you returned to',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline_rounded),
                        title: Text('${facts.promisesCompleted} completed'),
                        subtitle: Text(
                          '${facts.promisesDeferred} snoozed · groups may overlap',
                        ),
                      ),
                      if (facts.adjustmentEvidence.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Suggestions from explicit local evidence — your choice',
                        ),
                        for (final evidence in facts.adjustmentEvidence)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(evidence),
                          ),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const RoutinesScreen(),
                            ),
                          ),
                          child: const Text('Review routines manually'),
                        ),
                      ],
                    ],
                  ),
                ),
            const SizedBox(height: 24),
            Text(
              'On the horizon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (upcoming.isEmpty)
              const Text('No upcoming dated promises in the current plan.'),
            for (final promise in upcoming.take(5))
              ListTile(
                title: Text(
                  promise.rawContent,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(promise.reminderAt!.toLocal().toString()),
                onTap: () => context.push(RoutePaths.promiseDetail(promise.id)),
              ),
            const SizedBox(height: 24),
            const Text('What helped? What needs a little room?'),
            if (note.hasError)
              TextButton(
                onPressed: () => ref.invalidate(reviewNoteProvider(filter)),
                child: const Text('Retry loading saved note'),
              ),
            TextField(
              controller: _note,
              enabled: !_busy && _loaded == loadedKey,
              minLines: 2,
              maxLines: 6,
              maxLength: 1000,
              onChanged: (_) => setState(() => _dirty = true),
              decoration: const InputDecoration(
                hintText: 'Leave this blank if you prefer.',
              ),
            ),
            FilledButton(
              onPressed:
                  _busy || _loaded != loadedKey || _note.text.trim().isEmpty
                  ? null
                  : () => _save(filter),
              child: const Text('Save optional note'),
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_message != null) Text(_message!),
            TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      if (await _mayDiscard() && mounted) {
                        setState(() => _dirty = false);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
              child: const Text('Done for now'),
            ),
          ],
        ),
      ),
    );
  }
}
