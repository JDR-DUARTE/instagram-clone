import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:instagram_app/buscador.dart';
import 'package:instagram_app/feed.dart';
import 'package:instagram_app/perfil.dart';
import 'package:instagram_app/subir_foto.dart';

class NavegadorBarra extends StatelessWidget {
  final int indiceActual;
  const NavegadorBarra({required this.indiceActual, super.key});
  void _ir(BuildContext context, int index) {
    if (index == indiceActual) {
      return;
    }
    Widget destino;
    switch (index) {
      case 0:
        destino = Feed();
        break;
      case 1:
        destino = const Buscador();
        break;
      case 2:
        destino = const SubirFoto();
        break;
      case 3:
        destino = const Perfil();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: indiceActual,
      height: 60,
      onTap: (index) => _ir(context, index),
      items: [
        _buildIcono(Icons.home, indiceActual == 0),
        _buildIcono(Icons.search, indiceActual == 1),
        _buildIcono(Icons.add_a_photo_outlined, indiceActual == 2),
        _buildIcono(Icons.account_circle_outlined, indiceActual == 3),
      ],
    );
  }

  Widget _buildIcono(IconData icon, bool activo) {
    return Icon(
      icon,
      size: 30,
      color: activo
          ? const Color.fromARGB(255, 250, 120, 189)
          : Colors.blueAccent,
    );
  }
}

// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:instagram_app/buscador.dart';
// import 'package:instagram_app/feed.dart';
// import 'package:instagram_app/perfil.dart';
// import 'package:instagram_app/subir_foto.dart';

// class NavegadorBarra extends StatefulWidget {
//   final int indiceActual;
//   const NavegadorBarra({required this.indiceActual,super.key});

//   @override
//   State<NavegadorBarra> createState() => _NavegadorBarraState();
// }

// class _NavegadorBarraState extends State<NavegadorBarra> {
//   int _selectedTab = 0;
//   final List<Widget> _pages = [Feed(), Perfil(), Buscador(), SubirFoto()];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(child: _pages[_selectedTab]),
//       bottomNavigationBar: CurvedNavigationBar(
//         index: _selectedTab,
//         height: 60,
//         items: <Widget>[
//           _buildNavItem(Icons.home, _selectedTab == 0),
//           _buildNavItem(Icons.search, _selectedTab == 1),
//           _buildNavItem(Icons.add_a_photo_outlined, _selectedTab == 2),
//           _buildNavItem(Icons.account_circle_outlined, _selectedTab == 3),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, bool isSelected) {
//     return Icon(
//       icon,
//       size: 30,
//       color: isSelected
//           ? const Color.fromARGB(255, 253, 128, 178)
//           : Colors.blueAccent,
//     );
//   }
// }
