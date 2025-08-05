import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_app/components/navegador_barra.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class SubirFoto extends StatefulWidget {
  const SubirFoto({super.key});

  @override
  State<SubirFoto> createState() => _SubirFotoState();
}

class _SubirFotoState extends State<SubirFoto> {
  final supabase = Supabase.instance.client;
  final picker = ImagePicker();
  File? archivoSelec;
  bool subiendo = false;
  bool esVideo = false;
  Duration? duracionV;
  VideoPlayerController? videoController;

  Future<void> seleccImagen() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      limpiarVideo();
      setState(() {
        archivoSelec = File(pickedFile.path);
        esVideo = false;
      });
    }
  }

  Future<void> seleccVideo() async {
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      videoController = VideoPlayerController.file(File(picked.path));
      await videoController!.initialize();
      final duracion = videoController!.value.duration;
      if (duracion.inSeconds > 15) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El video debe durar 15 segundos o menos.')),
        );
        limpiarVideo();
        return;
      }
      setState(() {
        archivoSelec = File(picked.path);
        esVideo = true;
        duracionV = duracion;
      });
    }
  }

  void limpiarVideo() {
    videoController?.dispose();
    videoController = null;
    duracionV = null;
  }

  Future<void> subirHistoria() async {
    if (archivoSelec == null) {
      return;
    }
    setState(() {
      subiendo = true;
    });
    final userId = supabase.auth.currentUser!.id;
    final extension = p.extension(archivoSelec!.path);
    final nombreArchivo = '${Uuid().v4()}$extension';
    final ruta = '$userId/$nombreArchivo';
    try {
      await supabase.storage
          .from('historias')
          .upload(
            ruta,
            File(archivoSelec!.path),
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );
      final url = supabase.storage.from('historias').getPublicUrl(ruta);
      await supabase.from('historias').insert({
        'usuario_id': userId,
        'media_url': url,
        'tipo': esVideo ? 'video' : 'imagen',
        'texto': '',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historia subida correctamente')),
      );

      setState(() {
        archivoSelec = null;
        subiendo = false;
        limpiarVideo();
      });
    } catch (e) {
      print('error al subur historia $e');
      setState(() {
        subiendo = false;
      });
    }
  }

  Future<void> subir() async {
    if (archivoSelec == null) {
      return;
    }
    setState(() {
      subiendo = true;
    });
    final userId = supabase.auth.currentUser!.id;
    final extension = p.extension(archivoSelec!.path);
    final nombreImagen = Uuid().v4() + extension;
    final ruta = '$userId/$nombreImagen';

    try {
      await supabase.storage
          .from('publicaciones')
          .upload(
            ruta,
            archivoSelec!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );
      final url = supabase.storage.from('publicaciones').getPublicUrl(ruta);
      await supabase.from('publicaciones').insert({
        'usuario_id': userId,
        'imagen_url': url,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Publicación subida correctamente')),
      );
      setState(() {
        archivoSelec = null;
        subiendo = false;
      });
    } catch (e) {
      print('Error al subir publicacion: $e');
      setState(() {
        subiendo = false;
      });
    }
  }

  @override
  void dispose() {
    limpiarVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva publicación')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (archivoSelec != null)
                esVideo && videoController != null
                    ? SizedBox(
                      height: 400,
                      width: 250,
                      child: AspectRatio(
                          aspectRatio: videoController!.value.aspectRatio,
                          child: VideoPlayer(videoController!),
                        ),
                    )
                    : Image.file(archivoSelec!, height: 300),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: seleccImagen,
                
                    child: const Text('Seleccionar\n    Imagen'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: seleccVideo,
                    child: const Text('Seleccionar \n      Video'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (archivoSelec != null) ...[
                if (!esVideo)
                  ElevatedButton(
                    onPressed: subiendo ? null : subir,
                    child: subiendo
                        ? const CircularProgressIndicator()
                        : const Text('Subir Publicación'),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: subiendo ? null : subirHistoria,
                  child: subiendo
                      ? const CircularProgressIndicator()
                      : const Text('Subir Historia'),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavegadorBarra(indiceActual: 2),
    );
  }
}
