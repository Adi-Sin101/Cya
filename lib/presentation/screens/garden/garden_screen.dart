import 'package:flutter/material.dart';

import '../../widgets/coming_soon_view.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonView(
      title: 'Memory Garden',
      icon: Icons.spa_rounded,
      message: 'Watch your garden grow as you keep your promises. Coming soon.',
    );
  }
}
