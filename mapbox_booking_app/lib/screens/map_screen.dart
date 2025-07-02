import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class MapScreen extends StatefulWidget {
  final String originName;
  final String destinationName;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;

  const MapScreen({
    super.key,
    required this.originName,
    required this.destinationName,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  List<Position> route = [];
  PolylineAnnotationManager? polylineManager;
  double _currentZoom = 10.0;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    try {
      final url =
          'https://api.mapbox.com/directions/v5/mapbox/driving/'
          '${widget.originLng},${widget.originLat};${widget.destinationLng},${widget.destinationLat}?geometries=geojson&access_token=$mapboxAccessToken';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          route =
              coords
                  .map<Position>(
                    (c) => Position(c[0] as double, c[1] as double),
                  )
                  .toList();
        });
        _addLine();
      } else {
        setState(() {
          route = [];
        });
        _addLine();
      }
    } catch (_) {
      setState(() {
        route = [];
      });
      _addLine();
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.getCameraState().then((state) {
      setState(() {
        _currentZoom = state.zoom;
      });
    });
    if (route.isNotEmpty) {
      _addLine();
    }
  }

  Future<void> _addLine() async {
    if (mapboxMap == null || route.isEmpty) return;
    polylineManager ??=
        await mapboxMap!.annotations.createPolylineAnnotationManager();
    await polylineManager!.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: route),
        lineColor: 0xFFAB47BC, // Purple 400 color as int
        lineWidth: 6.0,
      ),
    );
    await mapboxMap!.flyTo(
      CameraOptions(center: Point(coordinates: route.first), zoom: 12.0),
      MapAnimationOptions(duration: 2000, startDelay: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Ride')),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(widget.originLng, widget.originLat),
              ),
              zoom: _currentZoom,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 120,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_in),
                    onPressed: () {
                      setState(() {
                        _currentZoom += 1;
                      });
                      mapboxMap?.flyTo(
                        CameraOptions(zoom: _currentZoom),
                        MapAnimationOptions(duration: 500, startDelay: 0),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.zoom_out),
                    onPressed: () {
                      setState(() {
                        _currentZoom -= 1;
                      });
                      mapboxMap?.flyTo(
                        CameraOptions(zoom: _currentZoom),
                        MapAnimationOptions(duration: 500, startDelay: 0),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      _fetchRoute();
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white.withOpacity(0.95),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'From:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.originName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.orange),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'To:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.destinationName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
