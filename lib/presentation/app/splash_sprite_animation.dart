import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashSpriteAnimation extends StatefulWidget {
  const SplashSpriteAnimation({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<SplashSpriteAnimation> createState() => _SplashSpriteAnimationState();
}

class _SplashSpriteAnimationState extends State<SplashSpriteAnimation>
    with SingleTickerProviderStateMixin {
  static const _asset = 'lib/assets/images/cya-splash-sprite.webp';
  static const _frameCount = 36;
  static const _columns = 6;
  static const _frameSize = 192.0;
  static const _fps = 15.0;

  late final AnimationController _controller;
  ui.Image? _sprite;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: (_frameCount / _fps * 1000).round()),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _complete();
          }
        });
    _loadSprite();
  }

  Future<void> _loadSprite() async {
    try {
      final data = await rootBundle.load(_asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() => _sprite = frame.image);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.forward(from: 0);
        }
      });
    } catch (_) {
      if (!mounted) return;
      _complete();
    }
  }

  void _complete() {
    if (_completed || !mounted) return;
    _completed = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    _sprite?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sprite = _sprite;
    if (sprite == null) {
      return Image.asset(
        'lib/assets/images/cya-logo.png',
        fit: BoxFit.cover,
        cacheWidth: 512,
        cacheHeight: 512,
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final frame = (_controller.value * (_frameCount - 1))
              .clamp(0, _frameCount - 1)
              .floor();
          return CustomPaint(
            painter: _SpritePainter(
              sprite: sprite,
              frame: frame,
              columns: _columns,
              frameSize: _frameSize,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  const _SpritePainter({
    required this.sprite,
    required this.frame,
    required this.columns,
    required this.frameSize,
  });

  final ui.Image sprite;
  final int frame;
  final int columns;
  final double frameSize;

  @override
  void paint(Canvas canvas, Size size) {
    final row = frame ~/ columns;
    final column = frame % columns;
    final source = Rect.fromLTWH(
      column * frameSize,
      row * frameSize,
      frameSize,
      frameSize,
    );
    final target = Offset.zero & size;
    canvas.drawImageRect(
      sprite,
      source,
      target,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) {
    return oldDelegate.sprite != sprite || oldDelegate.frame != frame;
  }
}
