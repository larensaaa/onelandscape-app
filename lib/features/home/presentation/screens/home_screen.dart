import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/tematik_menu_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 220,
        // backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
          child: SafeArea(
            top: true,
            bottom: false,
            left: false,
            right: false,
            child: Image.asset(
              'assets/images/onemap.png', 
              fit: BoxFit.cover, 
            ),
          ),
        ),
        
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, title: 'Peta', actionText: 'Tampilan Penuh'),
              const SizedBox(height: 2),
              _buildMapPreview(),
              const SizedBox(height: 5),
              _buildSectionHeader(context, title: 'Tematik', actionText: 'Semua Menu'),
              const SizedBox(height: 5),
              const TematikMenuGrid(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required String actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            if (title == 'Peta') {
              context.go('/map-full');
            }
          },
          child: Text(
            actionText,
            style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      elevation: 4,
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(-3.317, 114.590),
            initialZoom: 9.0,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.onelandscape',
            ),
          ],
        ),
      ),
    );
  }
}