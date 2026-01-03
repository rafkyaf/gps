import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchFriendPage extends StatefulWidget {
  const SearchFriendPage({super.key});

  @override
  State<SearchFriendPage> createState() => _SearchFriendPageState();
}

class _SearchFriendPageState extends State<SearchFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  User? currentUser = FirebaseAuth.instance.currentUser;

  // --- LOGIKA 1: KIRIM REQUEST (Dipanggil saat klik tombol "Tambah") ---
  Future<void> _sendFriendRequest(String targetUid) async {
    if (currentUser == null) return;

    try {
      // 1. Ambil data diri sendiri dulu untuk dikirim ke teman
      DocumentSnapshot myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      var myData = myDoc.data() as Map<String, dynamic>;

      // 2. Tulis ke database teman: users -> [UID TEMAN] -> friend_requests -> [UID KITA]
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('friend_requests')
          .doc(currentUser!.uid)
          .set({
            'uid': currentUser!.uid,
            'name': myData['name'],
            'email': myData['email'],
            'image': myData['image'] ?? 'assets/images/profile_default.png',
            'timestamp': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permintaan pertemanan terkirim!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengirim: $e")));
    }
  }

  // --- LOGIKA 2: TERIMA TEMAN ---
  Future<void> _acceptFriend(
    String senderUid,
    String senderName,
    String senderImage,
  ) async {
    try {
      // 1. Tambahkan dia ke daftar teman SAYA
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('friends')
          .doc(senderUid)
          .set({
            'uid': senderUid,
            'name': senderName,
            'image': senderImage,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 2. Tambahkan SAYA ke daftar teman DIA (Timbal balik)
      // Ambil data saya lagi
      DocumentSnapshot myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      var myData = myDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(senderUid)
          .collection('friends')
          .doc(currentUser!.uid)
          .set({
            'uid': currentUser!.uid,
            'name': myData['name'],
            'image': myData['image'] ?? 'assets/images/profile_default.png',
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 3. Hapus permintaan dari database
      await _rejectFriend(senderUid); // Hapus doc request

      if (mounted) {
        Navigator.pop(context); // Tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Anda sekarang berteman dengan $senderName")),
        );
      }
    } catch (e) {
      print("Error accepting friend: $e");
    }
  }

  // --- LOGIKA 3: TOLAK TEMAN (Hapus Request) ---
  Future<void> _rejectFriend(String senderUid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('friend_requests')
        .doc(senderUid)
        .delete();
  }

  // --- TAMPILAN POP-UP NOTIFIKASI ---
  void _showFriendRequests() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Permintaan Pertemanan"),
          content: SizedBox(
            width: double.maxFinite,
            // StreamBuilder mendengarkan koleksi 'friend_requests' secara real-time
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('friend_requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Tidak ada permintaan baru.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    // Cek Gambar (Asset atau Network)
                    ImageProvider imgProvider;
                    if (data['image'] != null &&
                        data['image'].toString().startsWith('assets')) {
                      imgProvider = AssetImage(data['image']);
                    } else if (data['image'] != null &&
                        data['image'].toString().startsWith('http')) {
                      imgProvider = NetworkImage(data['image']);
                    } else {
                      imgProvider = const AssetImage(
                        'assets/images/profile_default.png',
                      );
                    }

                    return ListTile(
                      leading: CircleAvatar(backgroundImage: imgProvider),
                      title: Text(data['name'] ?? "User"),
                      subtitle: Text(data['email'] ?? ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol Terima
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () => _acceptFriend(
                              data['uid'],
                              data['name'],
                              data['image'],
                            ),
                          ),
                          // Tombol Tolak
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _rejectFriend(data['uid']),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Teman"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // IKON NOTIFIKASI DENGAN STREAM
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .collection('friend_requests')
                .snapshots(),
            builder: (context, snapshot) {
              bool hasNotif =
                  snapshot.hasData && snapshot.data!.docs.isNotEmpty;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 28),
                    onPressed: _showFriendRequests,
                  ),
                  if (hasNotif)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 10,
                          minHeight: 10,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Email atau Nama...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
            ),
          ),

          // LIST PENCARIAN
          Expanded(
            child: _searchQuery.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "Ketik nama atau email teman",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _searchUsersStream(_searchQuery),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text("Terjadi kesalahan."));
                      }

                      var docs = snapshot.data!.docs;
                      // Filter agar tidak mencari diri sendiri
                      var users = docs
                          .where((doc) => doc['uid'] != currentUser?.uid)
                          .toList();

                      if (users.isEmpty) {
                        return const Center(
                          child: Text("Pengguna tidak ditemukan."),
                        );
                      }

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          var data =
                              users[index].data() as Map<String, dynamic>;

                          // Handle Gambar
                          ImageProvider imageProvider;
                          if (data['image'] != null &&
                              data['image'].toString().startsWith('assets')) {
                            imageProvider = AssetImage(data['image']);
                          } else if (data['image'] != null &&
                              data['image'].toString().startsWith('http')) {
                            imageProvider = NetworkImage(data['image']);
                          } else {
                            imageProvider = const AssetImage(
                              'assets/images/profile_default.png',
                            );
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: imageProvider,
                            ),
                            title: Text(data['name'] ?? "Tanpa Nama"),
                            subtitle: Text(data['email'] ?? ""),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                // Panggil fungsi kirim request
                                _sendFriendRequest(data['uid']);
                              },
                              child: const Text(
                                "Tambah",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _searchUsersStream(String query) {
    if (query.contains('@')) {
      return FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: query)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .snapshots();
    }
  }
}
