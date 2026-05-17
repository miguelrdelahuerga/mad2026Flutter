import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<List<String>> _coordinates = [];
  List<List<String>> _dbCoordinates = [];

  @override
  void initState() {
    super.initState();
    _loadCoordinates();
    _loadDbCoordinatesAndUpdate();
  }

  // Carga desde el archivo CSV (Snippet W11)
  Future<void> _loadCoordinates() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gps_coordinates.csv');
    if (await file.exists()) {
      List<String> lines = await file.readAsLines();
      setState(() {
        _coordinates = lines.map((line) => line.split(';')).toList();
      });
    }
  }

  // Carga desde SQLite (Snippet W12)
  void _loadDbCoordinatesAndUpdate() async {
    try {
      List<Map<String, dynamic>> dbCoords = await DatabaseHelper.instance.getCoordinates();
      setState(() {
        _dbCoordinates = dbCoords.map((c) => [
          c['timestamp'].toString(),
          c['latitude'].toString(),
          c['longitude'].toString()
        ]).toList();
      });
    } catch (e) {
      print("SQFLite no soportado en Web (Chrome). Usando persistencia CSV.");
    }
  }

  // Diálogo para borrar
  void _showDeleteDialog(String timestamp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm delete $timestamp"),
          content: Text("Do you want to delete this coordinate?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await DatabaseHelper.instance.deleteCoordinate(timestamp);
                Navigator.of(context).pop();
                _loadDbCoordinatesAndUpdate(); // Recarga la lista
              },
            ),
          ],
        );
      },
    );
  }

  // Diálogo para actualizar
  void _showUpdateDialog(String timestamp, String currentLat, String currentLong) {
    TextEditingController latController = TextEditingController(text: currentLat);
    TextEditingController longController = TextEditingController(text: currentLong);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update coordinates"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: latController,
                decoration: InputDecoration(labelText: "Latitude"),
              ),
              TextField(
                controller: longController,
                decoration: InputDecoration(labelText: "Longitude"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Update"),
              onPressed: () async {
                await DatabaseHelper.instance.updateCoordinate(timestamp, latController.text, longController.text);
                Navigator.of(context).pop();
                _loadDbCoordinatesAndUpdate(); // Recarga la lista
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Persistence List'),
      ),
      body: ListView.builder(
        itemCount: _coordinates.length + _dbCoordinates.length,
        itemBuilder: (context, index) {
          if (index < _coordinates.length) {
            var coord = _coordinates[index];
            return ListTile(
              title: Text('CSV Timestamp: ${coord[0]}', style: TextStyle(color: Colors.grey)),
              subtitle: Text('Lat: ${coord[1]}, Lon: ${coord[2]}'),
            );
          } else {
            var dbIndex = index - _coordinates.length;
            var coord = _dbCoordinates[dbIndex];
            return ListTile(
              title: Text('DB Timestamp: ${coord[0]}', style: TextStyle(color: Colors.blue)),
              subtitle: Text('Lat: ${coord[1]}, Lon: ${coord[2]}', style: TextStyle(color: Colors.blue)),
              onTap: () => _showDeleteDialog(coord[0]),
              onLongPress: () => _showUpdateDialog(coord[0], coord[1], coord[2]),
            );
          }
        },
      ),
    );
  }
}