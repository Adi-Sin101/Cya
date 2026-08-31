import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/cya_haptics.dart';
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
    final now = ref.watch(clockProvider)();
    final reminderAt = _customReminder ?? _preset.resolve(now);
    final canSave = _controller.text.trim().isNotEmpty && !_saving;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xs,
        AppSpacing.page,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'What do you want to save for later?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Paste, write, or dictate it. I'll bring it back.",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 3,
              style: theme.textTheme.bodyLarge,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Reply to Sarah about the trip…',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'When should I remind you?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm + 2,
              runSpacing: AppSpacing.sm + 2,
              children: <Widget>[
                for (final preset in ReminderPreset.values)
                  ChoiceChip(
                    label: Text(preset.label),
                    selected: _customReminder == null && _preset == preset,
                    onSelected: (_) {
                      CyaHaptics.selection(context);
                      setState(() {
                        _preset = preset;
                        _customReminder = null;
                      });
                    },
                  ),
                ActionChip(
                  avatar: const Icon(Icons.event_rounded, size: 18),
                  label: Text(
                    _customReminder == null
                        ? 'Pick date'
                        : formatDay(_customReminder!),
                  ),
                  onPressed: _pickDate,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Back at ${formatDay(reminderAt)} · '
                    '${formatTimeOfDay(reminderAt)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: context.cyaColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSave ? _save : null,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save to Cya! ✨'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    CyaHaptics.tap(context);
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
        CyaHaptics.confirm(context);
        // The promise is saved either way; this only decides whether Cya! may
        // knock (PRD §3.5 — asked here, where the reason is on screen).
        ref.read(reminderPortProvider).ensureNotificationPermission();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text("Saved. I'll remember for you.")),
          );
      },
      (error) {
        CyaHaptics.warn(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      },
    );
  }
}
