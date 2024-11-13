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
        .collection('usuarios')
        .doc(widget.currentUserId)
        .get();
    DocumentSnapshot otherUserSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.otherUserId)
        .get();

    setState(() {
      currentUserName = currentUserSnapshot['nombre'];
      otherUserName = otherUserSnapshot['nombre'];
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
    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('mensajes').add({
      'remitente': currentUserName, // Usar el nombre en lugar del ID
      'menaje': message,
      'FechaHora': FieldValue.serverTimestamp(),
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
                      .collection('mensajes')
                      .orderBy('FechaHora', descending: true)
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
                    bool isSentByCurrentUser = message['remitente'] == currentUserName;
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
                          '${message['mensaje']}', // Mostrar el nombre del remitente
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
