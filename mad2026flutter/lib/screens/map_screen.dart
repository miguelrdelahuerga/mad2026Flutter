import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../db/database_helper.dart';

class MapScreen extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];

  // Ruta estática solicitada por el snippet
  final List<LatLng> staticRoute = [
    LatLng(40.389235, -3.627749), // UPM Campus Sur
    LatLng(40.400000, -3.650000), // Punto intermedio inventado
    LatLng(40.416775, -3.703790), // Madrid Centro
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  // Función para cargar la lista de marcadores desde la base de datos
  Future<void> _loadMarkers() async {
    try {
      final dbMarkers = await DatabaseHelper.instance.getCoordinates();

      List<Marker> loadedMarkers = dbMarkers.map((record) {
        return Marker(
          point: LatLng(
              double.parse(record['latitude'].toString()),
              double.parse(record['longitude'].toString())
          ),
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_pin,
            size: 40,
            color: Colors.red,
          ),
        );
      }).toList();

      setState(() {
        markers = loadedMarkers;
      });
    } catch (e) {
      // Parche Web: Si SQLite falla en Chrome, mostramos marcadores de prueba
      print("Cargando marcadores simulados para Chrome Web");
      setState(() {
        markers = [
          Marker(
            point: LatLng(40.389235, -3.627749),
            width: 80, height: 80,
            child: const Icon(Icons.location_pin, size: 40, color: Colors.blue),
          ),
          Marker(
            point: LatLng(40.416775, -3.703790),
            width: 80, height: 80,
            child: const Icon(Icons.location_pin, size: 40, color: Colors.blue),
          )
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map & Routes')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(40.389235, -3.627749), // Centrado en la UPM
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          // Capa de la ruta estática
          PolylineLayer(
            polylines: [
              Polyline(
                points: staticRoute,
                strokeWidth: 4.0,
                color: Colors.blueAccent,
              ),
            ],
          ),
          // Capa de los marcadores dinámicos de la BBDD
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}