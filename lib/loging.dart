import 'package:flutter/material.dart';
import 'package:instagram_app/components/formulario_loging.dart';
import 'package:instagram_app/components/formulario_registro.dart';
import 'package:instagram_app/feed.dart';
import 'package:instagram_app/perfil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Loging extends StatefulWidget {
  const Loging({super.key});

  @override
  State<Loging> createState() => _LogingState();
}

class _LogingState extends State<Loging> {
  bool mostrarReg=false;
  final supabase =Supabase.instance.client;
   Future<void> hacerLogin(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login exitoso!')),
        );
        // Navegar a la pantalla principal (Feed)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Feed()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Bienvenido a Conexa',
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
            ),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                  setState(() {
                    mostrarReg=false;
                  });
                },
                child: Text('Iniciar Sesión')),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed:(){
                    setState(() {
                      mostrarReg=true;
                    });
                  },
                  child: Text('Registrarse')),
            ],

          ),
          SizedBox(height: 10,),
          Expanded(
            child: mostrarReg
              ? FormularioRegistro()
              : FormularioLoging(
                onLogin: hacerLogin,
              ),
            ),
        ],
      ),
    );
  }
}