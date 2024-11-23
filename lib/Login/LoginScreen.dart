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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _seeText = false;

  Future<void> _login() async {
  setState(() {
    _isLoading = true;
  });

  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    final User? user = userCredential.user;
    final DocumentSnapshot userDoc =
        await _firestore.collection('usuarios').doc(user!.uid).get();
    final role = userDoc['role'];

    if (mounted) {
      if (role == 'administrador') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => PABottomnavigation()));
      } else if (role == 'empleado') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Bottomnavigation()));
      }
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
    // Mostrar mensaje de error específico en el SnackBar
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
              'assets/logo.png',
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
                  // Campo de usuario
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Campo de contraseña
                  TextField(
                      controller: _passwordController,
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
                            setState(() {});
                          },
                        ),
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                        ),
                        )
                        )
                        ,
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Acción para recuperar contraseña
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.black,
                      decoration: TextDecoration.underline,),
                    ),
                  ),
                  // Botón de inicio de sesión
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87, // Color del botón
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
            // Enlace de "¿Olvidaste tu contraseña?"
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PantallaRegistro()), // Navegar a la pantalla de registro
                );
              },
              child: Text('¿No tienes cuenta? Regístrate',
              style: TextStyle(color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

