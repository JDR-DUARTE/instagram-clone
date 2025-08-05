import 'package:flutter/material.dart';
import 'package:instagram_app/components/navegador_barra.dart';
import 'package:instagram_app/editar_perfil.dart';
import 'package:instagram_app/pantalla_comentar.dart';
import 'package:instagram_app/pantalla_loging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  Map<String, dynamic>? perfil;
  List<Map<String, dynamic>> publicaciones = [];
  final supabase = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    cargarPerfil();
    cargarPublicaciones();
  }

  Future<void> cargarPerfil() async {
    final datos = await datosUser();
    print('Perfil recibido: $datos');
    setState(() {
      perfil = datos;
    });
  }
  Future<void> cargarPublicaciones() async{
    final userId = supabase.auth.currentUser!.id;
    if(userId==null){
      return;
    }
    final response = await Supabase.instance.client
      .from('publicaciones')
      .select('id,imagen_url')
      .eq('usuario_id', userId)
      .order('created_at', ascending: false);
    setState(() {
      publicaciones=List<Map<String,dynamic>>.from(response);
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

  Future<void> cerrarSesion() async {
    await supabase.auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context)=>PantallaLoging()),(Route<dynamic>route)=>false,);
  }

  @override
  Widget build(BuildContext context) {
    if (perfil == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Parte de perfil
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(perfil!['foto_url']),
          ),
          const SizedBox(height: 20),
          Text(
            perfil!['nombre'] ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '@${perfil!['nick']}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(perfil!['email'] ?? ''),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditarPerfil()),
                  ).then((_) {
                    cargarPerfil();
                  });
                },
                child: const Text('Editar Perfil'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: cerrarSesion,
                child: const Text('Cerrar'),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(), 

          const SizedBox(height: 10),
          publicaciones.isEmpty
              ? const Text('Aún no tienes publicaciones')
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: publicaciones.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final pub = publicaciones[index];
                    return GestureDetector(
                      onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>PantallaComentar(publicacionId: pub['id']),
                            ),
                          );
                        },
                      child: Image.network(pub['imagen_url'], fit: BoxFit.cover));
                  },
                ),
        ],
      ),
    ),
  ),
      bottomNavigationBar: NavegadorBarra(indiceActual: 3),
    );
  }
}
