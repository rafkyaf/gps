import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key});

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

// 1. TAMBAHKAN: 'with AutomaticKeepAliveClientMixin'
class _HomeMapPageState extends State<HomeMapPage>
    with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();

  // Posisi HP Kita (User)
  LatLng? _userPosition;

  // Posisi Alat (Hardware) dari Firebase
  LatLng? _devicePosition;
  double _deviceSpeed = 0.0;

  // Status: Apakah kamera harus ngikutin target otomatis?
  bool _isAutoFollowing = true;

  // 2. TAMBAHKAN: Override ini menjadi true (Wajib)
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _startUserTracking();
    _listenToDeviceData();
  }

  void _startUserTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _userPosition = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  void _listenToDeviceData() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('lokasi');

    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        double lat = (data['lat'] is int)
            ? (data['lat'] as int).toDouble()
            : (data['lat'] as double);

        double lng = (data['lng'] is int)
            ? (data['lng'] as int).toDouble()
            : (data['lng'] as double);

        double speed = 0;
        if (data['speed'] != null) {
          speed = (data['speed'] is int)
              ? (data['speed'] as int).toDouble()
              : (data['speed'] as double);
        }

        if (mounted) {
          setState(() {
            _devicePosition = LatLng(lat, lng);
            _deviceSpeed = speed;
          });

          // MODIFIKASI: Hanya pindahkan kamera jika Mode Auto Follow aktif
          if (_isAutoFollowing) {
            _mapController.move(_devicePosition!, 15.0);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 3. TAMBAHKAN: Panggil super.build agar halaman tetap hidup
    super.build(context);

    LatLng centerMap =
        _devicePosition ?? _userPosition ?? const LatLng(-7.7956, 110.3695);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. PETA UTAMA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centerMap,
              initialZoom: 15.0,
              // TAMBAHKAN: Deteksi jari user
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  // Kalau user geser peta pakai jari, matikan fitur "Auto Follow"
                  setState(() => _isAutoFollowing = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gps_tracker',
              ),

              MarkerLayer(
                markers: [
                  // MARKER 1: Posisi HP Kita (Titik Biru Kecil)
                  if (_userPosition != null)
                    Marker(
                      point: _userPosition!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(blurRadius: 5, color: Colors.black26),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                  // MARKER 2: Posisi ALAT TRACKER (Pin Merah Besar)
                  if (_devicePosition != null)
                    Marker(
                      point: _devicePosition!,
                      width: 80,
                      height: 80,
                      child: const Column(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 50),
                          Text(
                            "TARGET",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // TOMBOL RE-CENTER (Muncul kalau user sudah geser peta)
          if (!_isAutoFollowing)
            Positioned(
              bottom: 150,
              right: 20,
              child: FloatingActionButton.small(
                backgroundColor: Colors.red,
                child: const Icon(Icons.gps_fixed, color: Colors.white),
                onPressed: () {
                  // Aktifkan lagi Auto Follow
                  setState(() => _isAutoFollowing = true);
                  if (_devicePosition != null) {
                    _mapController.move(_devicePosition!, 15.0);
                  }
                },
              ),
            ),

          // 2. PANEL INFO DI BAWAH
          if (_devicePosition != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Status Alat",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Kecepatan: ${_deviceSpeed.toStringAsFixed(1)} km/j",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Lat: ${_devicePosition!.latitude.toStringAsFixed(5)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          "Lng: ${_devicePosition!.longitude.toStringAsFixed(5)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const Icon(Icons.person, size: 40, color: Colors.redAccent),
                  ],
                ),
              ),
            ),

          // Indikator Loading
          if (_devicePosition == null)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Chip(
                  label: Text("Menunggu sinyal alat..."),
                  backgroundColor: Colors.white,
                  avatar: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
