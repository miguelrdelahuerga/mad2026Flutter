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

  Future<void> _loadCoordinates() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gps_coordinates.csv');
      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        setState(() {
          _coordinates = lines.map((line) => line.split(';')).toList();
        });
      }
    } catch (e) {
      print("Error leyendo CSV");
    }
  }

  // Ahora este método lo podemos llamar con el botón de refrescar
  void _loadDbCoordinatesAndUpdate() async {
    try {
      List<Map<String, dynamic>> dbCoords = await DatabaseHelper.instance.getCoordinates();
      setState(() {
        _dbCoordinates = dbCoords.map((c) => [
          c['timestamp'].toString(),
          c['latitude'].toString(),
          c['longitude'].toString(),
          (c['type'] ?? 'water').toString(),
          (c['is_operational'] ?? 1).toString()
        ]).toList();
      });
    } catch (e) {
      print("Error cargando BBDD: $e");
    }
  }

  // --- DIÁLOGO PARA AÑADIR MANUALMENTE ---
  void _showAddManualDialog() {
    TextEditingController latController = TextEditingController();
    TextEditingController longController = TextEditingController();
    String selectedType = 'water';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setStateSB) {
              return AlertDialog(
                title: const Text("Añadir Oasis Manual"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text("Introduce las coordenadas exactas:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: latController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: const InputDecoration(labelText: "Latitud (Ej: 40.416)", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: longController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: const InputDecoration(labelText: "Longitud (Ej: -3.703)", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(labelText: 'Tipo de Oasis'),
                        items: const [
                          DropdownMenuItem(value: 'water', child: Text('Fuente de agua')),
                          DropdownMenuItem(value: 'shade', child: Text('Zona de sombra')),
                          DropdownMenuItem(value: 'indoor', child: Text('Refugio (Interior)')),
                        ],
                        onChanged: (val) {
                          setStateSB(() { selectedType = val!; });
                        },
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Cancelar"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    child: const Text("Guardar Oasis"),
                    onPressed: () async {
                      // Validamos que hayan metido números de verdad
                      double? lat = double.tryParse(latController.text);
                      double? lon = double.tryParse(longController.text);

                      if (lat != null && lon != null) {
                        await DatabaseHelper.instance.insertManualCoordinate(lat, lon, type: selectedType);
                        Navigator.of(context).pop();
                        _loadDbCoordinatesAndUpdate(); // Recarga la lista instantáneamente

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Oasis añadido con éxito!'), backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, usa formatos numéricos válidos.'), backgroundColor: Colors.red),
                        );
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  // --- DIÁLOGOS DE BORRAR Y ACTUALIZAR (SIN CAMBIOS) ---
  void _showDeleteDialog(String timestamp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar Oasis"),
          content: const Text("¿Quieres borrar este punto del mapa?"),
          actions: <Widget>[
            TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text("Borrar", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await DatabaseHelper.instance.deleteCoordinate(timestamp);
                Navigator.of(context).pop();
                _loadDbCoordinatesAndUpdate();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(String timestamp, String currentLat, String currentLong, String currentType, String currentOp) {
    TextEditingController latController = TextEditingController(text: currentLat);
    TextEditingController longController = TextEditingController(text: currentLong);
    String selectedType = currentType;
    bool isOperational = currentOp == '1';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setStateSB) {
              return AlertDialog(
                title: const Text("Actualizar Oasis"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(controller: latController, decoration: const InputDecoration(labelText: "Latitud")),
                      TextField(controller: longController, decoration: const InputDecoration(labelText: "Longitud")),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(labelText: 'Tipo de Oasis'),
                        items: const [
                          DropdownMenuItem(value: 'water', child: Text('Fuente de agua')),
                          DropdownMenuItem(value: 'shade', child: Text('Zona de sombra')),
                          DropdownMenuItem(value: 'indoor', child: Text('Refugio (Interior)')),
                        ],
                        onChanged: (val) { setStateSB(() { selectedType = val!; }); },
                      ),
                      SwitchListTile(
                        title: const Text('¿Está operativo?'),
                        value: isOperational,
                        activeColor: Colors.blue,
                        onChanged: (val) { setStateSB(() { isOperational = val; }); },
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.of(context).pop()),
                  TextButton(
                    child: const Text("Guardar"),
                    onPressed: () async {
                      await DatabaseHelper.instance.updateCoordinate(
                          timestamp, latController.text, longController.text, selectedType, isOperational ? 1 : 0
                      );
                      Navigator.of(context).pop();
                      _loadDbCoordinatesAndUpdate();
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  String _translateType(String type) {
    if (type == 'water') return 'Fuente de Agua';
    if (type == 'shade') return 'Zona de Sombra';
    if (type == 'indoor') return 'Refugio Interior';
    return 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar de Oasis'),
        actions: [
          // BOTÓN DE REFRESCO MANUAL PARA VER LOS DEL GPS
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar lista',
            onPressed: _loadDbCoordinatesAndUpdate,
          )
        ],
      ),
      body: _dbCoordinates.isEmpty
          ? const Center(child: Text("No hay oasis en el radar. \n¡Usa el GPS o añade uno manual!", textAlign: TextAlign.center))
          : ListView.builder(
        itemCount: _coordinates.length + _dbCoordinates.length,
        itemBuilder: (context, index) {
          if (index < _coordinates.length) {
            var coord = _coordinates[index];
            return ListTile(
              title: Text('Histórico: ${coord[0]}', style: const TextStyle(color: Colors.grey)),
              subtitle: Text('Lat: ${coord[1]}, Lon: ${coord[2]}'),
            );
          } else {
            var dbIndex = index - _coordinates.length;
            var coord = _dbCoordinates[dbIndex];

            bool operational = coord[4] == '1';
            String typeName = _translateType(coord[3]);

            return ListTile(
              leading: Icon(
                coord[3] == 'water' ? Icons.water_drop : (coord[3] == 'shade' ? Icons.park : Icons.ac_unit),
                color: operational ? Colors.blue : Colors.red,
              ),
              title: Text(typeName, style: TextStyle(color: operational ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold)),
              subtitle: Text('Lat: ${coord[1]}\nLon: ${coord[2]}\nEstado: ${operational ? "Funcionando" : "Fuera de servicio"}'),
              isThreeLine: true,
              onTap: () => _showDeleteDialog(coord[0]),
              onLongPress: () => _showUpdateDialog(coord[0], coord[1], coord[2], coord[3], coord[4]),
            );
          }
        },
      ),
      // BOTÓN FLOTANTE PARA AÑADIR A MANO
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddManualDialog,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Añadir Oasis'),
        backgroundColor: Colors.lightBlue,
      ),
    );
  }
}