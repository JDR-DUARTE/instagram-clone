import 'package:flutter/material.dart';
import 'package:instagram_app/components/navegador_barra.dart';
import 'package:instagram_app/historias_usuarios.dart';
import 'package:instagram_app/menciones.dart';
import 'package:instagram_app/mensajeria.dart';
import 'package:instagram_app/pantalla_comentar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> stories = [];

  Future<void> cargarHistorias() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      List<String> seguidos = [];
      final seguidosR = await supabase
          .from('seguimientos')
          .select('seguido_id')
          .eq('seguidor_id', userId);

      for (var item in seguidosR) {
        seguidos.add(item['seguido_id']);
      }
      seguidos.add(userId);

      final response = await supabase
          .from('historias')
          .select(
            'usuario_id,media_url,tipo,created_at,usuarios (nick,foto_url)',
          )
          .inFilter('usuario_id', seguidos)
          .order('created_at', ascending: false);

      final Map<String, Map<String, dynamic>> historiasPorUsuario = {};
      for (final historia in response) {
        final id = historia['usuario_id'];
        if (!historiasPorUsuario.containsKey(id)) {
          historiasPorUsuario[id] = historia;
        }
      }

      setState(() {
        stories = historiasPorUsuario.values.toList();
      });
    } catch (e) {
      print('error al cargar historias: $e');
    }
  }

  Future<void> cargarPublicaciones() async {
    try {
      List<String> seguidos = [];
      final userId = supabase.auth.currentUser!.id;

      final seguidosR = await supabase
          .from('seguimientos')
          .select('seguido_id')
          .eq('seguidor_id', userId);

      for (var item in seguidosR) {
        seguidos.add(item['seguido_id']);
      }
      seguidos.add(userId);

      final response = await supabase
          .from('publicaciones')
          .select(
            'id,imagen_url,created_at,usuario_id,usuarios(nombre, foto_url)',
          )
          .inFilter('usuario_id', seguidos)
          .order('created_at', ascending: false);

      setState(() {
        posts = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('error al cargar publicaciones: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    cargarHistorias();
    cargarPublicaciones();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(98, 67, 159, 0.988),
        foregroundColor: Colors.white,
        title: Image.asset(
          'assets/conexa4.png',
          height: 35,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Menciones()),
              );
            },
          ),
          const SizedBox(width: 8),
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
            if (stories.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final historia = stories[index];
                    final nick = historia['usuarios']['nick'];
                    final foto = historia['usuarios']['foto_url'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoriasUsuario(
                              usuarioId: historia['usuario_id'],
                              nick: historia['usuarios']['nick'] ?? 'nick',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
                        width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.purple,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage(foto),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              nick,
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 15),
            Expanded(
              child: posts.isEmpty
                  ? Center(child: Text('No hay publicaciones disponibles.'))
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(
                                        post['usuarios']['foto_url'],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      post['usuarios']['nombre'] ?? 'Usuario',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PantallaComentar(
                                        publicacionId: post['id'],
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  post['imagen_url'],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(child: Icon(Icons.broken_image)),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavegadorBarra(indiceActual: 0),
    );
  }
}
