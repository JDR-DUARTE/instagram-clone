import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class HistoriasUsuario extends StatefulWidget {
  final String usuarioId;
  final String nick;

  const HistoriasUsuario({super.key, required this.usuarioId, required this.nick});

  @override
  State<HistoriasUsuario> createState() => _HistoriasUsuarioState();
}

class _HistoriasUsuarioState extends State<HistoriasUsuario> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> historias = [];
  int historiaActual = 0;
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();
    cargarHistorias();
  }

  Future<void> cargarHistorias() async {
    final response = await supabase
        .from('historias')
        .select('media_url, tipo, created_at')
        .eq('usuario_id', widget.usuarioId)
        .order('created_at');

    setState(() {
      historias = List<Map<String, dynamic>>.from(response);
    });

    if (historias.isNotEmpty && historias[0]['tipo'] == 'video') {
      inicializarVideo(historias[0]['media_url']);
    }
  }

  Future<void> inicializarVideo(String url) async {
    videoController?.dispose();
    videoController = VideoPlayerController.network(url);
    await videoController!.initialize();
    setState(() {});
    videoController!.play();
  }

  void siguienteHistoria() {
    if (historiaActual + 1 < historias.length) {
      setState(() {
        historiaActual++;
      });

      if (historias[historiaActual]['tipo'] == 'video') {
        inicializarVideo(historias[historiaActual]['media_url']);
      } else {
        videoController?.dispose();
        videoController = null;
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (historias.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Historias de ${widget.nick}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final historia = historias[historiaActual];
    final tipo = historia['tipo'];

    return GestureDetector(
      onTap: siguienteHistoria,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: tipo == 'video'
              ? (videoController != null && videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: videoController!.value.aspectRatio,
                      child: VideoPlayer(videoController!),
                    )
                  : const CircularProgressIndicator())
              : Image.network(historia['media_url']),
        ),
      ),
    );
  }
}
