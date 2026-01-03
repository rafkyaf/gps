import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      // Tombol Tambah Teman (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        // LOGIKA BARU: Pindah ke halaman SearchFriendPage saat ditekan
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchFriendPage()),
          );
        },
        backgroundColor: Colors.redAccent,
        tooltip: 'Cari Teman',
        shape: const CircleBorder(), // Agar bulat sempurna
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Agar posisi item stabil
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Teman"),
          // Jarak di tengah untuk Floating Action Button
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
