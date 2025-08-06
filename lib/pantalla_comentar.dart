import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_portal/flutter_portal.dart';

class PantallaComentar extends StatefulWidget {
  final int publicacionId;
  const PantallaComentar({required this.publicacionId, super.key});

  @override
  State<PantallaComentar> createState() => _PantallaComentarState();
}

class _PantallaComentarState extends State<PantallaComentar> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> comentarios = [];
  final TextEditingController comentarioControl = TextEditingController();
  Map<String, dynamic>? publicacion;
  final GlobalKey<FlutterMentionsState> key = GlobalKey();
  List<Map<String, dynamic>> sugerencias = [];

  Future<void> cargarUsuarios() async {
    final response = await supabase
        .from('usuarios')
        .select('id, nick, foto_url')
        .limit(50);

    setState(() {
      sugerencias = List<Map<String, dynamic>>.from(response).map((usuario) {
        return {
          'id': usuario['id'],
          'display': usuario['nick'],
          'photo': usuario['foto_url'],
        };
      }).toList();
      print('SUGERENCIAS:');
      print(sugerencias);
    });
  }

  Future<void> cargarComentarios() async {
    final respose = await supabase
        .from('comentarios')
        .select('comentario,created_at,usuarios(nombre,foto_url)')
        .eq('publicacion_id', widget.publicacionId)
        .order('created_at');

    setState(() {
      comentarios = List<Map<String, dynamic>>.from(respose);
    });
  }

  Future<void> cargarPublicacion() async {
    final response = await supabase
        .from('publicaciones')
        .select('imagen_url, usuarios(nombre, foto_url)')
        .eq('id', widget.publicacionId)
        .single();

    setState(() {
      publicacion = response;
    });
  }

  Future<void> crearComentario() async {
    final texto = key.currentState!.controller!.text.trim();
    if (texto.isEmpty) {
      return;
    }
    final userId = supabase.auth.currentUser!.id;

    final comentarioR = await supabase
        .from('comentarios')
        .insert({
          'comentario': texto,
          'usuario_id': userId,
          'publicacion_id': widget.publicacionId,
        })
        .select()
        .single();
    final markup = key.currentState!.controller!.markupText;
    final menciones = RegExp(r'\@\[(.*?)\]\((.*?)\)').allMatches(markup);

    for (final match in menciones) {
      final posibleId = match.group(1)!;
      final posibleDisplay = match.group(2)!;
      final idUsuario = posibleId.replaceAll('__', '');
      final display = posibleDisplay.replaceAll('__', '');

      print('ID limpio: $idUsuario');
      print('Display limpio: $display');

      await supabase.from('menciones').insert({
        'comentario_id': comentarioR['id'],
        'mencionado_id': idUsuario,
      });
      print('idMensionado: $idUsuario');
    }
    key.currentState!.controller!.clear();
    cargarComentarios();
  }

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
    cargarComentarios();
    cargarPublicacion();
  }

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
       appBar: AppBar(title: const Text("")),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (publicacion != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    publicacion!['usuarios']['foto_url'],
                                  ),
                                ),
                                title: Text(
                                  publicacion!['usuarios']['nombre'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontFamily: 'Verdana'
                                  ),
                                  ),
                              ),
                              Image.network(
                                publicacion!['imagen_url'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ...comentarios.map((comentario) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                comentario['usuarios']['foto_url'],
                              ),
                            ),
                            title: Text(
                              comentario['usuarios']['nombre'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontFamily: 'Verdana'
                              ),
                              ),
                            subtitle: Text(comentario['comentario']),
                          );
                        }).toList(),
                        Spacer(),

                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: FlutterMentions(
                                  key: key,
                                  suggestionPosition: SuggestionPosition.Top,

                                  decoration: InputDecoration(
                                    hintText: "Escribe un comentario...",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  maxLength: 200,
                                  mentions: [
                                    Mention(
                                      trigger: '@',

                                      matchAll: true,
                                      style: TextStyle(color: Colors.purple),
                                      data: sugerencias,
                                      suggestionBuilder: (data) {
                                        print('Construyendo sugerencia: $data');
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              data['photo'],
                                            ),
                                          ),
                                          title: Text(data['display']),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: crearComentario,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
