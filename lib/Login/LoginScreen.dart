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
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _isLoading = false;
  bool _seeText = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Buscar el usuario en Firestore por correo
      final QuerySnapshot result = await _firestore
          .collection('usuarios')
          .where('usuario', isEqualTo: _usuarioController.text)
          .get();

      if (result.docs.isNotEmpty) {
        final DocumentSnapshot userDoc = result.docs.first;
        final role = userDoc['rol'];

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
        print("Usuario no encontrado en Firestore.");
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
      print('Error al iniciar sesión: $e');
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
                      controller: _usuarioController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
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
                        suffix: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _seeText = !_seeText;
                            });
                          },
                          child: Icon(Icons.remove_red_eye),
                          style: ButtonStyle(
                            iconColor: MaterialStateProperty.all(Colors.black),
                          ),
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
