import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../db/database_helper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _centerOnUserLocation();
  }

  void moveToLocation(double lat, double lon) {
    mapController.move(LatLng(lat, lon), 17.0);
  }

  Future<void> _centerOnUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
          width: 80,
          height: 80,
          child: Icon(iconData, size: 40, color: iconColor),
        );
      }).toList();

      setState(() {
        markers = loadedMarkers;
      });
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
            onPressed: _centerOnUserLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar marcadores',
            onPressed: _loadMarkers,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: const MapOptions(
          initialCenter: LatLng(40.389235, -3.627749),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'miguel.rdelahuerga@alumnos.upm.es',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
