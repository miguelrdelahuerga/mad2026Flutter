import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/second_screen.dart';
import 'screens/third_screen.dart';
import 'screens/map_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Esta "llave" nos permite controlar el mapa desde cualquier parte
  final GlobalKey<MapScreenState> mapKey = GlobalKey<MapScreenState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Función mágica que salta al mapa y lo centra en la coordenada elegida
  void _jumpToMap(double lat, double lon) {
    setState(() {
      _selectedIndex = 3; // Cambia la pestaña inferior al Mapa
    });
    // Le damos unos milisegundos para que el mapa se renderice y luego movemos la cámara
    Future.delayed(const Duration(milliseconds: 300), () {
      mapKey.currentState?.moveToLocation(lat, lon);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definimos las pantallas pasándole al Radar la función de saltar y al Mapa la llave
    final List<Widget> _screens = [
      SplashScreen(),
      SecondScreen(onJumpToMap: _jumpToMap), // Pasamos la función al radar
      ThirdScreen(),
      MapScreen(key: mapKey), // Enganchamos la llave al mapa
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Sensor'),
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Radar'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber), label: 'Avisos'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa Oasis'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}