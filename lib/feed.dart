import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_app/components/navegador_barra.dart';
import 'package:instagram_app/mensajeria.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final supabase = Supabase.instance.client;

  Future<void> subirFoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

      if (imagen == null) {
        print('No se seleccionó ninguna imagen');
        return;
      }

      final user = supabase.auth.currentUser;
      if (user == null) {
        print('No hay usuario logueado');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subiendo foto...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );

      final String nombreArchivo =
          'foto_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 👇 Aquí es donde diferenciamos entre Web y Móvil
      if (kIsWeb) {
        // WEB: usar bytes (Uint8List)
        final bytes = await imagen.readAsBytes();
        await supabase.storage.from('fotos').uploadBinary(nombreArchivo, bytes);
      } else {
        // MÓVIL: usar File
        final file = File(imagen.path);
        await supabase.storage.from('fotos').upload(nombreArchivo, file);
      }

      final publicUrl = supabase.storage
          .from('fotos')
          .getPublicUrl(nombreArchivo);

      await supabase.from('posts').insert({
        'usuarioId': user.id,
        'email': user.email,
        'url_imagen': publicUrl,
        'descripcion': 'Mi nueva foto',
        // 'fecha': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Foto subida exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al subir foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir foto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: const Text(
          'conexa',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.messenger),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Mensajeria()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'tu email: ${user?.email}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            Text(
              'Posts de la comunidad:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
      bottomNavigationBar: NavegadorBarra(indiceActual: 0),
    );
  }
}
