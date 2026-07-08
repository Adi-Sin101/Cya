// Smoke tests for the Cya! app shell and reactive Home.

import 'package:cya/presentation/app/cya_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home renders greeting, Today card and a promise', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CyaApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Arif'), findsOneWidget); // greeting
    expect(find.text('4 promises'), findsOneWidget); // Today hero card
    expect(find.text('Reply to Sarah'), findsOneWidget); // mock promise
    expect(find.text('Garden'), findsWidgets); // bottom nav
  });

  testWidgets('Toggling a promise updates the Today completion ring', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CyaApp()));
    await tester.pumpAndSettle();

    // Mock data starts with 1 of 4 completed.
    expect(find.text('1/4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('0/4'), findsOneWidget);
  });

  testWidgets('Profile dark mode switch updates the app theme', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CyaApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    final switchFinder = find.byKey(
      const ValueKey<String>('profile-dark-mode-switch'),
    );
    expect(switchFinder, findsOneWidget);
    expect(Theme.of(tester.element(switchFinder)).brightness, Brightness.light);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(switchFinder)).brightness, Brightness.dark);
  });
}
