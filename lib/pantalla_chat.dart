import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaChat extends StatefulWidget {
  final String receptorId;
  final String receptorNombre;
  const PantallaChat({
    required this.receptorId,
    required this.receptorNombre,
    super.key});

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final supabase = Supabase.instance.client;
  final TextEditingController msjControlador = TextEditingController();
  List<Map<String,dynamic>> mensajes =[];
  // bool isLoading = true;
  String? errorMessage;

Future<void> cargarMsj() async {
    try {
      // setState(() {
      //   isLoading = true;
      //   errorMessage = null;
      // });

      final userId = supabase.auth.currentUser!.id;
      
      // Método 1: Mensajes enviados por mí
      final mensajesEnviados = await supabase
        .from('mensajes')
        .select()
        .eq('emisor_id', userId)
        .eq('receptor_id', widget.receptorId);

      // Método 2: Mensajes recibidos por mí
      final mensajesRecibidos = await supabase
        .from('mensajes')
        .select()
        .eq('emisor_id', widget.receptorId)
        .eq('receptor_id', userId);

      // Combinar y ordenar
      List<Map<String, dynamic>> todosMensajes = [
        ...List<Map<String,dynamic>>.from(mensajesEnviados),
        ...List<Map<String,dynamic>>.from(mensajesRecibidos),
      ];
      
      // Ordenar por fecha
      todosMensajes.sort((a, b) {
        if (a['created_at'] == null || b['created_at'] == null) return 0;
        return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
      });

      setState(() {
        mensajes = todosMensajes;
        // isLoading = false;
      });
      
      
    } catch (e) {
      print('el error es : $e');
      setState(() {
        errorMessage = e.toString();
        // isLoading = false;
      });
    }
  }

  Future<void> enviarMsj() async{
    final userId = supabase.auth.currentUser!.id;
    final texto =msjControlador.text.trim();
    if (texto.isEmpty){return;}

    await supabase.from('mensajes').insert({
      'emisor_id':userId,
      'receptor_id':widget.receptorId,
      'mensaje': texto,
    });
    msjControlador.clear();
    await cargarMsj();
  }

  @override
  void initState(){
    super.initState();
    cargarMsj();
  }
  @override
  Widget build(BuildContext context) {
    final userId =supabase.auth.currentUser!.id;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receptorNombre),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = mensajes[index];
                final esMio = mensaje['emisor_id'] == userId;
                return Container(
                  alignment:
                      esMio ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: esMio
                          ? Colors.purple.shade100
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Text(mensaje['mensaje']),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msjControlador,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purple),
                  onPressed: enviarMsj,
                ),
              ],
            ),
          )
        ],
      ),

    );
  }
}