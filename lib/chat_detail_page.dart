import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatDetailPage extends StatefulWidget {
  final String friendUid;
  final String friendName;
  final String friendImage;

  const ChatDetailPage({
    super.key,
    required this.friendUid,
    required this.friendName,
    required this.friendImage,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    chatRoomId = _getChatRoomId(_auth.currentUser!.uid, widget.friendUid);
    // Saat halaman dibuka, tandai pesan dari teman sebagai 'Sudah Dibaca'
    _markMessagesAsRead();
  }

  String _getChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) < 0) {
      return "${user1}_$user2";
    } else {
      return "${user2}_$user1";
    }
  }

  // --- LOGIKA BARU: Tandai pesan sudah dibaca ---
  Future<void> _markMessagesAsRead() async {
    try {
      // Ambil pesan yang dikirim oleh TEMAN dan statusnya belum dibaca
      var querySnapshot = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: widget.friendUid)
          .where('isRead', isEqualTo: false)
          .get();

      // Update satu per satu
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print("Gagal update status read: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    String msg = _messageController.text.trim();
    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
            'senderId': _auth.currentUser!.uid,
            'receiverId': widget.friendUid,
            'message': msg,
            'timestamp': FieldValue.serverTimestamp(),
            // --- LOGIKA BARU: Default belum dibaca ---
            'isRead': false,
          });
    } catch (e) {
      print("Gagal kirim pesan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.friendUid)
              .snapshots(),
          builder: (context, snapshot) {
            String displayName = widget.friendName;
            String displayImage = widget.friendImage;

            if (snapshot.hasData && snapshot.data!.exists) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              displayName = data['name'] ?? widget.friendName;
              displayImage = data['image'] ?? widget.friendImage;
            }

            ImageProvider imgProvider;
            if (displayImage.startsWith('assets')) {
              imgProvider = AssetImage(displayImage);
            } else if (displayImage.startsWith('http')) {
              imgProvider = NetworkImage(displayImage);
            } else {
              imgProvider = const AssetImage(
                'assets/images/profile_default.png',
              );
            }

            return Row(
              children: [
                CircleAvatar(backgroundImage: imgProvider, radius: 20),
                const SizedBox(width: 10),
                Text(displayName, style: const TextStyle(fontSize: 18)),
              ],
            );
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var data = messages[index].data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == _auth.currentUser!.uid;
                    return _buildMessageBubble(
                      data['message'],
                      isMe,
                      data['isRead'] ?? false,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Tulis pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, bool isRead) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? Colors.redAccent : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(15),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          // Indikator Read (Opsional, kecil di bawah pesan)
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 5),
              child: Icon(
                Icons.done_all,
                size: 16,
                color: isRead ? Colors.blue : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
