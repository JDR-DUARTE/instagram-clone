import 'package:flutter/material.dart';
import 'package:instagram_app/components/formulario_Loging.dart';
import 'package:instagram_app/components/formulario_registro.dart';
import 'package:instagram_app/feed.dart';
import 'package:instagram_app/perfil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaLoging extends StatefulWidget {
  const PantallaLoging({super.key});

  @override
  State<PantallaLoging> createState() => _PantallaLogingState();
}

class _PantallaLogingState extends State<PantallaLoging> {
  bool mostrarReg = false;
  final supabase = Supabase.instance.client;

  Future<void> hacerLogin(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login exitoso!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Feed()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      
                      // Imagen centrada arriba
                      Center(
                        child: Image.asset(
                          'assets/conexa1.png',
                          height: 350,
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: 18),

                      // Formulario (sin Expanded)
                      mostrarReg
                          ? FormularioRegistro()
                          : FormularioLoging(onLogin: hacerLogin),

                      Spacer(),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            mostrarReg = !mostrarReg;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 22.0),
                          child: Text(
                            mostrarReg
                                ? '¿Ya tienes cuenta? Inicia sesión'
                                : '¿No tienes cuenta? Regístrate',
                            style: TextStyle(
                              color: Colors.teal,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

}
