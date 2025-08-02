import 'package:flutter/material.dart';
import 'package:instagram_app/components/navegador_barra.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Buscador extends StatefulWidget {
  const Buscador({super.key});

  @override
  State<Buscador> createState() => _BuscadorState();
}

class _BuscadorState extends State<Buscador> {
  final supabase = Supabase.instance.client;
  final TextEditingController controlador = TextEditingController();
  List<dynamic> resultados=[];

  void buscarUsuarios(String query) async{
    if (query.isEmpty){
      setState(() {
        resultados =[];
      });
      return;
    }
    final response =await supabase
      .from('usuarios')
      .select()
      .ilike('nick', '%$query%');
    setState(() {
      resultados =response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
     appBar: AppBar(
      title: Text('Buscar usuarios'),
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
     ),
     body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controlador,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre..',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: buscarUsuarios,
          ),
          SizedBox(height: 20,),
          Expanded(
            child: ListView.builder(
              itemCount: resultados.length,
              itemBuilder:(context,index){
                final usuario=resultados[index];
                return ListTile(
                  title: Text(usuario['nombre']),
                  subtitle: Text('@${usuario['nick'] ?? 'sin nick'}'),
                );
                
              })
              ),
        ],
      ),
      ),
     bottomNavigationBar: NavegadorBarra(indiceActual: 1),
    );
  }
}