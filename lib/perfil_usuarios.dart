import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilUsuarios extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const PerfilUsuarios({required this.usuario, super.key});

  @override
  State<PerfilUsuarios> createState() => _PerfilUsuariosState();
}

class _PerfilUsuariosState extends State<PerfilUsuarios> {
  final supabase = Supabase.instance.client;
  
  bool siguiendo = false;
  Future<void> verificarSeSigue() async{
    final userId= supabase.auth.currentUser!.id;
  final seguidoId =widget.usuario['id'];

    final response = await supabase
        .from('seguimientos')
        .select()
        .eq('seguidor_id', userId)
        .eq('seguido_id', seguidoId)
        .limit(1);
    final data = response as List<dynamic>?;
    setState(() {
      siguiendo=data !=null && data.isNotEmpty;
    });
  }
  @override
  void initState(){
    super.initState();
    verificarSeSigue();
  }
 Future<void> seguirUsuario() async {
  final userId = supabase.auth.currentUser!.id;
  final seguidoId = widget.usuario['id'];

  try {
    // Verificamos si ya lo sigues
    final existe = await supabase
        .from('seguimientos')
        .select()
        .eq('seguidor_id', userId)
        .eq('seguido_id', seguidoId)
        .limit(1);

    if (existe.isNotEmpty) {
      print('Ya sigues a este usuario.');
      return;
    }

    // Insertar seguimiento
    await supabase.from('seguimientos').insert({
      'seguidor_id': userId,
      'seguido_id': seguidoId,
    });

    setState(() {
      siguiendo = true;
    });
  } catch (e) {
    print('Error al seguir: $e');
    // Puedes mostrar un SnackBar si quieres
  }
}

  Future<void> dejarDeSeguir() async {
  final userId = supabase.auth.currentUser!.id;
  final seguidoId = widget.usuario['id'];

  try {
    await supabase
        .from('seguimientos')
        .delete()
        .eq('seguidor_id', userId)
        .eq('seguido_id', seguidoId);

    setState(() {
      siguiendo = false;
    });
  } catch (e) {
    print('Error al dejar de seguir: $e');
    // Puedes mostrar un SnackBar o alerta
  }
}


  @override
  Widget build(BuildContext context) {
    final persona = widget.usuario;
    return Scaffold(
      appBar: AppBar(
        title: Text('@${persona['nick']}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: persona['foto_url'] != null
                  ? NetworkImage(persona['foto_url'])
                  : null,
            ),
            SizedBox(height: 20),
            Text(
              persona['nombre'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '@${persona['nick']}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if(siguiendo){
                  dejarDeSeguir();
                }else{
                  seguirUsuario();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: siguiendo ? const Color.fromARGB(255, 244, 54, 216) : Colors.blue,
              ),
              child: Text(siguiendo ? 'Dejar de seguir' : 'Seguir'),
            ),
          ],
        ),
      ),
    );
  }
}
