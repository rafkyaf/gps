import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:permission_handler/permission_handler.dart'; // Import Permission Handler
import 'home_map_page.dart';
import 'pesan_page.dart';
import 'riwayat_page.dart';
import 'profile_page.dart';
import 'search_friend_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeMapPage(),
    const PesanPage(),
    const RiwayatPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Panggil fungsi cek lokasi tepat saat halaman ini dimuat pertama kali
    _checkAndRequestLocation();
  }

  // --- LOGIKA BARU: Request Lokasi Otomatis ---
  Future<void> _checkAndRequestLocation() async {
    // 1. Cek apakah GPS (Hardware) aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Jika mati, minta user menyalakan (biasanya muncul pop-up sistem)
      // Kalau user menolak, kita bisa tampilkan snackbar peringatan
      bool opened = await Geolocator.openLocationSettings();
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Mohon aktifkan GPS untuk menggunakan fitur tracking.",
            ),
          ),
        );
      }
    }

    // 2. Cek Izin Aplikasi (Permission)
    var status = await Permission.location.status;
    if (status.isDenied) {
      // Jika belum diizinkan, minta izin
      await Permission.location.request();
    }

    // Opsional: Jika ditolak permanen (user pilih "Don't ask again")
    if (await Permission.location.isPermanentlyDenied) {
      if (mounted) {
        openAppSettings(); // Buka settingan aplikasi
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      // Tombol Tambah Teman (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchFriendPage()),
          );
        },
        backgroundColor: Colors.redAccent,
        tooltip: 'Cari Teman',
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Pesan"),
          // Jarak di tengah untuk FAB
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
