import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaComentar extends StatefulWidget {
  final int publicacionId;
  const PantallaComentar({ required this.publicacionId,super.key});

  @override
  State<PantallaComentar> createState() => _PantallaComentarState();
}

class _PantallaComentarState extends State<PantallaComentar> {
  final supabase= Supabase.instance.client;
  List<Map<String,dynamic>> comentarios=[];
  final TextEditingController comentarioControl= TextEditingController();
  Map<String, dynamic>?publicacion;
  Future<void> cargarComentarios()async{
    final respose =await supabase
      .from('comentarios')
      .select('comentario,created_at,usuarios(nombre,foto_url)')
      .eq('publicacion_id', widget.publicacionId)
      .order('created_at');

    setState(() {
      comentarios=List<Map<String,dynamic>>.from(respose);
    });
  }

  Future<void> cargarPublicacion() async{
     final response = await supabase
      .from('publicaciones')
      .select('imagen_url, usuarios(nombre, foto_url)')
      .eq('id', widget.publicacionId)
      .single();

  setState(() {
    publicacion = response;
  });
  }
  Future<void> crearComentario() async{
    final texto =comentarioControl.text.trim();
    if(texto.isEmpty){
      return;
    }
    final userId= supabase.auth.currentUser!.id;

    await supabase.from('comentarios').insert({
      'comentario':texto,
      'usuario_id':userId,
      'publicacion_id': widget.publicacionId,
    });
    comentarioControl.clear();
    cargarComentarios();
  }
  @override
  void initState(){
    super.initState();
    cargarComentarios();
    cargarPublicacion();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Comentarios")),
    body: Column(
      children: [
        // Mostrar la publicación original (autor + imagen)
        if (publicacion != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(publicacion!['usuarios']['foto_url']),
                ),
                title: Text(publicacion!['usuarios']['nombre']),
              ),
              Image.network(
                publicacion!['imagen_url'],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Icon(Icons.broken_image)),
              ),
              const SizedBox(height: 12),
            ],
          ),

        // Lista de comentarios
        Expanded(
          child: ListView.builder(
            itemCount: comentarios.length,
            itemBuilder: (context, index) {
              final comentario = comentarios[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(comentario['usuarios']['foto_url']),
                ),
                title: Text(comentario['usuarios']['nombre']),
                subtitle: Text(comentario['comentario']),
              );
            },
          ),
        ),

        // Campo para escribir y enviar comentario
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: comentarioControl,
                  decoration: InputDecoration(hintText: "Escribe un comentario..."),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: crearComentario,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}