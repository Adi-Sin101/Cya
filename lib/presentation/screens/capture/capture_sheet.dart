import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/reminder_format.dart';
import '../../../domain/enums/reminder_preset.dart';
import '../../../domain/usecases/capture_intention.dart';

/// Opens the in-app capture sheet (PRD §8.2 "Capture Intention").
///
/// The *fast* capture path is native (PRD §5.4); this is the deliberate,
/// in-app one. It still does the same minimum work on save: one insert plus a
/// default reminder, no network, no inference (PRD §3.2).
Future<void> showCaptureSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const CaptureSheet(),
  );
}

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({super.key});

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  ReminderPreset _preset = ReminderPreset.defaultPreset;
  DateTime? _customReminder;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Straight to typing: capture friction is the product's whole thesis.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    final now = ref.watch(clockProvider)();
    final reminderAt = _customReminder ?? _preset.resolve(now);

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
            "Paste, write, or dictate it. I'll bring it back.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Reply to Sarah about the trip…',
              filled: true,
              fillColor: cya.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('When should I remind you?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final preset in ReminderPreset.values)
                ChoiceChip(
                  label: Text(preset.label),
                  selected: _customReminder == null && _preset == preset,
                  onSelected: (_) => setState(() {
                    _preset = preset;
                    _customReminder = null;
                  }),
                ),
              ActionChip(
                avatar: const Icon(Icons.event_rounded, size: 16),
                label: Text(
                  _customReminder == null
                      ? 'Pick Date'
                      : formatDay(_customReminder!),
                ),
                onPressed: _pickDate,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Back at ${formatDay(reminderAt)} · '
                '${formatTimeOfDay(reminderAt)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _controller.text.trim().isEmpty || _saving
                  ? null
                  : _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save to Cya! ✨'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = ref.read(clockProvider)();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (!mounted) return;
    setState(() {
      _customReminder = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 9,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await ref
        .read(captureIntentionProvider)
        .call(
          rawContent: _controller.text,
          sourceApp: CaptureIntention.inAppSource,
          preset: _preset,
          reminderAt: _customReminder,
        );
    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (_) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text("Saved. I'll remember for you.")),
          );
      },
      (error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      },
    );
  }
}
