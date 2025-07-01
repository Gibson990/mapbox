import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Ride'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SVG logo placeholder
            Center(
              child: SvgPicture.network(
                'https://upload.wikimedia.org/wikipedia/commons/8/84/Example.svg',
                height: 80,
                width: 80,
                placeholderBuilder:
                    (context) => const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFFF9800),
                    ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'From',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'To',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_fromController.text.isEmpty || _toController.text.isEmpty) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MapScreen(
                      origin: _fromController.text,
                      destination: _toController.text,
                    ),
                  ),
                );
              },
              child: const Text('Select Ride'),
            ),
          ],
        ),
      ),
    );
  }
}
