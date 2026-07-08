import 'package:flutter/material.dart';

import '../../widgets/coming_soon_view.dart';

class PromisesScreen extends StatelessWidget {
  const PromisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonView(
      title: 'Promises',
      icon: Icons.bookmark_rounded,
      message:
          'Your full list of promises — with categories and search — lands next.',
    );
  }
}
