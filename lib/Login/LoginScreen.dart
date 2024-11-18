import 'package:chatempresa/Administrador/PABottomNavigation.dart';
import 'package:chatempresa/Empleado/BottomNavigation.dart';
import 'package:chatempresa/Login/PantallaRegistro.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _isLoading = false;
  bool _seeText = true;

  Future<void> _login() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Iniciar sesión con Firebase Authentication
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _correoController.text,
      password: _contrasenaController.text,
    );

    User? user= userCredential.user;

    // Obtener el correo del usuario autenticado
    String correo = _correoController.text;

    // Buscar el usuario por correo electrónico en Firestore
    final QuerySnapshot userQuery = await _firestore
        .collection('usuarios')
        .where('email', isEqualTo: correo)
        .limit(1) // Limitar la consulta a un solo documento
        .get();

    if (userQuery.docs.isNotEmpty) {
      final userDoc = userQuery.docs.first;
      final role = userDoc['role'];

      // Navegar a la pantalla correspondiente según el rol
      if (mounted) {
        if (role == 'administrador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PABottomnavigation()),
          );
        } else if (role == 'empleado') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Bottomnavigation()),
          );
        }
      }
    } else {
      // El usuario no tiene un rol asignado o no existe en Firestore
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Usuario no encontrado en Firestore."),
      ));
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    switch (e.code) {
      case 'invalid-email':
        errorMessage = 'El correo electrónico no es válido.';
        break;
      case 'user-disabled':
        errorMessage = 'El usuario ha sido deshabilitado.';
        break;
      case 'user-not-found':
        errorMessage = 'No se encontró al usuario con ese correo.';
        break;
      case 'wrong-password':
        errorMessage = 'La contraseña es incorrecta.';
        break;
      default:
        errorMessage = 'Algo salió mal';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage),
    ));
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282828),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Ruta de la imagen
                width: 325,
                height: 325,
              ),
              SizedBox(height: 20),
              Text(
                'BATER PAPO',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              
              // Formulario de inicio de sesión
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _correoController,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    TextField(
                      controller: _contrasenaController,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        suffix: IconButton(
                          icon: Icon(
                            _seeText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _seeText = !_seeText;
                            });
                          },
                        ),
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                        ),
                      ),
                      obscureText: _seeText,
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Acción para recuperar contraseña
                      },
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Iniciar sesión', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PantallaRegistro()),
                  );
                },
                child: Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
