import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_motion.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/routine_providers.dart';

class RhythmWeekChart extends ConsumerWidget {
  const RhythmWeekChart({super.key, required this.day});
  final DateTime day;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monday = DateTime(day.year, day.month, day.day - day.weekday + 1);
    final days = List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
    final records = [
      for (final date in days)
        ref.watch(dayRoutinesProvider(localDayKey(date))),
    ];
    if (records.any((r) => r.hasError)) {
      return const Text('Weekly plan could not be read. Reopen to retry.');
    }
    if (records.any((r) => !r.hasValue)) return const LinearProgressIndicator();
    final totals = [for (final r in records) r.value!.length];
    final completed = [
      for (final r in records)
        r.value!.where((o) => o.state == 'completed').length,
    ];
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'The shape of your week',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const Tooltip(
              message:
                  'Selected plans by their target day. Filled bars show explicitly completed routines, not tracked work.',
              child: Icon(Icons.info_outline_rounded, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          label: [
            for (var i = 0; i < 7; i++)
              '${MaterialLocalizations.of(context).formatMediumDate(days[i])}: ${totals[i]} selected, ${completed[i]} completed',
          ].join('; '),
          child: ExcludeSemantics(
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: AppMotion.of(context, AppMotion.slow),
                  curve: AppMotion.enter,
                  builder: (context, t, _) => SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _WeekPainter(
                        totals,
                        completed,
                        theme.colorScheme.primary,
                        t,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${totals.fold(0, (a, b) => a + b)} selected · ${completed.fold(0, (a, b) => a + b)} completed',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _WeekPainter extends CustomPainter {
  _WeekPainter(this.totals, this.completed, this.ink, this.reveal);
  final List<int> totals, completed;
  final Color ink;
  final double reveal;
  @override
  void paint(Canvas canvas, Size size) {
    final maximum = math.max(1, totals.reduce(math.max));
    for (var i = 0; i < 7; i++) {
      final x = (i + .5) * size.width / 7,
          width = math.min(22.0, size.width / 12);
      final height = totals[i] / maximum * (size.height - 16) * reveal;
      if (totals[i] == 0) {
        canvas.drawCircle(
          Offset(x, size.height - 6),
          2,
          Paint()..color = ink.withValues(alpha: .2),
        );
        continue;
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - width / 2, size.height - 6 - height, width, height),
          const Radius.circular(9),
        ),
        Paint()..color = ink.withValues(alpha: .16),
      );
      final filled = completed[i] / maximum * (size.height - 16) * reveal;
      if (filled > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x - width / 2,
              size.height - 6 - filled,
              width,
              filled,
            ),
            const Radius.circular(9),
          ),
          Paint()..color = ink,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_WeekPainter old) =>
      old.totals != totals ||
      old.completed != completed ||
      old.ink != ink ||
      old.reveal != reveal;
}
