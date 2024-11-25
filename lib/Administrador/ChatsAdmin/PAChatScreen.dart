import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

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
  File? _selectedFile;

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
    if (message.isEmpty && _selectedFile == null) return;

    String chatId = getChatId();

    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'senderId': widget.currentUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String chatId = getChatId();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 8),
            Text('$otherUserName'),
          ],
        ),
        backgroundColor: Color(0xFF6B6B6B),
      ),
      backgroundColor: Color(0xFF282828),
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
                          color: isSentByCurrentUser ? Color(0xFF6B6B6B) : Color(0xFFE6EFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message['message'] != null && message['message'].isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  final text = message['message'];
                                  if (text.contains('.com')) {
                                    final url = 'https://${text.trim()}';
                                    launch(url);
                                  }
                                },
                                child: Text(
                                  message['message'] ?? '',
                                  style: TextStyle(color: Colors.black, decoration: message['message'].contains('.com') ? TextDecoration.underline : TextDecoration.none),
                                ),
                              ),
                          ],
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
                    maxLines: 5,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...', hintStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Color(0xFFE6EFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.attach_file, color: Colors.black),
                            onPressed: () {
                              // Placeholder: button does not perform any action for now
                            },
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
