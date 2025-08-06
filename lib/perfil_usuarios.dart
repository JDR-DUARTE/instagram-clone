import 'package:emailjs/emailjs.dart' as EmailJS;
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
  List<Map<String, dynamic>> publicaciones = [];
  int cantSeguidores = 0;
  int cantSeguidos = 0;

  Future<void> cargarPublicaciones() async {
    final userId = widget.usuario['id'];

    final data = await supabase
        .from('publicaciones')
        .select()
        .eq('usuario_id', userId)
        .order('created_at', ascending: false);

    setState(() {
      publicaciones = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> verificarSeSigue() async {
    final userId = supabase.auth.currentUser!.id;
    final seguidoId = widget.usuario['id'];

    final response = await supabase
        .from('seguimientos')
        .select()
        .eq('seguidor_id', userId)
        .eq('seguido_id', seguidoId)
        .limit(1);

    final data = response as List<dynamic>?;
    final seguidores = await supabase
        .from('seguimientos')
        .select()
        .eq('seguido_id', seguidoId);

    print('Seguidores encontrados: $seguidores');

    final seguidos = await supabase
        .from('seguimientos')
        .select()
        .eq('seguidor_id', seguidoId);
    print('Seguidos encontrados: $seguidos');
    setState(() {
      siguiendo = data != null && data.isNotEmpty;
      cantSeguidores = seguidores.length;
      cantSeguidos = seguidos.length;
    });
  }

  @override
  void initState() {
    super.initState();
    verificarSeSigue();
    cargarPublicaciones();
  }

  Future<void> seguirUsuario() async {
    final userId = supabase.auth.currentUser!.id;
    final seguidoId = widget.usuario['id'];

    try {
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
      await supabase.from('seguimientos').insert({
        'seguidor_id': userId,
        'seguido_id': seguidoId,
      });

      setState(() {
        siguiendo = true;
      });
    } catch (e) {
      print('Error al seguir: $e');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final persona = widget.usuario;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${persona['nick']}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Verdana',
            fontSize: 24,
          ),
        ),
        backgroundColor: Color.fromRGBO(98, 67, 159, 0.988),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: persona['foto_url'] != null
                      ? NetworkImage(persona['foto_url'])
                      : null,
                ),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      '${persona['nombre']}',
                      style: TextStyle(
                        color: Color.fromRGBO(98, 67, 159, 0.988),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Verdana',
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              '$cantSeguidos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text(
                              'Seguidos',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(width: 20,),
                        Column(
                          children: [
                            Text(
                              '$cantSeguidores',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text(
                              'Seguidores',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (siguiendo) {
                  dejarDeSeguir();
                } else {
                  seguirUsuario();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: siguiendo
                    ? const Color.fromARGB(255, 242, 229, 229)
                    : Color.fromRGBO(98, 67, 159, 0.988),
              ),
              child: Text(
                siguiendo ? 'Dejar de seguir' : 'Seguir',
                style: TextStyle(
                  color: siguiendo ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            publicaciones.isEmpty
                ? Text('Este usuario aún no tiene publicaciones.')
                : GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: publicaciones.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      final pub = publicaciones[index];
                      return Image.network(
                        pub['imagen_url'],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
