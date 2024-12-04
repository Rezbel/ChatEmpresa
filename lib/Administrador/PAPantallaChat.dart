import 'package:chatempresa/Administrador/ChatsAdmin/ChatsList.dart';
import 'package:chatempresa/Administrador/ChatsAdmin/PAGruposList.dart';
import 'package:chatempresa/Login/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PAPantallachat extends StatefulWidget {
  const PAPantallachat({super.key});

  @override
  State<PAPantallachat> createState() => _PAPantallachatState();
}

class _PAPantallachatState extends State<PAPantallachat> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool showChats = true;

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _openMeetingLink() async {
    const url = 'https://meet.google.com/landing';
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url));
    } else {
      print('No se puede abrir la URL xd');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'Bater Papo',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Cerrar sesión') {
                _signOut(context);
              } else if (value == 'Agendar reunión') {
                _openMeetingLink();
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Cerrar sesión',
                child: Text('Cerrar sesión'),
              ),
              const PopupMenuItem<String>(
                value: 'Agendar reunión',
                child: Text('Agendar reunión'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showChats = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showChats ? Colors.white : Colors.grey,
                  ),
                  child: const Text(
                    'Chats',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showChats = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showChats ? Colors.grey : Colors.white,
                  ),
                  child: const Text(
                    'Grupos',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: showChats
                ? PAChatsList(currentUser: currentUser)
                : PAGruposList(currentUserId: currentUser?.uid ?? ''),
          ),
        ],
      ),
    );
  }
}
