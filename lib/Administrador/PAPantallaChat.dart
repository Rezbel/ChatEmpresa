import 'package:chatempresa/modelo/PAChatsList.dart';
import 'package:chatempresa/modelo/PAGruposList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PAPantallachat extends StatefulWidget {
  const PAPantallachat({super.key});

  @override
  State<PAPantallachat> createState() => _PAPantallachatState();
}

class _PAPantallachatState extends State<PAPantallachat> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool showChats = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
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
