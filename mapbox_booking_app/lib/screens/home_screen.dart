import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'map_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _fromNameController = TextEditingController();
  final TextEditingController _toNameController = TextEditingController();
  Map<String, dynamic>? _fromFeature;
  Map<String, dynamic>? _toFeature;
  bool _loadingFrom = false;
  bool _loadingTo = false;
  String? _fromError;
  String? _toError;

  Future<void> _resolveLocation(String name, bool isFrom) async {
    setState(() {
      if (isFrom) {
        _loadingFrom = true;
        _fromError = null;
      } else {
        _loadingTo = true;
        _toError = null;
      }
    });
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/' +
        Uri.encodeComponent(name) +
        '.json?access_token=$mapboxAccessToken&autocomplete=true&country=TZ&limit=1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['features'] is List && (data['features'] as List).isNotEmpty) {
          final feature =
              (data['features'] as List).first as Map<String, dynamic>;
          setState(() {
            if (isFrom) {
              _fromFeature = feature;
            } else {
              _toFeature = feature;
            }
          });
        } else {
          setState(() {
            if (isFrom) {
              _fromFeature = null;
              _fromError = 'No location found';
            } else {
              _toFeature = null;
              _toError = 'No location found';
            }
          });
        }
      } else {
        setState(() {
          if (isFrom) {
            _fromFeature = null;
            _fromError = 'Error: ${response.statusCode}';
          } else {
            _toFeature = null;
            _toError = 'Error: ${response.statusCode}';
          }
        });
      }
    } catch (e) {
      setState(() {
        if (isFrom) {
          _fromFeature = null;
          _fromError = 'Error: $e';
        } else {
          _toFeature = null;
          _toError = 'Error: $e';
        }
      });
    } finally {
      setState(() {
        if (isFrom) {
          _loadingFrom = false;
        } else {
          _loadingTo = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Locations')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('From:'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fromNameController,
                    decoration: InputDecoration(
                      labelText: 'From location name',
                      errorText: _fromError,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _resolveLocation(value.trim(), true);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _loadingFrom
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        final value = _fromNameController.text.trim();
                        if (value.isNotEmpty) {
                          _resolveLocation(value, true);
                        }
                      },
                    ),
              ],
            ),
            if (_fromFeature != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  _fromFeature!['place_name'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            const SizedBox(height: 16),
            const Text('To:'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toNameController,
                    decoration: InputDecoration(
                      labelText: 'To location name',
                      errorText: _toError,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _resolveLocation(value.trim(), false);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _loadingTo
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        final value = _toNameController.text.trim();
                        if (value.isNotEmpty) {
                          _resolveLocation(value, false);
                        }
                      },
                    ),
              ],
            ),
            if (_toFeature != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  _toFeature!['place_name'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  (_fromFeature != null && _toFeature != null)
                      ? () {
                        final fromCoords =
                            _fromFeature!['geometry']['coordinates'];
                        final toCoords = _toFeature!['geometry']['coordinates'];
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => MapScreen(
                                  originName: _fromFeature!['place_name'],
                                  destinationName: _toFeature!['place_name'],
                                  originLat: fromCoords[1],
                                  originLng: fromCoords[0],
                                  destinationLat: toCoords[1],
                                  destinationLng: toCoords[0],
                                ),
                          ),
                        );
                      }
                      : null,
              child: const Text('Track Ride'),
            ),
          ],
        ),
      ),
    );
  }
}
