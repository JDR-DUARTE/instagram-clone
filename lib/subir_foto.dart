import 'package:flutter/material.dart';
import 'package:instagram_app/components/navegador_barra.dart';

class SubirFoto extends StatefulWidget {
  const SubirFoto({super.key});

  @override
  State<SubirFoto> createState() => _SubirFotoState();
}

class _SubirFotoState extends State<SubirFoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Subir una foto'),
      ),
      bottomNavigationBar: NavegadorBarra(indiceActual:2),
    );
  }
}