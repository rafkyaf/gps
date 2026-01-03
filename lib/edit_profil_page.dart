import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;

  // Daftar Pilihan Avatar (Pastikan path ini sesuai dengan pubspec.yaml)
  final List<String> _avatarOptions = [
    'assets/images/profile_default.jpg',
    'assets/images/avatar_man1.jpg',
    'assets/images/avatar_woman1.jpg',
    'assets/images/avatar_man2.jpg',
    'assets/images/avatar_woman2.jpg',
    'assets/images/avatar_man3.jpg',
    'assets/images/avatar_woman3.jpg',
  ];

  String _selectedAvatar =
      'assets/images/profile_default.jpg'; // Default pilihan

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    setState(() => _isLoading = true);

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';

        setState(() {
          // Jika ada data gambar di DB, pakai itu. Jika tidak, pakai default.
          if (data['image'] != null && _avatarOptions.contains(data['image'])) {
            _selectedAvatar = data['image'];
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || user == null) return;
    setState(() => _isLoading = true);

    try {
      // Simpan path asset (string) ke Firestore, bukan URL download
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'image': _selectedAvatar, // Simpan path lokal yang dipilih
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Pilih Avatar Anda:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // Pilihan Avatar (Horizontal List)
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _avatarOptions.length,
                        itemBuilder: (context, index) {
                          final avatarPath = _avatarOptions[index];
                          final isSelected = _selectedAvatar == avatarPath;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatar = avatarPath;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.redAccent,
                                        width: 3,
                                      )
                                    : null,
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: AssetImage(avatarPath),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Form Input
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Nama Lengkap",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Nomor HP",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "Alamat",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: _saveProfile,
                        child: const Text(
                          "SIMPAN",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
