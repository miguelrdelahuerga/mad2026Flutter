import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';

class SecondScreen extends StatefulWidget {
  // Recibimos la función que hace saltar el mapa
  final Function(double, double)? onJumpToMap;

  const SecondScreen({Key? key, this.onJumpToMap}) : super(key: key);

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

  // --- MÉTODOS DE BBDD Y DIÁLOGOS (Iguales que la última vez) ---
  Future<void> _loadCoordinates() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/gps_coordinates.csv');
      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        setState(() { _coordinates = lines.map((l) => l.split(';')).toList(); });
      }
    } catch (e) {}
  }

  void _loadDbCoordinatesAndUpdate() async {
    try {
      List<Map<String, dynamic>> dbCoords = await DatabaseHelper.instance.getCoordinates();
      setState(() {
        _dbCoordinates = dbCoords.map((c) => [
          c['timestamp'].toString(), c['latitude'].toString(), c['longitude'].toString(),
          (c['type'] ?? 'water').toString(), (c['is_operational'] ?? 1).toString()
        ]).toList();
      });
    } catch (e) {}
  }

  void _showAddManualDialog() {
    TextEditingController latC = TextEditingController();
    TextEditingController lonC = TextEditingController();
    String selectedType = 'water';

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setStateSB) => AlertDialog(
              title: const Text("Añadir Oasis Manual"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: latC, decoration: const InputDecoration(labelText: "Latitud")),
                  TextField(controller: lonC, decoration: const InputDecoration(labelText: "Longitud")),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: 'water', child: Text('Fuente')),
                      DropdownMenuItem(value: 'shade', child: Text('Sombra')),
                      DropdownMenuItem(value: 'indoor', child: Text('Refugio')),
                    ],
                    onChanged: (val) { setStateSB(() { selectedType = val!; }); },
                  ),
                ],
              ),
              actions: [
                TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.of(context).pop()),
                ElevatedButton(
                  child: const Text("Guardar"),
                  onPressed: () async {
                    double? lat = double.tryParse(latC.text);
                    double? lon = double.tryParse(lonC.text);
                    if (lat != null && lon != null) {
                      await DatabaseHelper.instance.insertManualCoordinate(lat, lon, type: selectedType);
                      Navigator.of(context).pop();
                      _loadDbCoordinatesAndUpdate();
                    }
                  },
                ),
              ],
            )
        )
    );
  }

  void _showDeleteDialog(String timestamp) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Eliminar Oasis"),
          content: const Text("¿Borrar permanentemente?"),
          actions: [
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
        )
    );
  }

  void _showUpdateDialog(String ts, String lat, String lon, String t, String op) {
    TextEditingController latC = TextEditingController(text: lat);
    TextEditingController lonC = TextEditingController(text: lon);
    String selType = t;
    bool isOp = op == '1';

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setStateSB) => AlertDialog(
              title: const Text("Actualizar"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: latC, decoration: const InputDecoration(labelText: "Latitud")),
                  TextField(controller: lonC, decoration: const InputDecoration(labelText: "Longitud")),
                  DropdownButtonFormField<String>(
                    value: selType,
                    items: const [
                      DropdownMenuItem(value: 'water', child: Text('Fuente')),
                      DropdownMenuItem(value: 'shade', child: Text('Sombra')),
                      DropdownMenuItem(value: 'indoor', child: Text('Refugio')),
                    ],
                    onChanged: (val) { setStateSB(() { selType = val!; }); },
                  ),
                  SwitchListTile(title: const Text('¿Operativo?'), value: isOp, onChanged: (v) { setStateSB(() { isOp = v; }); })
                ],
              ),
              actions: [
                TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.of(context).pop()),
                TextButton(
                  child: const Text("Guardar"),
                  onPressed: () async {
                    await DatabaseHelper.instance.updateCoordinate(ts, latC.text, lonC.text, selType, isOp ? 1 : 0);
                    Navigator.of(context).pop();
                    _loadDbCoordinatesAndUpdate();
                  },
                ),
              ],
            )
        )
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
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDbCoordinatesAndUpdate)],
      ),
      body: ListView.builder(
        itemCount: _coordinates.length + _dbCoordinates.length,
        itemBuilder: (context, index) {
          if (index < _coordinates.length) {
            var coord = _coordinates[index];
            return ListTile(title: Text('Histórico: ${coord[0]}'), subtitle: Text('Lat: ${coord[1]}, Lon: ${coord[2]}'));
          } else {
            var dbIndex = index - _coordinates.length;
            var coord = _dbCoordinates[dbIndex];
            bool op = coord[4] == '1';

            return ListTile(
              leading: Icon(
                coord[3] == 'water' ? Icons.water_drop : (coord[3] == 'shade' ? Icons.park : Icons.ac_unit),
                color: op ? Colors.blue : Colors.red,
              ),
              title: Text(_translateType(coord[3]), style: TextStyle(color: op ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold)),
              subtitle: Text('Lat: ${coord[1]}\nLon: ${coord[2]}'),
              isThreeLine: true,
              // Botón de borrar movido a la derecha
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _showDeleteDialog(coord[0]),
              ),
              // Al tocar un elemento de la lista saltamos al mapa gracias a la función _jumpToMap
              onTap: () {
                if (widget.onJumpToMap != null) {
                  double lat = double.parse(coord[1]);
                  double lon = double.parse(coord[2]);
                  widget.onJumpToMap!(lat, lon);
                }
              },
              onLongPress: () => _showUpdateDialog(coord[0], coord[1], coord[2], coord[3], coord[4]),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddManualDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}