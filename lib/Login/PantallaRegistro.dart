import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaRegistro extends StatefulWidget {
  @override
  _PantallaRegistroState createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController(); // Para el rol del usuario
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    // Verificar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Las contraseñas no coinciden.'),
      ));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text,
        'name': _nameController.text,
        'surname': _surnameController.text,
        'username': _usernameController.text,
        'role': _roleController.text, // Asignar el rol al nuevo usuario
      });

      // Navegar a la pantalla de login
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print('Error al registrarse: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.message}'),
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
      appBar: AppBar(
        backgroundColor: Color(0xFF282828),
        iconTheme: IconThemeData( color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                'Registrar usuario',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              
              // Formulario de registro
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de correo electrónico
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Campo de contraseña
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),

                    // Campo de confirmar contraseña
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),

                    // Campo de nombre
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Campo de apellido
                    TextField(
                      controller: _surnameController,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Campo de nombre de usuario
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Campo de rol
                    TextField(
                      controller: _roleController,
                      decoration: InputDecoration(
                        labelText: 'Rol (administrador/empleado)',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Botón de registrar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87, // Color del botón
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Registrar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
