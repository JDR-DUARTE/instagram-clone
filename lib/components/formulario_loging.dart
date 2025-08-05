import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class FormularioLoging extends StatefulWidget {
  final Function(String ,String) onLogin;
  const FormularioLoging({required this.onLogin ,super.key});

  @override
  State<FormularioLoging> createState() => _FormularioLogingState();
}

class _FormularioLogingState extends State<FormularioLoging> {
  final TextEditingController emailController=TextEditingController();
  final TextEditingController claveController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email'),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'ejemplo@gmail.com',
          ),
        ),
        SizedBox(height: 10,),
        Text('Clave'),
        TextField(
          controller: claveController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '********',
          ),
        ),
        SizedBox(height: 20,),
        Center(
          child: ElevatedButton(
            onPressed:(){
              final email = emailController.text.trim();
              final clave = claveController.text.trim();
              widget.onLogin(email, clave);
            },
            child:Text(
              'Iniciar Sesión',
              style: TextStyle(
                color: Color.fromRGBO(108, 54, 215, 0.988),
                fontWeight: FontWeight.bold,
              ),
              )),
        )
      ],
    );
  }
}