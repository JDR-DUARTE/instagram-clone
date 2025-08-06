import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Menciones extends StatefulWidget {
  const Menciones({super.key});

  @override
  State<Menciones> createState() => _MencionesState();
}

class _MencionesState extends State<Menciones> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> menciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarMenciones();
  }

  Future<void> cargarMenciones() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('menciones')
          .select(
            'id, comentario_id, comentarios(comentario, publicacion_id, publicaciones(id, imagen_url))',
          )
          .eq('mencionado_id', userId);
      print(response);

      setState(() {
        menciones = List<Map<String, dynamic>>.from(response);
        cargando = false;
      });
    } catch (e) {
      print('Error al cargar menciones: $e');
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Menciones',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Verdana',
            ),
          ),
          backgroundColor: Color.fromRGBO(98, 67, 159, 0.988),
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (menciones.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Menciones')),
        body: Center(child: Text('No tienes menciones.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menciones',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Verdana'),
        ),
        backgroundColor: Color.fromRGBO(98, 67, 159, 0.988),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: menciones.length,
        itemBuilder: (context, index) {
          final mencion = menciones[index];
          final publicacion = mencion['publicaciones'];
          final comentario = mencion['comentarios'];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: publicacion != null && publicacion['imagen_url'] != null
                  ? Image.network(
                      publicacion['imagen_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.image_not_supported),
              title: comentario != null
                  ? Text(comentario['comentario'] ?? '')
                  : Text('Comentario no disponible'),
              subtitle: Text('Has sido mencionado en una publicación'),
              onTap: () {
                // Navigator.push(...);
              },
            ),
          );
        },
      ),
    );
  }
}
