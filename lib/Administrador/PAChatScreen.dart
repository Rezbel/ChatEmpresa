import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PAChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const PAChatScreen({
    Key? key,
    required this.currentUserId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  State<PAChatScreen> createState() => _PAChatScreenState();
}

class _PAChatScreenState extends State<PAChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? currentUserName;
  String? otherUserName;

  @override
  void initState() {
    super.initState();
    _getUserNames();
  }

  Future<void> _getUserNames() async {
    DocumentSnapshot currentUserSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.currentUserId)
        .get();
    DocumentSnapshot otherUserSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.otherUserId)
        .get();

    setState(() {
      currentUserName = currentUserSnapshot['username'];
      otherUserName = otherUserSnapshot['username'];
    });
  }

  String getChatId() {
    if (widget.currentUserId.isEmpty || widget.otherUserId.isEmpty) return '';
    List<String> ids = [widget.currentUserId, widget.otherUserId];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    String chatId = getChatId();
    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'senderId': widget.currentUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    String chatId = getChatId();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con $otherUserName'),
        backgroundColor: Color(0xFF282828),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatId.isNotEmpty
                  ? FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isSentByCurrentUser = message['senderId'] == widget.currentUserId;
                    return Align(
                      alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByCurrentUser ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['message'] ?? 'Mensaje vacío',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      sendMessage(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
