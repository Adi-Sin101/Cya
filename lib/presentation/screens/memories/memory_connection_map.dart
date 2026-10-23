import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/memory.dart';

/// A bounded view of saved, accepted edges. The full list remains below it.
class MemoryConnectionMap extends StatelessWidget {
  const MemoryConnectionMap({
    super.key,
    required this.source,
    required this.links,
    required this.onOpen,
  });
  final Memory source;
  final List<Memory> links;
  final ValueChanged<Memory> onOpen;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final nodes = links.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Around this thought', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '${nodes.length} of ${links.length} saved links · Full list below',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          height: 300,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final center = Offset(constraints.maxWidth / 2, 150);
              final points = [
                for (var i = 0; i < nodes.length; i++)
                  Offset(
                    center.dx +
                        (constraints.maxWidth / 2 - 48) *
                            math.cos(
                              -math.pi / 2 + i * math.pi * 2 / nodes.length,
                            ),
                    center.dy +
                        108 *
                            math.sin(
                              -math.pi / 2 + i * math.pi * 2 / nodes.length,
                            ),
                  ),
              ];
              return Stack(
                children: [
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: CustomPaint(
                        painter: _ConnectionsPainter(
                          center,
                          points,
                          theme.colorScheme.primary.withValues(alpha: .3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: center.dx - 42,
                    top: center.dy - 32,
                    child: Semantics(
                      label: 'Source thought: ${source.displayText}',
                      child: Container(
                        width: 84,
                        height: 64,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'This thought',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  for (var i = 0; i < nodes.length; i++)
                    Positioned(
                      left: points[i].dx - 40,
                      top: points[i].dy - 28,
                      child: Semantics(
                        button: true,
                        label:
                            '${nodes[i].connectionKind ?? 'Related'}: ${nodes[i].displayText}. ${nodes[i].connectionOrigin == 'model' ? 'Accepted suggestion' : 'Your link'}',
                        child: Material(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => onOpen(nodes[i]),
                            child: SizedBox(
                              width: 80,
                              height: 56,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  nodes[i].displayText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ConnectionsPainter extends CustomPainter {
  _ConnectionsPainter(this.center, this.points, this.color);
  final Offset center;
  final List<Offset> points;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (final point in points) {
      canvas.drawLine(center, point, paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectionsPainter old) =>
      old.center != center || old.color != color || old.points != points;
}
