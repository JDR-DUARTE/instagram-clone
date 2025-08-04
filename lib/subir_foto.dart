import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_app/components/navegador_barra.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SubirFoto extends StatefulWidget {
  const SubirFoto({super.key});

  @override
  State<SubirFoto> createState() => _SubirFotoState();
}

class _SubirFotoState extends State<SubirFoto> {
  final supabase = Supabase.instance.client;
  final picker =ImagePicker();
  File? imagenSelec;
  bool subiendo=false;

  Future<void> seleccImagen() async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      setState(() {
        imagenSelec=File(pickedFile.path);
      });
    }
  }
  Future<void> subirPublicacion() async{
    if(imagenSelec==null){
      return;
    }
    setState(() {
      subiendo=true;
    });
    final userId= supabase.auth.currentUser!.id;
    final extension =p.extension(imagenSelec!.path);
    final nombreImagen= Uuid().v4() + extension;
    final ruta='$userId/$nombreImagen';

    try{
      await supabase.storage.from('publicaciones').update(
        ruta, 
        imagenSelec!,
        fileOptions: FileOptions(cacheControl: '3600',upsert: false)
        );
        final url=supabase.storage.from('publicaciones').getPublicUrl(ruta);
        await supabase.from('publicaciones').insert({
          'usuario_id':userId,
          'imagen_url':url,
        }
        );
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Publicación subida correctamente')),
      );
      setState(() {
        imagenSelec = null;
        subiendo = false;
      });
    }catch(e){
      print('Error al subir imagen: $e');
      setState(() {
        subiendo=false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: const Text('Nueva publicación')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagenSelec!= null)
              Image.file(imagenSelec!, height: 300),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: seleccImagen,
              child: const Text('Seleccionar imagen'),
            ),
            const SizedBox(height: 10),
            if (imagenSelec!= null)
              ElevatedButton(
                onPressed: subiendo ? null : subirPublicacion,
                child: subiendo
                    ? const CircularProgressIndicator()
                    : const Text('Subir'),
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavegadorBarra(indiceActual: 2),
    );
  }
}