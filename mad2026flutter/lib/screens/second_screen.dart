import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  // 1. Variable para almacenar las coordenadas leídas [cite: 1155]
  List<List<String>> _coordinates = [];

  @override
  void initState() {
    super.initState();
    print("initState: Initial state setup.");
    // 2. Llamamos a la carga de datos al iniciar
    _loadCoordinates();
  }

  // 3. Método para leer el archivo CSV asíncronamente [cite: 1161-1168]
  Future<void> _loadCoordinates() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gps_coordinates.csv');

    // Verificamos si el archivo existe antes de leerlo
    if (await file.exists()) {
      List<String> lines = await file.readAsLines();
      setState(() {
        _coordinates = lines.map((line) => line.split(';')).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build: Building the user interface.");
    return Scaffold(
      appBar: AppBar(title: Text('Second Screen')),
      // 4. Implementación del ListView para mostrar los datos
      body: _coordinates.isEmpty
          ? Center(child: Text("No data recorded yet."))
          : ListView.builder(
              itemCount: _coordinates.length,
              itemBuilder: (context, index) {
                var coord = _coordinates[index];
                // Formateo del timestamp de milisegundos a fecha legible
                var formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(int.parse(coord[0])),
                );

                return ListTile(
                  leading: Icon(Icons.location_on, color: Colors.blue),
                  title: Text('Timestamp: $formattedDate'),
                  subtitle: Text(
                    'Latitude: ${coord[1]}, Longitude: ${coord[2]}',
                  ),
                );
              },
            ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies: Dependencies updated.");
  }

  @override
  void didUpdateWidget(SecondScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget: The widget has been updated from the parent.");
  }

  @override
  void dispose() {
    print("dispose: Cleaning up before the state is destroyed.");
    super.dispose();
  }
}
