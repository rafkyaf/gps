import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Package wajib untuk koordinat OSM

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key});

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  // Koordinat default (Yogyakarta)
  final LatLng _center = const LatLng(-7.7829, 110.3671);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lokasi Langsung (OSM)"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Container Peta
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    // Pusatkan peta di awal
                    initialCenter: _center, 
                    initialZoom: 15.0,
                  ),
                  children: [
                    // LAYER 1: Peta Dasar (OpenStreetMap)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.gps_tracker',
                    ),
                    
                    // LAYER 2: Marker (Pin Merah)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _center,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on, 
                            color: Colors.red, 
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tombol Aksi
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Nanti kita isi logika "Cek Lokasi Saya" di sini
              },
              icon: const Icon(Icons.my_location, color: Colors.white),
              label: const Text("Lokasi Saya", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}