import 'package:flutter/material.dart';
import 'package:instagram_app/nueva_conversacion.dart';
import 'package:instagram_app/pantalla_chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Mensajeria extends StatefulWidget {
  const Mensajeria({super.key});

  @override
  State<Mensajeria> createState() => _MensajeriaState();
}

class _MensajeriaState extends State<Mensajeria> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> conversaciones = [];

  @override
  void initState() {
    super.initState();
    cargarConversa();
  }

  Future<void> cargarConversa() async {
    final userId = supabase.auth.currentUser!.id;
    final mensajes = await supabase
        .from('mensajes')
        .select('emisor_id,receptor_id')
        .or('emisor_id.eq.$userId,receptor_id.eq.$userId');

    final Set<String> otrosUsuarios = {};

    for (var msj in mensajes) {
      final emisor = msj['emisor_id'];
      final receptor = msj['receptor_id'];

      if (emisor != userId) {
        otrosUsuarios.add(emisor);
      }
      if (receptor != userId) {
        otrosUsuarios.add(receptor);
      }
    }
    if (otrosUsuarios.isEmpty) {
      setState(() {
        conversaciones = [];
      });
      return;
    }
    final datos = await supabase
        .from('usuarios')
        .select('id,nombre,nick,foto_url')
        .inFilter('id', otrosUsuarios.toList());
    setState(() {
      conversaciones = List<Map<String, dynamic>>.from(datos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mensajes',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontFamily: 'Verdana'
            ),
        ),
        backgroundColor: Color.fromRGBO(98, 67, 159, 0.988),
        foregroundColor: Colors.white,
      ),

      body: conversaciones.isEmpty
          ? Center(
              child: Text(
                'No tienes conversaciones aún',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: ListView.builder(
                itemCount: conversaciones.length,
                itemBuilder: (context, index) {
                  final conv = conversaciones[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: conv['foto_url'] != null
                            ? NetworkImage(conv['foto_url'])
                            : null,
                      ),
                      title: Text(
                        conv['nick'] ?? conv['nombre'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Verdana',
                        ),
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaChat(
                              receptorId: conv['id'],
                              receptorNombre: conv['nombre'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final usuario = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NuevaConversacion()),
          );
        },
        backgroundColor: Color.fromRGBO(98, 67, 159, 0.988),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
