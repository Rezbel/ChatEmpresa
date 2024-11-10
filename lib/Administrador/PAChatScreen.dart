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
    // Consultar los nombres de ambos usuarios desde la colección `users`
    DocumentSnapshot currentUserSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();
    DocumentSnapshot otherUserSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .get();

    setState(() {
      currentUserName = currentUserSnapshot['name'];
      otherUserName = otherUserSnapshot['name'];
    });
  }

  String getChatId() {
    // Asegurarse de que ambos nombres estén disponibles antes de generar el chatId
    if (currentUserName == null || otherUserName == null) return '';
    
    List<String> names = [currentUserName!, otherUserName!];
    names.sort();
    return names.join("_"); // chatId basado en los nombres
  }

  Future<void> sendMessage(String message) async {
    if (currentUserName == null) return; // Esperar a que el nombre esté disponible

    String chatId = getChatId();
    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'sender': currentUserName, // Usar el nombre en lugar del ID
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    String chatId = getChatId();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 10),
            Text(otherUserName ?? '',
            style: TextStyle(color: Colors.white),),
          ],
        ),
        backgroundColor: Color(0xFF6B6B6B),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Color(0xFF282828), // Nuevo fondo para el contenedor de mensajes
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
                      bool isSentByCurrentUser = message['sender'] == currentUserName;
                      return Row(
                        mainAxisAlignment: isSentByCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isSentByCurrentUser)
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSentByCurrentUser ? Color(0xFF6B6B6B) : Color(0xFFE6EFFF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${message['message']}',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          if (isSentByCurrentUser)
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.black),
                  onPressed: () {
                    // Aquí puedes añadir la lógica para adjuntar archivos
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: Color(0xFFE6EFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.black),
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
