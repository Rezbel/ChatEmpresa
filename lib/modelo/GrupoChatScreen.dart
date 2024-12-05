import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GrupoChatScreen extends StatefulWidget {
  final String groupId; // El ID del grupo para identificarlo
  final String groupName;

  const GrupoChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  _GrupoChatScreenState createState() => _GrupoChatScreenState();
}

class _GrupoChatScreenState extends State<GrupoChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.group, color: Colors.white),
            const SizedBox(width: 8),
            Text(widget.groupName),
          ],
        ),
        backgroundColor: const Color(0xFF6B6B6B),
      ),
      backgroundColor: const Color(0xFF282828),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('grupos')
                  .doc(widget.groupId)
                  .collection('mensajes')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Mostrar mensajes nuevos al final
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == _currentUser?.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Column(
                                children: [
                                  Icon(Icons.person, color: Colors.black),
                                ],
                              ),
                            ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFF6B6B6B)
                                  : const Color(0xFFE6EFFF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ), // Limitar el ancho de los mensajes
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Text(
                                    data['senderName'] ?? 'Usuario',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.grey[700],
                                    ),
                                  ),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () {
                                    final text = data['message'];
                                    if (text.contains('.com')) {
                                      final url = '${text.trim()}';
                                      launch(url);
                                    }
                                  },
                                  child: Text(
                                    data['message'] ?? '',
                                    style: TextStyle(
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                        decoration:
                                            data['message'].contains('.com')
                                                ? TextDecoration.underline
                                                : TextDecoration.none),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: 5,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: const Color(0xFFE6EFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file,
                                color: Colors.black),
                            onPressed: () {
                              // Placeholder: button does not perform any action for now
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.black),
                            onPressed: () {
                              if (_messageController.text.trim().isNotEmpty) {
                                _sendMessage(_messageController.text.trim());
                                _messageController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) async {
    if (_currentUser == null) return;

    // Cargar datos del usuario actual desde Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_currentUser.uid)
        .get();

    if (!userDoc.exists) {
      print("Usuario no encontrado en Firestore");
      return;
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final senderName = userData['username'] ?? 'Usuario';

    final messageData = {
      'message': message,
      'senderId': _currentUser.uid,
      'senderName': senderName, // Ahora usa el username desde Firestore
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Guardar el mensaje en la colección 'mensajes'
    await FirebaseFirestore.instance
        .collection('grupos')
        .doc(widget.groupId)
        .collection('mensajes')
        .add(messageData);
  }
}
