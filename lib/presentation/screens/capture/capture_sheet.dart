import 'package:flutter/material.dart';

import '../../../core/theme/cya_colors_extension.dart';
import '../../../domain/enums/reminder_preset.dart';

/// Opens the capture bottom sheet (PRD §8.2 "Capture Intention").
///
/// A visual stub for this iteration — the real capture is the native-thin path
/// (PRD §5.4). Saving here just acknowledges and closes.
Future<void> showCaptureSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const CaptureSheet(),
  );
}

class CaptureSheet extends StatelessWidget {
  const CaptureSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'What do you want to save for later?',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Paste, write, or let Cya! understand what this is about.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            height: 96,
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cya.surface2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('Your intention…', style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(height: 20),
          Text('When should I remind you?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final preset in ReminderPreset.values)
                Chip(
                  label: Text(preset.label),
                  backgroundColor: cya.surface2,
                  labelStyle: theme.textTheme.labelLarge,
                ),
              Chip(
                label: const Text('Pick Date'),
                backgroundColor: cya.surface2,
                labelStyle: theme.textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                'AI Suggestion · Tonight · 8:00 PM',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Capture arrives with the native-thin path ✨',
                      ),
                    ),
                  );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Save to Cya! ✨'),
            ),
          ),
        ],
      ),
    );
  }
}
