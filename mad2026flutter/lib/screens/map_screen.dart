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

  // La "Ruta Fresca" estática
  final List<LatLng> staticRoute = [
    const LatLng(40.389235, -3.627749), // UPM Campus Sur
    const LatLng(40.395000, -3.640000), // Parque cercano
    const LatLng(40.400000, -3.650000), // Zona de sombras
    const LatLng(40.416775, -3.703790), // Centro Madrid (Refugio)
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    try {
      final dbMarkers = await DatabaseHelper.instance.getCoordinates();

      List<Marker> loadedMarkers = dbMarkers.map((record) {
        String type = record['type'] ?? 'water';
        int isOp = record['is_operational'] ?? 1;

        // Selección dinámica de Icono y Color
        IconData iconData = Icons.water_drop;
        Color iconColor = Colors.blue;

        if (type == 'shade') {
          iconData = Icons.park;
          iconColor = Colors.green;
        } else if (type == 'indoor') {
          iconData = Icons.ac_unit;
          iconColor = Colors.lightBlue;
        }

        // Si está averiado/cerrado, se pone rojo
        if (isOp == 0) {
          iconColor = Colors.red.withOpacity(0.6);
        }

        return Marker(
          point: LatLng(
            double.parse(record['latitude'].toString()),
            double.parse(record['longitude'].toString()),
          ),
          width: 80,
          height: 80,
          child: Icon(iconData, size: 40, color: iconColor),
        );
      }).toList();

      setState(() {
        markers = loadedMarkers;
      });
    } catch (e) {
      // Marcadores simulados para Google Chrome con la nueva lógica
      print("Cargando oasis simulados para Chrome Web");
      setState(() {
        markers = [
          Marker(
            point: const LatLng(40.389235, -3.627749), // Fuente operativa
            width: 80, height: 80,
            child: const Icon(Icons.water_drop, size: 40, color: Colors.blue),
          ),
          Marker(
            point: const LatLng(40.395000, -3.640000), // Zona de sombra
            width: 80, height: 80,
            child: const Icon(Icons.park, size: 40, color: Colors.green),
          ),
          Marker(
            point: const LatLng(40.400000, -3.650000), // Fuente ROTA
            width: 80, height: 80,
            child: Icon(Icons.water_drop, size: 40, color: Colors.red.withOpacity(0.6)),
          ),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Oasis')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(40.389235, -3.627749), // Centrado en la UPM
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'miguel.rdelahuerga@alumnos.upm.es',
          ),
          // Capa de la Ruta Fresca
          PolylineLayer(
            polylines: [
              Polyline(
                points: staticRoute,
                strokeWidth: 5.0,
                color: Colors.lightBlueAccent.withOpacity(0.7),
              ),
            ],
          ),
          // Capa de los Oasis
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}