import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/topojson_world.dart';
import '../models/game_state.dart';
import '../models/lang.dart';
import '../models/metrics.dart';
import '../theme.dart';
import 'visual_shell.dart';

/// Lagekarte auf Basis der echten Natural-Earth-Küstenlinien (110m-TopoJSON,
/// gleiche Datenbasis wie im FoerderPilot): Fähigkeitsknoten, Vertragsbrücke,
/// Verifikations-Checkpoints und Schattenrisiko reagieren auf [state].
class WorldSituationMap extends StatefulWidget {
  final GameState state;
  final bool showBrief;
  final double? height;

  /// Endlosschleife der Kartenanimation. Widget-Tests schalten das ab,
  /// damit `pumpAndSettle` terminiert.
  static bool loopAnimation = true;

  const WorldSituationMap({
    super.key,
    required this.state,
    this.showBrief = true,
    this.height,
  });

  @override
  State<WorldSituationMap> createState() => _WorldSituationMapState();
}

class _WorldSituationMapState extends State<WorldSituationMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );
  _MapRegion _selected = _MapRegion.pacific;
  _LandGeometry? _land;

  @override
  void initState() {
    super.initState();
    TopojsonWorld.load().then((world) {
      if (!mounted) return;
      setState(() => _land = _LandGeometry.fromWorld(world));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduced) {
      _controller.stop();
    } else if (WorldSituationMap.loopAnimation) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.lang;
    final map = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _WorldMapPainter(
              state: widget.state,
              phase: _controller.value,
              lang: lang,
              selected: _selected,
              land: _land,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    return GlassPanel(
      padding: const EdgeInsets.all(10),
      blur: false,
      tint: const Color(0xD909171F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
            child: SectionLabel(
              lang == AppLang.de ? 'Globales Netzwerk' : 'Global network',
              color: AppTheme.tealBright,
              trailing: _EscalationPill(state: widget.state),
            ),
          ),
          SizedBox(height: widget.height ?? 218, child: map),
          if (widget.showBrief) ...[
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: _RegionBrief(
                key: ValueKey(_selected),
                region: _selected,
                state: widget.state,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleTap(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    // Grobe Regionen-Zuordnung entlang der Längengrade der Knoten.
    final width = box.size.width;
    final x = details.localPosition.dx / math.max(width, 1);
    final next = switch (x) {
      < .40 => _MapRegion.usa,
      < .62 => _MapRegion.eu,
      < .77 => _MapRegion.india,
      _ => _MapRegion.china,
    };
    if (next != _selected) setState(() => _selected = next);
  }
}

/// Kartenausschnitt der äquirektangulären Projektion.
const double _latTop = 84;
const double _latBottom = -58;

Offset _geo(double lat, double lng) => Offset(
      (lng + 180) / 360,
      (_latTop - lat) / (_latTop - _latBottom),
    );

/// Normalisierte Land-Ringe + Pfad-Cache pro Zeichenfläche.
class _LandGeometry {
  final List<List<Offset>> rings;
  Size? _cachedSize;
  Path? _cachedPath;

  _LandGeometry(this.rings);

  factory _LandGeometry.fromWorld(TopojsonWorld world) {
    final rings = <List<Offset>>[];
    for (final ring in world.polygons) {
      // Antarktis liegt komplett unter dem Kartenausschnitt — weglassen.
      if (ring.every((p) => p.lat < _latBottom)) continue;
      final points = <Offset>[
        for (final p in ring) _geo(p.lat.clamp(_latBottom, _latTop), p.lng),
      ];
      if (points.length >= 3) rings.add(points);
    }
    return _LandGeometry(rings);
  }

  Path pathFor(Size size) {
    if (_cachedPath != null && _cachedSize == size) return _cachedPath!;
    final path = Path();
    for (final ring in rings) {
      path.moveTo(ring.first.dx * size.width, ring.first.dy * size.height);
      for (final p in ring.skip(1)) {
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      path.close();
    }
    _cachedSize = size;
    _cachedPath = path;
    return path;
  }
}

enum _MapRegion { usa, eu, india, china, pacific }

class _RegionBrief extends StatelessWidget {
  final _MapRegion region;
  final GameState state;

  const _RegionBrief({super.key, required this.region, required this.state});

  @override
  Widget build(BuildContext context) {
    final de = state.lang == AppLang.de;
    final us = state.metric(Metric.usCapability).round();
    final cn = state.metric(Metric.cnCapability).round();
    final trust = state.metric(Metric.trust).round();
    final verification = state.metric(Metric.verification).round();
    final risk = state.metric(Metric.covertRisk).round();

    final (title, detail, color, icon) = switch (region) {
      _MapRegion.usa => (
        de ? 'USA · FRONTIER' : 'USA · FRONTIER',
        de
            ? 'Fähigkeitsindex $us · politischer Handlungsspielraum ${state.metric(Metric.politicalCapital).round()}'
            : 'Capability index $us · political room ${state.metric(Metric.politicalCapital).round()}',
        AppTheme.blue,
        Icons.hub_outlined,
      ),
      _MapRegion.china => (
        de ? 'CHINA · FRONTIER' : 'CHINA · FRONTIER',
        de
            ? 'Fähigkeitsindex $cn · Abstand zu den USA ${us - cn >= 0 ? "+" : ""}${us - cn}'
            : 'Capability index $cn · US lead ${us - cn >= 0 ? "+" : ""}${us - cn}',
        AppTheme.red,
        Icons.memory_outlined,
      ),
      _MapRegion.eu => (
        de ? 'EUROPA · REGELMACHT' : 'EUROPE · RULE MAKER',
        de
            ? 'Brückenknoten für Standards, Inspektionen und Forschungszugang.'
            : 'Bridge node for standards, inspections and research access.',
        AppTheme.tealBright,
        Icons.account_balance_outlined,
      ),
      _MapRegion.india => (
        de ? 'INDIEN · SWING NODE' : 'INDIA · SWING NODE',
        de
            ? 'Talent-, Energie- und Compute-Partner außerhalb der beiden Hauptblöcke.'
            : 'Talent, energy and compute partner beyond the two main blocs.',
        AppTheme.amber,
        Icons.bolt_outlined,
      ),
      _MapRegion.pacific => (
        de ? 'PAZIFIK · SYSTEMLAGE' : 'PACIFIC · SYSTEM STATE',
        de
            ? 'Vertrauen $trust · Verifikation $verification · Schattenrisiko $risk · Eskalation ${state.metric(Metric.escalation).round()}'
            : 'Trust $trust · verification $verification · covert risk $risk · escalation ${state.metric(Metric.escalation).round()}',
        _treatyColor(state),
        Icons.public,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Alarmstufen-Anzeige über der Karte.
class _EscalationPill extends StatelessWidget {
  final GameState state;

  const _EscalationPill({required this.state});

  @override
  Widget build(BuildContext context) {
    final escalation = state.metric(Metric.escalation);
    final stage = EscalationStage.of(escalation);
    return StatusPill(
      label:
          '${stage.code.t(state.lang)} · ${stage.label.t(state.lang)} '
          '${escalation.round()}',
      color: stage.color,
      icon: escalation >= 60
          ? Icons.warning_amber_rounded
          : Icons.shield_outlined,
      pulse: escalation >= 60,
    );
  }
}

/// Alarmstufe der militärischen Lage — die Leiter, an deren Ende (100)
/// die Partie im Krieg endet.
class EscalationStage {
  final LText label;
  final Color color;
  final LText code;

  const EscalationStage(this.label, this.color, this.code);

  static EscalationStage of(double escalation) {
    if (escalation >= 80) {
      return const EscalationStage(
        LText('Kriegsgefahr', 'Imminent conflict'),
        AppTheme.danger,
        LText('STUFE 5', 'LEVEL 5'),
      );
    }
    if (escalation >= 60) {
      return const EscalationStage(
        LText('Krise', 'Crisis'),
        AppTheme.red,
        LText('STUFE 4', 'LEVEL 4'),
      );
    }
    if (escalation >= 40) {
      return const EscalationStage(
        LText('Spannung', 'Tension'),
        AppTheme.amber,
        LText('STUFE 3', 'LEVEL 3'),
      );
    }
    if (escalation >= 20) {
      return const EscalationStage(
        LText('Erhöhte Wachsamkeit', 'Heightened alert'),
        AppTheme.blue,
        LText('STUFE 2', 'LEVEL 2'),
      );
    }
    return const EscalationStage(
      LText('Friedenslage', 'Peacetime posture'),
      AppTheme.green,
      LText('STUFE 1', 'LEVEL 1'),
    );
  }
}

Color _treatyColor(GameState state) => switch (state.treatyPhase) {
  TreatyPhase.none || TreatyPhase.collapsed => AppTheme.danger,
  TreatyPhase.negotiation => AppTheme.amber,
  TreatyPhase.moratorium => AppTheme.covert,
  TreatyPhase.controlledAscent => AppTheme.green,
  _ => AppTheme.tealBright,
};

class _WorldMapPainter extends CustomPainter {
  final GameState state;
  final double phase;
  final AppLang lang;
  final _MapRegion selected;
  final _LandGeometry? land;

  const _WorldMapPainter({
    required this.state,
    required this.phase,
    required this.lang,
    required this.selected,
    required this.land,
  });

  // Reale Koordinaten: Washington, Brüssel, Delhi, Peking.
  static final Offset _usa = _geo(38.9, -77.0);
  static final Offset _eu = _geo(50.85, 4.35);
  static final Offset _india = _geo(28.61, 77.21);
  static final Offset _china = _geo(39.90, 116.41);

  // Plausible Standorte verdeckter Projekte: Xinjiang, Sibirien, Sahara.
  static final List<Offset> _covertSites = [
    _geo(41.5, 85),
    _geo(61, 98),
    _geo(23, 8),
  ];

  // Militärische Brennpunkte, an denen sich Eskalation zuerst zeigt:
  // Taiwanstraße, Südchinesisches Meer, Koreanische Halbinsel,
  // Malakkastraße (Chip- und Energie-Nadelöhr).
  static final List<(Offset, String)> _flashpoints = [
    (_geo(24.5, 119.5), 'TWN'),
    (_geo(14.0, 114.0), 'SCS'),
    (_geo(38.0, 127.0), 'KOR'),
    (_geo(3.0, 100.5), 'MAL'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
    );
    _paintOcean(canvas, size);
    _paintGraticule(canvas, size);
    _paintLand(canvas, size);
    _paintSecondaryLinks(canvas, size);
    _paintTreatyLink(canvas, size);
    _paintCovertRisk(canvas, size);
    _paintEscalation(canvas, size);
    _paintNode(
      canvas,
      size,
      _usa,
      'USA',
      AppTheme.blue,
      state.metric(Metric.usCapability),
      selected == _MapRegion.usa,
    );
    _paintNode(
      canvas,
      size,
      _eu,
      'EU',
      AppTheme.tealBright,
      34,
      selected == _MapRegion.eu,
    );
    _paintNode(
      canvas,
      size,
      _india,
      'IND',
      AppTheme.amber,
      29,
      selected == _MapRegion.india,
    );
    _paintNode(
      canvas,
      size,
      _china,
      'CHN',
      AppTheme.red,
      state.metric(Metric.cnCapability),
      selected == _MapRegion.china,
    );
    _paintScan(canvas, size);
    canvas.restore();
  }

  void _paintOcean(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A202A), Color(0xFF07131B)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    final pacificGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              _treatyColor(state).withValues(alpha: .11),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .52, size.height * .43),
              radius: size.width * .48,
            ),
          );
    canvas.drawRect(Offset.zero & size, pacificGlow);
  }

  void _paintGraticule(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.tealBright.withValues(alpha: .07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7;
    // Längengrade alle 30°, Breitengrade 60N/30N/0/30S auf der Projektion.
    for (var lng = -150; lng <= 150; lng += 30) {
      final x = _geo(0, lng.toDouble()).dx * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (final lat in const [60.0, 30.0, 0.0, -30.0]) {
      final y = _geo(lat, 0).dy * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    paint.color = AppTheme.tealBright.withValues(alpha: .035);
    for (var i = 0; i < 70; i++) {
      final x = ((i * 47) % 101) / 101 * size.width;
      final y = ((i * 31) % 89) / 89 * size.height;
      canvas.drawCircle(Offset(x, y), .8, paint);
    }
  }

  void _paintLand(Canvas canvas, Size size) {
    final geometry = land;
    if (geometry == null) return;
    final path = geometry.pathFor(size);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF18303A)
        ..style = PaintingStyle.fill,
    );
    // Küsten-Glow + feine Konturlinie: liest sich wie ein Lagetisch.
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.tealBright.withValues(alpha: .10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF41606A).withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7,
    );
  }

  void _paintSecondaryLinks(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = AppTheme.teal.withValues(alpha: .25);
    canvas.drawPath(_curve(_point(_usa, size), _point(_eu, size), -.10), paint);
    paint.color = AppTheme.amber.withValues(alpha: .19);
    canvas.drawPath(
      _curve(_point(_eu, size), _point(_india, size), .04),
      paint,
    );
    paint.color = AppTheme.red.withValues(alpha: .18);
    canvas.drawPath(
      _curve(_point(_india, size), _point(_china, size), -.02),
      paint,
    );

    for (final link in [
      (_usa, _eu, AppTheme.tealBright),
      (_eu, _india, AppTheme.amber),
      (_india, _china, AppTheme.red),
    ]) {
      final path = _curve(_point(link.$1, size), _point(link.$2, size), -.06);
      final metric = path.computeMetrics().first;
      final tangent = metric.getTangentForOffset(
        metric.length * ((phase + .3) % 1),
      );
      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          1.8,
          Paint()..color = link.$3.withValues(alpha: .7),
        );
      }
    }
  }

  void _paintTreatyLink(Canvas canvas, Size size) {
    final start = _point(_usa, size);
    final end = _point(_china, size);
    final path = _curve(start, end, -.22);
    final color = _treatyColor(state);
    final trust = state.metric(Metric.trust) / 100;
    final broken =
        state.treatyPhase == TreatyPhase.none ||
        state.treatyPhase == TreatyPhase.collapsed;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6 + trust * 1.8
      ..color = color.withValues(alpha: .42 + trust * .45);

    if (broken || state.treatyPhase == TreatyPhase.negotiation) {
      _drawDashedPath(canvas, path, paint, dash: broken ? 7 : 11, gap: 7);
    } else {
      canvas.drawPath(path, paint);
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
        ..color = color.withValues(alpha: .11);
      canvas.drawPath(path, glow);
    }

    final metric = path.computeMetrics().first;
    if (!broken) {
      final checkpoints = (state.metric(Metric.verification) / 18).ceil().clamp(
        1,
        6,
      );
      for (var i = 1; i <= checkpoints; i++) {
        final t = i / (checkpoints + 1);
        final tangent = metric.getTangentForOffset(metric.length * t);
        if (tangent == null) continue;
        canvas.drawCircle(
          tangent.position,
          3.5,
          Paint()..color = const Color(0xFF08151D),
        );
        canvas.drawCircle(
          tangent.position,
          3,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = color.withValues(alpha: .9),
        );
      }
    }

    final particles = broken ? 2 : 4;
    for (var i = 0; i < particles; i++) {
      final direction = i.isEven ? 1.0 : -1.0;
      final offset = ((phase * direction + i / particles) % 1 + 1) % 1;
      final tangent = metric.getTangentForOffset(metric.length * offset);
      if (tangent == null) continue;
      canvas.drawCircle(
        tangent.position,
        broken ? 2.2 : 2.7,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    final labelPoint = metric.getTangentForOffset(metric.length * .5)?.position;
    if (labelPoint != null) {
      _label(
        canvas,
        state.treatyPhase.label(lang).toUpperCase(),
        labelPoint.translate(0, -11),
        color,
        size: 7.5,
        centered: true,
      );
    }
  }

  void _paintCovertRisk(Canvas canvas, Size size) {
    final risk = state.metric(Metric.covertRisk) / 100;
    if (risk < .03) return;
    final pulse = .8 + math.sin(phase * math.pi * 2) * .2;
    for (var i = 0; i < _covertSites.length; i++) {
      final center = _point(_covertSites[i], size);
      final radius = (8 + risk * 23) * pulse * (1 - i * .12);
      final heat = Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.covert.withValues(alpha: .2 * risk),
            AppTheme.danger.withValues(alpha: .05 * risk),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, heat);
      if (risk > .45) {
        canvas.drawCircle(
          center,
          2,
          Paint()..color = AppTheme.covert.withValues(alpha: .5),
        );
      }
    }
  }

  /// Militärische Lage: Brennpunkte, Konfliktachse und Alarmrahmen.
  void _paintEscalation(Canvas canvas, Size size) {
    final escalation = state.metric(Metric.escalation);
    if (escalation < 8) return;
    final level = (escalation / 100).clamp(0.0, 1.0);
    final stage = EscalationStage.of(escalation);
    final pulse = .72 + math.sin(phase * math.pi * 4) * .28;

    // Brennpunkte glimmen ab Stufe 2 und flackern in der Krise.
    final activeCount = switch (escalation) {
      >= 80 => 4,
      >= 55 => 3,
      >= 30 => 2,
      _ => 1,
    };
    for (var i = 0; i < activeCount; i++) {
      final (position, code) = _flashpoints[i];
      final center = _point(position, size);
      final radius = (5 + level * 13) * (i.isEven ? pulse : 1.15 - pulse * .3);

      canvas.drawCircle(
        center,
        radius * 2.1,
        Paint()
          ..shader = RadialGradient(
            colors: [
              stage.color.withValues(alpha: .26 * level),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 2.1)),
      );
      // Zielkreuz statt Punkt — das ist keine Metrik, das ist eine Lage.
      final cross = Paint()
        ..color = stage.color.withValues(alpha: .55 + level * .4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1;
      canvas.drawCircle(center, radius, cross);
      canvas.drawLine(
        center.translate(-radius - 3, 0),
        center.translate(-radius + 1, 0),
        cross,
      );
      canvas.drawLine(
        center.translate(radius - 1, 0),
        center.translate(radius + 3, 0),
        cross,
      );
      canvas.drawLine(
        center.translate(0, -radius - 3),
        center.translate(0, -radius + 1),
        cross,
      );
      canvas.drawLine(
        center.translate(0, radius - 1),
        center.translate(0, radius + 3),
        cross,
      );
      if (escalation >= 40) {
        _label(
          canvas,
          code,
          center.translate(0, -radius - 12),
          stage.color,
          size: 7,
          centered: true,
        );
      }
    }

    // Ab der Spannungsstufe legt sich eine Konfliktachse über die
    // Vertragsbrücke: derselbe Weg, andere Bedeutung.
    if (escalation >= 40) {
      final axis = _curve(_point(_usa, size), _point(_china, size), -.05);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 + level * 2.4
        ..color = stage.color.withValues(alpha: .22 + level * .5);
      _drawDashedPath(canvas, axis, paint, dash: 4 + level * 7, gap: 6);

      final metric = axis.computeMetrics().first;
      final head = metric.getTangentForOffset(
        metric.length * ((phase * 2) % 1),
      );
      if (head != null) {
        canvas.drawCircle(
          head.position,
          2 + level * 2,
          Paint()
            ..color = stage.color
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }

    // Alarmrahmen: Ab der Krise pulsiert der Kartenrand.
    if (escalation >= 60) {
      final border = Rect.fromLTWH(0, 0, size.width, size.height).deflate(1.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(border, const Radius.circular(15)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 + level * 2
          ..color = stage.color.withValues(alpha: .18 + pulse * .3),
      );
      // Rote Ecken wie auf einem Lagemonitor im Alarmzustand.
      const len = 16.0;
      final tick = Paint()
        ..color = stage.color.withValues(alpha: .5 + pulse * .4)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (final corner in [
        (const Offset(6, 6), const Offset(1, 0), const Offset(0, 1)),
        (Offset(size.width - 6, 6), const Offset(-1, 0), const Offset(0, 1)),
        (Offset(6, size.height - 6), const Offset(1, 0), const Offset(0, -1)),
        (
          Offset(size.width - 6, size.height - 6),
          const Offset(-1, 0),
          const Offset(0, -1),
        ),
      ]) {
        canvas.drawLine(
          corner.$1,
          corner.$1 + corner.$2 * len,
          tick,
        );
        canvas.drawLine(
          corner.$1,
          corner.$1 + corner.$3 * len,
          tick,
        );
      }
    }
  }

  void _paintNode(
    Canvas canvas,
    Size size,
    Offset normalized,
    String label,
    Color color,
    double value,
    bool isSelected,
  ) {
    final center = _point(normalized, size);
    final base = 5.5 + value / 100 * 5;
    final pulse = 1 + math.sin((phase + normalized.dx) * math.pi * 2) * .08;
    final radius = base * pulse;

    if (isSelected) {
      canvas.drawCircle(
        center,
        radius + 8,
        Paint()
          ..color = color.withValues(alpha: .08)
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawCircle(
      center,
      radius + 4,
      Paint()
        ..color = color.withValues(alpha: .12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF08151D));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2 : 1.35
        ..color = color,
    );
    canvas.drawCircle(center, 2.2, Paint()..color = color);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 3),
      -.8 + phase * math.pi * 2,
      1.1,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: .68),
    );
    _label(
      canvas,
      label,
      center.translate(0, radius + 8),
      color,
      centered: true,
      size: 7.8,
    );
  }

  void _paintScan(Canvas canvas, Size size) {
    // Faktor 2 hält den Sweep an der Schleifen-Nahtstelle stetig.
    final x = ((phase * 2) % 1) * size.width;
    final rect = Rect.fromLTWH(x - 28, 0, 56, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, Color(0x1265E3D0), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  Path _curve(Offset from, Offset to, double bend) {
    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final control = mid.translate(0, bend * (to.dx - from.dx).abs());
    return Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
  }

  Offset _point(Offset normalized, Size size) =>
      Offset(normalized.dx * size.width, normalized.dy * size.height);

  void _label(
    Canvas canvas,
    String text,
    Offset at,
    Color color, {
    double size = 8,
    bool centered = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: .92),
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(canvas, centered ? at.translate(-painter.width / 2, 0) : at);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dash, metric.length),
          ),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.state.turn != state.turn ||
      oldDelegate.state.treatyPhase != state.treatyPhase ||
      oldDelegate.state.metric(Metric.escalation) !=
          state.metric(Metric.escalation) ||
      oldDelegate.selected != selected ||
      oldDelegate.land != land;
}
