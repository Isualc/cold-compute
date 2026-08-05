import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;

/// Lädt eine TopoJSON-Weltkarte (countries-110m.json) und stellt die
/// Land-Polygone in Lat/Lng bereit. Singleton: wird nur einmal pro App-Session
/// geladen und gecacht.
///
/// Nutzung:
/// ```dart
/// final world = await TopojsonWorld.load();
/// for (final ring in world.polygons) { ... }
/// ```
class TopojsonWorld {
  /// Eine Liste von Polygon-Ringen (jeder Ring ist eine geschlossene Kontur aus LatLng-Punkten).
  final List<List<LatLng>> polygons;

  const TopojsonWorld(this.polygons);

  static TopojsonWorld? _cached;
  static Future<TopojsonWorld>? _loading;

  /// Lädt world_110m.json aus Assets (oder liefert den Cache).
  static Future<TopojsonWorld> load([String asset = 'assets/data/world_110m.json']) {
    if (_cached != null) return Future.value(_cached);
    _loading ??= _loadInternal(asset);
    return _loading!;
  }

  static Future<TopojsonWorld> _loadInternal(String asset) async {
    final raw = await rootBundle.loadString(asset);
    final data = jsonDecode(raw) as Map<String, dynamic>;

    // Transform: delta → absolute
    final transform = data['transform'] as Map<String, dynamic>;
    final scale = (transform['scale'] as List).cast<num>();
    final translate = (transform['translate'] as List).cast<num>();

    // Arcs dekodieren: delta-encoded → LatLng-Listen
    final arcsRaw = (data['arcs'] as List);
    final arcs = <List<LatLng>>[];
    for (final arcRaw in arcsRaw) {
      double x = 0, y = 0;
      final arc = <LatLng>[];
      for (final pt in (arcRaw as List)) {
        final p = (pt as List).cast<num>();
        x += p[0].toDouble();
        y += p[1].toDouble();
        arc.add(LatLng(
          lng: translate[0].toDouble() + scale[0].toDouble() * x,
          lat: translate[1].toDouble() + scale[1].toDouble() * y,
        ));
      }
      arcs.add(arc);
    }

    // Alle Polygon-Ringe aus countries-Geometrie zusammenfassen
    final polys = <List<LatLng>>[];
    final objects = (data['objects'] as Map<String, dynamic>)['countries'] as Map<String, dynamic>;
    final geometries = objects['geometries'] as List;
    for (final geom in geometries) {
      final type = (geom as Map<String, dynamic>)['type'];
      final arcsField = geom['arcs'];
      if (type == 'Polygon') {
        _collectRings(arcsField as List, arcs, polys);
      } else if (type == 'MultiPolygon') {
        for (final poly in arcsField as List) {
          _collectRings(poly as List, arcs, polys);
        }
      }
    }

    final world = TopojsonWorld(polys);
    _cached = world;
    return world;
  }

  static void _collectRings(List rings, List<List<LatLng>> arcs, List<List<LatLng>> out) {
    for (final ring in rings) {
      final points = <LatLng>[];
      for (final arcIdx in (ring as List)) {
        final idx = arcIdx as int;
        final arc = idx < 0 ? arcs[~idx].reversed.toList() : arcs[idx];
        // Erstes Element des folgenden Arcs überspringen, damit Duplikate am Join weg sind
        if (points.isNotEmpty && arc.isNotEmpty) {
          points.addAll(arc.skip(1));
        } else {
          points.addAll(arc);
        }
      }
      if (points.length >= 3) out.add(points);
    }
  }
}

/// Ein Punkt auf der Kugel in Grad.
class LatLng {
  final double lat;
  final double lng;
  const LatLng({required this.lat, required this.lng});
}

/// Orthographische Projektion eines Kugelpunkts auf die 2D-Scheibe.
/// [lambda] = Rotation um die Y-Achse (Longitude-Versatz), in Grad.
/// [phi] = Neigung der Polachse, in Grad.
/// Rückgabe: (x, y) im Bereich [-1, 1], und `visible` = true, wenn auf der
/// zum Betrachter zeigenden Hemisphäre.
({double x, double y, bool visible}) orthographic({
  required double lat,
  required double lng,
  required double lambda,
  required double phi,
}) {
  final latR = lat * math.pi / 180;
  final lngR = (lng - lambda) * math.pi / 180;
  final phiR = phi * math.pi / 180;

  final cosLat = math.cos(latR);
  final sinLat = math.sin(latR);
  final cosLng = math.cos(lngR);
  final sinLng = math.sin(lngR);
  final cosPhi = math.cos(phiR);
  final sinPhi = math.sin(phiR);

  // Standard orthographic projection (mit φ1 als Zentrum-Latitude)
  final cosC = sinPhi * sinLat + cosPhi * cosLat * cosLng;
  final visible = cosC > 0;

  final x = cosLat * sinLng;
  final y = cosPhi * sinLat - sinPhi * cosLat * cosLng;

  return (x: x, y: -y, visible: visible); // y nach oben → Bildschirm y nach unten
}
