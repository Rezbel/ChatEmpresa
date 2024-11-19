import 'package:chatempresa/Administrador/PAChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsList extends StatelessWidget {
  final User? currentUser;

  ChatsList({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var users = snapshot.data!.docs.where((user) {
                  return user.id != currentUser!.uid;
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user['username'],
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        subtitle: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('chats')
                              .doc(getChatId(currentUser!.uid, user.id))
                              .collection('messages')
                              .orderBy('timestamp', descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context, chatSnapshot) {
                            if (!chatSnapshot.hasData ||
                                chatSnapshot.data!.docs.isEmpty) {
                              return const Text(
                                'No hay mensajes',
                                style: TextStyle(color: Colors.black54),
                              );
                            }
                            var lastMessage = chatSnapshot.data!.docs.first;
                            String messageText =
                                lastMessage['message'] ?? 'Mensaje vacío';
                            return Text(
                              messageText,
                              style: const TextStyle(color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        trailing: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('chats')
                              .doc(getChatId(currentUser!.uid, user.id))
                              .collection('messages')
                              .orderBy('timestamp', descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context, chatSnapshot) {
                            if (!chatSnapshot.hasData ||
                                chatSnapshot.data!.docs.isEmpty) {
                              return const Text(
                                'Sin mensajes',
                                style: TextStyle(color: Colors.black54),
                              );
                            }
                            var lastMessage = chatSnapshot.data!.docs.first;

                            // Verificar si 'timestamp' existe y no es null usando el operador ?.
                            var timestamp =
                                lastMessage['timestamp'] as Timestamp?;
                            if (timestamp != null) {
                              var date = timestamp.toDate();
                              return Text(
                                '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: Colors.black54),
                              );
                            }
                            return const Text(
                              'Hora no disponible',
                              style: TextStyle(color: Colors.black54),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PAChatScreen(
                                currentUserId: currentUser!.uid,
                                otherUserId: user.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
  }
}
String getChatId(String currentUserId, String otherUserId) {
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    return ids.join('_');
  }