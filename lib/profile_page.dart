import 'package:flutter/material.dart';
// ignore: unused_import
import 'edit_profil_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengguna"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage('assets/images/profile_default.png'),
            ),
          ),
          const SizedBox(height: 20),

          // Nama
          const Text(
            "Nama Lengkap",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Text(
            "Rafky A.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 30),

          // Email
          const Text(
            "Email",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Text("user@gmail.com", style: TextStyle(fontSize: 16)),
          const Divider(height: 30),

          // Nomor HP
          const Text(
            "Nomor HP",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Text("+62 812 3456 7890", style: TextStyle(fontSize: 16)),
          const Divider(height: 30),

          // Alamat
          const Text(
            "Alamat",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Text("Sleman, Yogyakarta", style: TextStyle(fontSize: 16)),
          const Divider(height: 30),

          // Tombol Edit Profil
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
            child: const Text(
              "Edit Profil",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
