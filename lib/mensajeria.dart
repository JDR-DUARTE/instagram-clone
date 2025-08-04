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
  Future<void> cargarConversa()async{
    final userId =supabase.auth.currentUser!.id;
    final mensajes =await supabase
    .from('mensajes')
    .select('emisor_id,receptor_id')
    .or('emisor_id.eq.$userId,receptor_id.eq.$userId');

    final Set<String> otrosUsuarios={};

    for (var msj in mensajes){
      final emisor =msj['emisor_id'];
      final receptor =msj['receptor_id'];

      if(emisor!=userId){
        otrosUsuarios.add(emisor);
      }
      if(receptor!=userId){
        otrosUsuarios.add(receptor);
      }
    }
    if(otrosUsuarios.isEmpty){
      setState(() {
        conversaciones=[];
      });
      return;
    }
    final datos =await supabase 
      .from('usuarios')
      .select('id,nombre,nick,foto_url')
      .inFilter('id', otrosUsuarios.toList());
      setState(() {
        conversaciones=List<Map<String,dynamic>>.from(datos);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: Colors.purple,
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
            padding: const EdgeInsets.only(top:15.0),
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
                      title: Text(conv['nombre'] ?? conv['nick'] ?? ''),
                                
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
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }
}
