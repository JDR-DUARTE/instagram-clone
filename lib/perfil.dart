import 'package:flutter/material.dart';
import 'package:instagram_app/components/navegador_barra.dart';
import 'package:instagram_app/editar_perfil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  Map<String, dynamic>? perfil;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    final datos = await datosUser();
    print('Perfil recibido: $datos');
    setState(() {
      perfil = datos;
    });
  }

  Future<Map<String, dynamic>?> datosUser() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return null;

    final response = await Supabase.instance.client
        .from('usuarios')
        .select()
        .eq('id', userId)
        .single();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    if (perfil == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Foto de perfil
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(perfil!['foto_url']),
            ),
            const SizedBox(height: 20),

            // Nombre del usuario
            Text(
              perfil!['nombre'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // Nick (@usuario)
            Text(
              '@${perfil!['nick']}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(perfil!['email'] ?? ''),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context)=>EditarPerfil()),
                  ).then((_){
                    cargarPerfil();
                  });
              }, 
              child: Text('Editar Perfil'),),
          ],
        ),
      ),
      bottomNavigationBar: NavegadorBarra(indiceActual:3),
    );
  }
}
