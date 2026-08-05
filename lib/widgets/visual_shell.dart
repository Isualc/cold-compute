import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Animated, low-cost background shared by every major screen.
class StrategicBackdrop extends StatefulWidget {
  final Widget child;
  final bool animate;

  const StrategicBackdrop({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<StrategicBackdrop> createState() => _StrategicBackdropState();
}

class _StrategicBackdropState extends State<StrategicBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.animate && !reduced) {
      if (_controller.status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) =>
                  CustomPaint(painter: _BackdropPainter(_controller.value)),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  final double phase;

  const _BackdropPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.line.withValues(alpha: .09)
      ..strokeWidth = .7;
    const spacing = 44.0;
    final drift = phase * spacing;
    for (double x = -spacing + drift; x < size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (
      double y = -spacing + drift * .45;
      y < size.height + spacing;
      y += spacing
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [AppTheme.teal.withValues(alpha: .09), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * (.22 + math.sin(phase * math.pi * 2) * .03),
                size.height * .18,
              ),
              radius: size.shortestSide * .62,
            ),
          );
    canvas.drawRect(Offset.zero & size, glow);

    final dotPaint = Paint()
      ..color = AppTheme.textPrimary.withValues(alpha: .08);
    for (var i = 0; i < 46; i++) {
      final fx = ((i * 37) % 101) / 101;
      final fy = ((i * 61) % 97) / 97;
      final pulse = .45 + .55 * math.sin((phase * 2 + i / 9) * math.pi * 2);
      dotPaint.color = AppTheme.textPrimary.withValues(
        alpha: .025 + pulse * .045,
      );
      canvas.drawCircle(
        Offset(fx * size.width, fy * size.height),
        .7,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Color? tint;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool blur;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.tint,
    this.borderColor,
    this.onTap,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget panel = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? AppTheme.surfaceGlass,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? AppTheme.lineSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    if (blur) {
      panel = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: panel,
        ),
      );
    }

    if (onTap == null) return panel;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: panel),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  final Widget? trailing;

  const SectionLabel(
    this.text, {
    super.key,
    this.color = AppTheme.textSecondary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              letterSpacing: 1.8,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool pulse;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: pulse
                    ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 1)]
                    : null,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignalButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const SignalButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: AppTheme.surface.withValues(alpha: .8),
        side: const BorderSide(color: AppTheme.lineSoft),
      ),
    );
  }
}
