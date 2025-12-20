import 'package:flutter/material.dart';
import 'home_map_page.dart';
import 'pesan_page.dart';
import 'riwayat_page.dart';
import 'profile_page.dart';

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

  // Fungsi untuk menampilkan dialog Tambah Teman
  void _showAddFriendDialog() {
    final TextEditingController friendEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Teman"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Masukkan alamat email teman yang sudah terdaftar di aplikasi ini.",
            ),
            const SizedBox(height: 10),
            TextField(
              controller: friendEmailController,
              decoration: const InputDecoration(
                labelText: "Email Teman",
                hintText: "contoh: teman@gmail.com",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_add),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              // Disini nanti logika cek database Firebase akan dipasang
              // Untuk sementara kita tampilkan notifikasi saja
              if (friendEmailController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Permintaan berteman dikirim ke ${friendEmailController.text}",
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Tambah", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      // Tombol Tambah Teman (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: Colors.redAccent,
        tooltip: 'Tambah Teman',
        shape: const CircleBorder(), // Agar bulat sempurna
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // Posisi di tengah dock

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Agar posisi item stabil
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Pesan"),
          // Kita beri jarak di tengah untuk Floating Action Button?
          // Tidak perlu Spacer khusus jika pakai type: fixed dan centerDocked,
          // FAB akan otomatis menumpuk (overlay) sedikit.
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
