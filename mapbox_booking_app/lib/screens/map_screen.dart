import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class MapScreen extends StatefulWidget {
  final String origin;
  final String destination;

  const MapScreen({super.key, required this.origin, required this.destination});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMapController? mapController;
  List<LatLng> route = [];

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    try {
      final originGeo = await _geocode(widget.origin);
      final destGeo = await _geocode(widget.destination);
      if (originGeo == null || destGeo == null) return;
      final url =
          'https://api.mapbox.com/directions/v5/mapbox/driving/${originGeo.longitude},${originGeo.latitude};${destGeo.longitude},${destGeo.latitude}?geometries=geojson&access_token=$mapboxAccessToken';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          route = coords
              .map((c) => LatLng(c[1] as double, c[0] as double))
              .toList();
        });
        _addLine();
      }
    } catch (_) {}
  }

  Future<LatLng?> _geocode(String query) async {
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json?access_token=$mapboxAccessToken&limit=1';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final features = data['features'] as List;
      if (features.isNotEmpty) {
        final coords = features[0]['center'];
        return LatLng(coords[1], coords[0]);
      }
    }
    return null;
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    if (route.isNotEmpty) {
      _addLine();
    }
  }

  void _addLine() {
    if (mapController == null || route.isEmpty) return;
    mapController!.addLine(LineOptions(
      geometry: route,
      lineColor: '#ff9800',
      lineWidth: 5,
    ));
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: route.first, northeast: route.last),
      left: 40,
      top: 40,
      right: 40,
      bottom: 40,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route')),
      body: MapboxMap(
        accessToken: mapboxAccessToken,
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
      ),
    );
  }
}
