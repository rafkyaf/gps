import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail_page.dart';

class PesanPage extends StatefulWidget {
  const PesanPage({super.key});

  @override
  State<PesanPage> createState() => _PesanPageState();
}

class _PesanPageState extends State<PesanPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Helper untuk ID Chatroom (Sama persis dengan di ChatDetailPage)
  String _getChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) < 0) {
      return "${user1}_$user2";
    } else {
      return "${user2}_$user1";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text("Silakan login terlebih dahulu"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pesan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1. STREAM DAFTAR TEMAN
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('friends')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Belum ada riwayat pesan.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var friendsList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: friendsList.length,
            itemBuilder: (context, index) {
              var friendRelationData =
                  friendsList[index].data() as Map<String, dynamic>;
              String friendUid = friendRelationData['uid'];
              String chatRoomId = _getChatRoomId(currentUser!.uid, friendUid);

              // 2. STREAM DATA PROFIL ASLI (Nama & Foto Terbaru)
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(friendUid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  String name = friendRelationData['name'] ?? "Teman";
                  String image =
                      friendRelationData['image'] ??
                      'assets/images/profile_default.png';

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    var realUserData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    name = realUserData['name'] ?? name;
                    image = realUserData['image'] ?? image;
                  }

                  ImageProvider imgProvider;
                  if (image.startsWith('assets')) {
                    imgProvider = AssetImage(image);
                  } else if (image.startsWith('http')) {
                    imgProvider = NetworkImage(image);
                  } else {
                    imgProvider = const AssetImage(
                      'assets/images/profile_default.png',
                    );
                  }

                  // 3. STREAM PESAN (Untuk Last Message & Unread Count)
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chat_rooms')
                        .doc(chatRoomId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      String lastMessage = "Mulai obrolan baru";
                      String time = "";
                      int unreadCount = 0;
                      bool isLastMessageByMe = false;

                      if (messageSnapshot.hasData &&
                          messageSnapshot.data!.docs.isNotEmpty) {
                        var allMessages = messageSnapshot.data!.docs;
                        var lastDoc = allMessages.first; // Pesan paling baru
                        var lastData = lastDoc.data() as Map<String, dynamic>;

                        lastMessage = lastData['message'];
                        isLastMessageByMe =
                            lastData['senderId'] == currentUser!.uid;

                        // Hitung pesan yang belum dibaca (yang dikirim ke SAYA dan isRead false)
                        unreadCount = allMessages.where((doc) {
                          var d = doc.data() as Map<String, dynamic>;
                          return d['receiverId'] == currentUser!.uid &&
                              d['isRead'] == false;
                        }).length;

                        // Ambil waktu (Optional, jika ingin menampilkan jam)
                        // Timestamp ts = lastData['timestamp'] ?? Timestamp.now();
                        // DateTime dt = ts.toDate();
                        // time = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: imgProvider,
                            ),
                            // Indikator Online (Opsional, dihardcode dulu)
                            // Positioned(right: 0, bottom: 0, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))))
                          ],
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          isLastMessageByMe
                              ? "Anda: $lastMessage"
                              : lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unreadCount > 0
                                ? Colors.black87
                                : Colors
                                      .grey, // Jika ada pesan baru, teks lebih gelap
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Jam (Jika mau ditampilkan)
                            // Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
                            // SizedBox(height: 5),

                            // BADGE NOTIFIKASI
                            if (unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                friendUid: friendUid,
                                friendName: name,
                                friendImage: image,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
