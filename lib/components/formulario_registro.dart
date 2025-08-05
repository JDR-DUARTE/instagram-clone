import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({super.key});

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nickController = TextEditingController();
  final nombreController = TextEditingController();
  final supabase = Supabase.instance.client;
  String msjError = '';


  void registrarUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final nick = nickController.text.trim();
    final nombre = nombreController.text.trim();

    setState(() {
      msjError = '';
    });

    if (email.isEmpty || password.isEmpty || nick.isEmpty || nombre.isEmpty) {
      setState(() {
        msjError = 'Por favor completa todos los campos.';
      });
      return;
    }

    final respuestaNick = await supabase
        .from('usuarios')
        .select()
        .eq('nick', nick)
        .maybeSingle();
    print("Respuesta de verificación de nick: $respuestaNick");

    if (respuestaNick != null) {
      print('entro al if');
      setState(() {
        msjError = 'El nick ya está en uso elige uno diferente';
      });
      return;
    }

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nick': nick,
          'nombre': nombre,
        },
      );

      final user = response.user;
      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Revisa tu correo y confírmalo para completar el registro!')),
        );
      }

    } catch (e) {
      print("Error en registro: $e");
      setState(() {
        msjError = 'Ocurrió un error al registrar: $e';
      });
    }
  }
@override
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: nickController,
          decoration: InputDecoration(labelText: 'Nick (@usuario)'),
        ),
        SizedBox(height: 20),
        TextField(
          controller: nombreController,
          decoration: InputDecoration(labelText: 'Nombre para mostrar'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: registrarUser,
          child: Text(
            'Registrar',
            style: TextStyle(
              color: Color.fromRGBO(108, 54, 215, 0.988),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (msjError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(msjError, style: TextStyle(color: Colors.red)),
          ),
      ],
    ),
  );
}
}