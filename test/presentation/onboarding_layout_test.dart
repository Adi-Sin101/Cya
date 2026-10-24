import 'dart:io';
import 'dart:ui' as ui;

import 'package:cya/core/theme/app_theme.dart';
import 'package:cya/presentation/screens/onboarding/pages/notifications_page.dart';
import 'package:cya/presentation/screens/onboarding/pages/share_gesture_page.dart';
import 'package:cya/presentation/screens/onboarding/pages/welcome_page.dart';
import 'package:cya/presentation/screens/onboarding/widgets/notification_preview.dart';
import 'package:cya/presentation/screens/onboarding/widgets/share_gesture_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('PlusJakartaSans');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(
        rootBundle.load('lib/assets/fonts/PlusJakartaSans-$weight.ttf'),
      );
    }
    await fonts.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  for (final size in [const Size(360, 800), const Size(320, 640)]) {
    for (final reduced in [false, true]) {
      testWidgets('onboarding illustrations fit $size reduced=$reduced', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        for (final dark in [false, true]) {
          for (final scale in [1.0, 1.35]) {
            for (final (name, page, headline, action) in [
              (
                'welcome',
                WelcomePage(onNext: () {}),
                "I'll remember for you.",
                'Next',
              ),
              (
                'share',
                ShareGesturePage(onNext: () {}),
                'Save it without leaving the app.',
                'Got it',
              ),
              (
                'notification',
                NotificationsPage(onNext: () {}),
                'This is how I bring things back.',
                'Allow notifications',
              ),
            ]) {
              final boundary = GlobalKey();
              await tester.pumpWidget(
                ProviderScope(
                  child: MaterialApp(
                    theme: dark ? AppTheme.dark : AppTheme.light,
                    home: MediaQuery(
                      data: MediaQueryData(
                        size: size,
                        textScaler: TextScaler.linear(scale),
                        disableAnimations: reduced,
                      ),
                      child: RepaintBoundary(
                        key: boundary,
                        child: Scaffold(
                          body: SafeArea(
                            child: Column(
                              children: [
                                Expanded(child: page),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
              // Sample the beginning, sheet entrance, tap/save and exit phases.
              for (final milliseconds in [0, 900, 900, 700, 1200, 1200]) {
                await tester.pump(Duration(milliseconds: milliseconds));
                final error = tester.takeException();
                final output =
                    Platform.environment['CYA_ONBOARDING_PREVIEW_DIR'];
                if (output != null &&
                    (milliseconds == 0 || milliseconds == 1200)) {
                  await tester.runAsync(() async {
                    final image =
                        await (boundary.currentContext!.findRenderObject()!
                                as RenderRepaintBoundary)
                            .toImage();
                    final bytes = await image.toByteData(
                      format: ui.ImageByteFormat.png,
                    );
                    final file = File(
                      '$output/$name-${size.width.toInt()}-$scale-$dark-$reduced-${tester.binding.clock.now().millisecondsSinceEpoch}.png',
                    );
                    await file.parent.create(recursive: true);
                    await file.writeAsBytes(bytes!.buffer.asUint8List());
                    image.dispose();
                  });
                }
                expect(
                  error,
                  isNull,
                  reason:
                      '$name $size scale=$scale dark=$dark reduced=$reduced',
                );
                if (name == 'share') {
                  final demo = tester.getRect(find.byType(ShareGestureDemo));
                  for (final label in ['Share via', 'Cya!', 'Saved · 0.1s']) {
                    final visible = visiblePaintRect(tester, find.text(label));
                    if (!visible.isEmpty) {
                      expect(
                        visible.top,
                        greaterThanOrEqualTo(demo.top - .1),
                        reason: '$label escapes above illustration',
                      );
                      expect(
                        visible.bottom,
                        lessThanOrEqualTo(demo.bottom + .1),
                        reason: '$label paints over onboarding copy',
                      );
                      expect(
                        visible.right,
                        lessThanOrEqualTo(demo.right + .1),
                        reason: '$label escapes illustration width',
                      );
                      expect(
                        visible.left,
                        greaterThanOrEqualTo(demo.left - .1),
                        reason: '$label escapes illustration width',
                      );
                    }
                  }
                }
              }
              if (name == 'share') {
                final demo = tester.getRect(find.byType(ShareGestureDemo));
                expect(
                  demo.bottom,
                  lessThanOrEqualTo(tester.getRect(find.text(headline)).top),
                );
              }
              if (name == 'notification') {
                expect(
                  find.descendant(
                    of: find.byType(NotificationPreview),
                    matching: find.text('Reply to Sarah'),
                  ),
                  findsOneWidget,
                  reason:
                      'The decorative card behind must not repeat notification text/actions',
                );
              }
              await tester.ensureVisible(find.text(action));
              await tester.pump();
              expect(
                tester.getRect(find.text(action)).bottom,
                lessThan(size.height - 39),
              );
              await tester.pumpWidget(const SizedBox.shrink());
            }
          }
        }
      });
    }
  }
}

// The visible paint bounds include the actual animation transforms and ancestor
// clipping/opacity, rather than only checking layout rectangles (which missed
// the sheet sliding over the headline without a RenderFlex exception).
Rect visiblePaintRect(WidgetTester tester, Finder finder) {
  final render = tester.renderObject<RenderBox>(finder);
  var visible = MatrixUtils.transformRect(
    render.getTransformTo(null),
    render.paintBounds,
  );
  RenderObject? ancestor = render;
  while (ancestor != null) {
    if (ancestor is RenderOpacity && ancestor.opacity == 0) return Rect.zero;
    if ((ancestor is RenderClipRect && ancestor.clipBehavior != Clip.none) ||
        (ancestor is RenderClipRRect && ancestor.clipBehavior != Clip.none)) {
      visible = visible.intersect(
        MatrixUtils.transformRect(
          ancestor.getTransformTo(null),
          ancestor.paintBounds,
        ),
      );
    }
    ancestor = ancestor.parent;
  }
  return visible;
}
