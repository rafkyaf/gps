import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameC = TextEditingController(text: "Rafky A.");
  final TextEditingController emailC = TextEditingController(text: "user@gmail.com");
  final TextEditingController phoneC = TextEditingController(text: "+62 812 3456 7890");
  final TextEditingController addressC = TextEditingController(text: "Sleman, Yogyakarta");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: "Nama Lengkap"),
            ),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phoneC,
              decoration: const InputDecoration(labelText: "Nomor HP"),
            ),
            TextField(
              controller: addressC,
              decoration: const InputDecoration(labelText: "Alamat"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // TODO: Simpan data ke database, shared preferences, atau firebase
                Navigator.pop(context); // kembali ke halaman profil
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
