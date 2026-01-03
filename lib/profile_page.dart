import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profil_page.dart';
import 'login_screen.dart';
import 'change_password_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil User yang sedang login
    final user = FirebaseAuth.instance.currentUser;

    // Jika entah kenapa user tidak ada (belum login), kembalikan ke login
    if (user == null) {
      return const Center(child: Text("Silakan login terlebih dahulu"));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // StreamBuilder memantau dokumen di koleksi 'users' milik UID ini
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Saat loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Jika error
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan memuat data."));
          }

          // 3. Jika data tidak ditemukan
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data profil tidak ditemukan."));
          }

          // 4. Ambil data dari snapshot
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                // === HEADER PROFILE ===
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 130,
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 60,
                          // Cek apakah gambar berupa Link Internet (http) atau Aset Lokal (assets/)
                          backgroundImage:
                              (userData['image'] != null &&
                                  userData['image'].toString().isNotEmpty)
                              ? (userData['image'].toString().startsWith('http')
                                    ? NetworkImage(userData['image'])
                                    : AssetImage(userData['image'])
                                          as ImageProvider)
                              : const AssetImage(
                                  'assets/images/profile_default.png',
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),

                // Nama & Status
                Text(
                  userData['name'] ?? "User",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userData['email'] ?? "-",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // === CARD DETAIL ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        _buildProfileItem(
                          Icons.email,
                          "Email",
                          userData['email'] ?? "-",
                        ),
                        const Divider(height: 1),
                        _buildProfileItem(
                          Icons.phone,
                          "Nomor HP",
                          userData['phone'] ?? "-",
                        ),
                        const Divider(height: 1),
                        _buildProfileItem(
                          Icons.location_on,
                          "Alamat",
                          userData['address'] ?? "-",
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- TOMBOL EDIT PROFIL ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      "Edit Profil",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // --- TOMBOL GANTI PASSWORD (BARU) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent, // Warna oranye
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_reset, color: Colors.white),
                    label: const Text(
                      "Ganti Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // --- TOMBOL LOGOUT ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      "Keluar",
                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
