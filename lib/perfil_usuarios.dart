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
  final String serviceId = 'service_5noatff';
  final String templateId = 'template_a1pp89a';
  final String publicKey = 'dHgtQ_9jG2aW6HUEa';
  bool enviandoEmail = false;
  List<Map<String, dynamic>> publicaciones = [];

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
    setState(() {
      siguiendo = data != null && data.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    verificarSeSigue();
    cargarPublicaciones();
  }

  // Future<void> enviarEmail(String seguidoId) async {
  //   final userId = supabase.auth.currentUser!.id;

  //   final seguidorR = await supabase
  //       .from('usuarios')
  //       .select('nick,nombre')
  //       .eq('id', userId)
  //       .single();

  //   final seguidoR = await supabase
  //       .from('usuarios')
  //       .select('nick,nombre,email')
  //       .eq('id', seguidoId)
  //       .single();

  //   final emailSeguido = seguidoR['email'];

  //   if (emailSeguido == null) {
  //     print('No se pudo obtener el email del usuario seguido');
  //     return;
  //   }

  //   final templateParams = {
  //     'user_email': emailSeguido,
  //     // Agrega más campos si los usas en tu template, por ahora solo este
  //   };

  //   try {
  //     await EmailJS.send(
  //       serviceId,
  //       templateId,
  //       templateParams,
  //       const EmailJS.Options(
  //         publicKey: 'dHgtQ_9jG2aW6HUEa',
  //       ),
  //     );
  //     print('✅ Email enviado exitosamente con EmailJS');
  //   } catch (error) {
  //     if (error is EmailJS.EmailJSResponseStatus) {
  //       print('❌ Error ${error.status}: ${error.text}');
  //     } else {
  //       print('❌ Error desconocido: ${error.toString()}');
  //     }
  //   }
  // }

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
        title: Text('${persona['nick']}'),
        backgroundColor: Color.fromRGBO(98, 67, 159, 0.988),
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
                  color: siguiendo? Colors.black : Colors.white,
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
                        pub['imagen_url'], // Asegúrate de que se llama así en tu tabla
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
