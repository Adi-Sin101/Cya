import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/router/route_paths.dart';
import '../providers/intention_providers.dart';
import '../screens/garden/widgets/garden_scene_view.dart';
import 'motion/pressable.dart';

/// An illustrated doorway to the real event-backed Garden, never seeded growth.
class GardenDoorway extends ConsumerWidget {
  const GardenDoorway({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scene = ref.watch(gardenSceneProvider);
    final plants = scene.beds.expand((bed) => bed.plants).toList();
    // Keep miniature painting bounded; the full Garden retains all history.
    final preview = plants
        .skip(plants.length > 16 ? plants.length - 16 : 0)
        .toList();
    final count = scene.totalGrowths;
    return Pressable(
      semanticLabel: 'Open Memory Garden. $count promises kept.',
      onTap: () => context.push(RoutePaths.garden),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: GardenSceneView(
                plants: preview,
                height: 100,
                now: ref.watch(clockProvider)(),
                animateWind: false,
                plantScale: 1.1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Memory Garden',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          count == 0
                              ? 'A little room to grow.'
                              : '$count ${count == 1 ? 'promise' : 'promises'} kept. Still growing.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
