import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final supabase= Supabase.instance.client;
  final nombreController = TextEditingController();
  final nickController = TextEditingController();

  File? fotoNueva;
  String? urlFoto;
  @override
  void initState(){
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async{
    final userId=supabase.auth.currentUser?.id;
    if(userId==null){
      return;
    }
    final response=await supabase
      .from('usuarios')
      .select()
      .eq('id', userId)
      .single();
    
    setState(() {
      nombreController.text=response['nombre']?? '';
      urlFoto=response['foto_url'];
    });
  }

  Future<void> selecFotoNew() async{
    final picker= ImagePicker();
    final image= await picker.pickImage(source: ImageSource.gallery);

    if(image !=null){
      setState(() {
        fotoNueva=File(image.path);
      });
    }
  }
   Future<void> guardarCambios() async {
  final userId = supabase.auth.currentUser?.id;
 
  if (userId == null) {
    
    return;
  }

  String? nuevaUrl;

  try {
    if (fotoNueva != null) {
      final nombreArchivo = 'perfil_$userId.jpg';

      await supabase.storage
          .from('perfil')
          .upload(nombreArchivo, fotoNueva!, fileOptions: const FileOptions(upsert: true));

      final url = supabase.storage
          .from('perfil')
          .getPublicUrl(nombreArchivo);
      nuevaUrl = url;
    }

    await supabase.from('usuarios').update({
      'nombre': nombreController.text,
      if (nuevaUrl != null) 'foto_url': nuevaUrl,
    }).eq('id', userId);

  

    if (mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    print('ERROR al guardar cambios: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    ImageProvider? foto;
    if(fotoNueva!=null){
      foto=FileImage(fotoNueva!);
    }else if(urlFoto!=null){
      foto=NetworkImage(urlFoto!);
    }else{
      foto =null;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            GestureDetector(
              onTap: selecFotoNew,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: foto,
                child: foto == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre para mostrar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: guardarCambios,
              child: const Text('Guardar cambios'),
            )
          ],
        ),
      ),
    );
  }
}