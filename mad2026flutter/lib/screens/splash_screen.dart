import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'settings_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final logger = Logger();
  final _uidController = TextEditingController();
  final _tokenController = TextEditingController();

  // 1. Añadimos la variable para la suscripción del GPS [cite: 1087]
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    String? token = prefs.getString('token');
    if (uid == null || token == null) {
      _showInputDialog();
    } else {
      logger.d("UID: $uid, Token: $token");
    }
  }

  Future<void> _showInputDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter UID and Token'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _uidController,
                  decoration: InputDecoration(hintText: "UID"),
                ),
                TextField(
                  controller: _tokenController,
                  decoration: InputDecoration(hintText: "Token"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('uid', _uidController.text);
                await prefs.setString('token', _tokenController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 2. Método para iniciar el seguimiento GPS [cite: 1113-1131]
  void startTracking() async {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualiza cada 10 metros
    );

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            writePositionToFile(position);
          },
        );
  }

  // 3. Método para detener el seguimiento GPS [cite: 1132-1135]
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // 4. Método para escribir en el archivo CSV [cite: 1136-1141]
  Future<void> writePositionToFile(Position position) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gps_coordinates.csv');
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    await file.writeAsString(
      '${timestamp};${position.latitude};${position.longitude}\n',
      mode: FileMode.append,
    );
    logger.d("Posición guardada: ${position.latitude}, ${position.longitude}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HelloWorldFt for MAD'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      // 5. Actualizamos el body con el Switch para activar/desactivar el seguimiento [cite: 1101-1112]
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Screen!'),
            SizedBox(height: 20),
            Text(
              _positionStreamSubscription != null
                  ? "Tracking ON"
                  : "Tracking OFF",
            ),
            Switch(
              value: _positionStreamSubscription != null,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    startTracking();
                  } else {
                    stopTracking();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _uidController.dispose();
    _tokenController.dispose();
    _positionStreamSubscription?.cancel(); // Cancelamos el GPS al cerrar
    super.dispose();
  }
}
