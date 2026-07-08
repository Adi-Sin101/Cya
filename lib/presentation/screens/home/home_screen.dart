import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/home_providers.dart';
import 'widgets/home_greeting_header.dart';
import 'widgets/memory_garden_preview.dart';
import 'widgets/promise_list_section.dart';
import 'widgets/today_card.dart';
import 'widgets/week_stats_section.dart';

/// The Home screen: greeting, Today card, promises, garden, and weekly stats,
/// reactive over [homeControllerProvider] (PRD §8.2).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: <Widget>[
          HomeGreetingHeader(userName: home.userName, level: home.level),
          const SizedBox(height: 20),
          TodayCard(total: home.todayTotal, completed: home.todayCompleted),
          const SizedBox(height: 24),
          PromiseListSection(
            promises: home.promises,
            onToggle: controller.togglePromise,
          ),
          const SizedBox(height: 24),
          MemoryGardenPreview(garden: home.garden),
          const SizedBox(height: 16),
          WeekStatsSection(stats: home.week),
        ],
      ),
    );
  }
}
