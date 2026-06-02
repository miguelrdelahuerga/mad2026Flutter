import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Importante para ubicar al arrancar
import '../db/database_helper.dart';

class MapScreen extends StatefulWidget {
  // Recibe la Key que le manda el MainScreen
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];

  // Controlador para poder mover la cámara desde el código
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _centerOnUserLocation(); // Centra el mapa al iniciarlo
  }

  // --- FUNCIÓN ESTRELLA: Mueve la cámara desde el Radar ---
  void moveToLocation(double lat, double lon) {
    mapController.move(LatLng(lat, lon), 17.0); // 17.0 es el zoom (muy de cerca)
  }

  // Intenta leer el GPS y centra el mapa ahí
  Future<void> _centerOnUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Movemos la cámara a donde está el usuario
      moveToLocation(position.latitude, position.longitude);
    } catch (e) {
      print("No se pudo obtener la ubicación para centrar el mapa.");
    }
  }

  Future<void> _loadMarkers() async {
    try {
      final dbMarkers = await DatabaseHelper.instance.getCoordinates();

      List<Marker> loadedMarkers = dbMarkers.map((record) {
        String type = record['type'] ?? 'water';
        int isOp = record['is_operational'] ?? 1;

        IconData iconData = Icons.water_drop;
        Color iconColor = Colors.blue;

        if (type == 'shade') {
          iconData = Icons.park;
          iconColor = Colors.green;
        } else if (type == 'indoor') {
          iconData = Icons.ac_unit;
          iconColor = Colors.lightBlue;
        }

        if (isOp == 0) iconColor = Colors.red.withOpacity(0.6);

        return Marker(
          point: LatLng(
            double.parse(record['latitude'].toString()),
            double.parse(record['longitude'].toString()),
          ),
          width: 80, height: 80,
          child: Icon(iconData, size: 40, color: iconColor),
        );
      }).toList();

      setState(() { markers = loadedMarkers; });
    } catch (e) {
      print("Error cargando BBDD en el mapa.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Oasis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Centrar en mi ubicación',
            onPressed: _centerOnUserLocation, // Botón manual por si nos perdemos por el mapa
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar marcadores',
            onPressed: _loadMarkers,
          )
        ],
      ),
      body: FlutterMap(
        mapController: mapController, // Vinculamos el controlador
        options: const MapOptions(
          initialCenter: LatLng(40.389235, -3.627749), // Centro por defecto (UPM)
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'miguel.rdelahuerga@alumnos.upm.es',
          ),
          // ¡Adiós a la PolylineLayer de la ruta estática!
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}