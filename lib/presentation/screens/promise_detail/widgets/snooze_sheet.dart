import 'package:flutter/material.dart';

/// Snooze options (PRD §8.2 actions). Deliberately few and coarse — a long
/// picker turns "later" into a planning session, which is the opposite of the
/// product.
const List<(String, Duration)> _snoozeOptions = <(String, Duration)>[
  ('In an hour', Duration(hours: 1)),
  ('This evening', Duration(hours: 3)),
  ('Tomorrow', Duration(days: 1)),
  ('Next week', Duration(days: 7)),
];

Future<Duration?> showSnoozeSheet(BuildContext context) {
  return showModalBottomSheet<Duration>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Bring it back…', style: theme.textTheme.titleLarge),
            ),
            for (final (label, duration) in _snoozeOptions)
              ListTile(
                leading: const Icon(Icons.snooze_rounded),
                title: Text(label),
                onTap: () => Navigator.of(sheetContext).pop(duration),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
