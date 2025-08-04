import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_app/pantalla_chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NuevaConversacion extends StatefulWidget {
  const NuevaConversacion({super.key});

  @override
  State<NuevaConversacion> createState() => _NuevaConversacionState();
}

class _NuevaConversacionState extends State<NuevaConversacion> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> seguidores = [];
  bool cargando = true;
  @override
  void initState() {
    super.initState();
    obtenerSeguidores();
  }

  Future<void> obtenerSeguidores() async {
    final userId = supabase.auth.currentUser!.id;

    final response = await supabase
        .from('seguimientos')
        .select(
          'seguidor_id,seguidorMsjss:seguidor_id(id,nombre,nick,foto_url)',
        )
        .eq('seguido_id', userId);

    final data = response as List;

    setState(() {
      seguidores = data
          .map((item) => item['seguidorMsjss'] as Map<String, dynamic>)
          .where((user) => user['id'] != userId)
          .toList();
      cargando = false;
    });
  }

  void abrirChat(Map<String, dynamic> seguidorMsjs) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaChat(
          receptorId: seguidorMsjs['id'],
          receptorNombre: seguidorMsjs['nombre'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir seguidor'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : seguidores.isEmpty
          ? const Center(child: Text('Nadie te sigue todavía'))
          : Padding(
            padding: const EdgeInsets.only(top:15.0),
            child: ListView.builder(
                itemCount: seguidores.length,
                itemBuilder: (context, index) {
                  final seguidorMsjs = seguidores[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: seguidorMsjs['foto_url'] != null
                            ? NetworkImage(seguidorMsjs['foto_url'])
                            : null,
                        child: seguidorMsjs['foto_url'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(seguidorMsjs['nombre'] ?? seguidorMsjs['nick']),
                      subtitle: Text('@${seguidorMsjs['nick']}'),
                      onTap: () => abrirChat(seguidorMsjs),
                    ),
                  );
                },
              ),
          ),
    );
  }
}
