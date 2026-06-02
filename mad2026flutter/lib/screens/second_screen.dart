import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';

class SecondScreen extends StatefulWidget {
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

  Future<void> _loadCoordinates() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/gps_coordinates.csv');
      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        setState(() => _coordinates = lines.map((l) => l.split(';')).toList());
      }
    } catch (e) {}
  }

  void _loadDbCoordinatesAndUpdate() async {
    try {
      List<Map<String, dynamic>> dbCoords = await DatabaseHelper.instance
          .getCoordinates();
      setState(() {
        _dbCoordinates = dbCoords
            .map(
              (c) => [
                c['timestamp'].toString(),
                c['latitude'].toString(),
                c['longitude'].toString(),
                (c['type'] ?? 'water').toString(),
                (c['is_operational'] ?? 1).toString(),
              ],
            )
            .toList();
      });
    } catch (e) {}
  }

  void _showAddManualDialog() {
    TextEditingController latC = TextEditingController();
    TextEditingController lonC = TextEditingController();
    String selectedType = 'water';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Añadir Oasis Manual'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latC,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Latitud',
                  prefixIcon: Icon(Icons.north_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lonC,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Longitud',
                  prefixIcon: Icon(Icons.east_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: const Color(0xFF0A1628),
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'water', child: Text('💧  Fuente')),
                  DropdownMenuItem(value: 'shade', child: Text('🌿  Sombra')),
                  DropdownMenuItem(value: 'indoor', child: Text('❄️  Refugio')),
                ],
                onChanged: (val) => setS(() => selectedType = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('GUARDAR'),
              onPressed: () async {
                double? lat = double.tryParse(latC.text);
                double? lon = double.tryParse(lonC.text);
                if (lat != null && lon != null) {
                  await DatabaseHelper.instance.insertManualCoordinate(
                    lat,
                    lon,
                    type: selectedType,
                  );
                  Navigator.of(ctx).pop();
                  _loadDbCoordinatesAndUpdate();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String timestamp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Oasis'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              foregroundColor: Colors.white,
            ),
            child: const Text('ELIMINAR'),
            onPressed: () async {
              await DatabaseHelper.instance.deleteCoordinate(timestamp);
              Navigator.of(ctx).pop();
              _loadDbCoordinatesAndUpdate();
            },
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(
    String ts,
    String lat,
    String lon,
    String t,
    String op,
  ) {
    TextEditingController latC = TextEditingController(text: lat);
    TextEditingController lonC = TextEditingController(text: lon);
    String selType = t;
    bool isOp = op == '1';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Actualizar Oasis'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latC,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Latitud'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lonC,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Longitud'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selType,
                dropdownColor: const Color(0xFF0A1628),
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'water', child: Text('💧  Fuente')),
                  DropdownMenuItem(value: 'shade', child: Text('🌿  Sombra')),
                  DropdownMenuItem(value: 'indoor', child: Text('❄️  Refugio')),
                ],
                onChanged: (val) => setS(() => selType = val!),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text(
                  '¿Operativo?',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                value: isOp,
                onChanged: (v) => setS(() => isOp = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('GUARDAR'),
              onPressed: () async {
                double? parsedLat = double.tryParse(latC.text);
                double? parsedLon = double.tryParse(lonC.text);

                if (parsedLat != null && parsedLon != null) {
                  await DatabaseHelper.instance.updateCoordinate(
                    ts,
                    parsedLat,
                    parsedLon,
                    selType,
                    isOp ? 1 : 0,
                  );
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  _loadDbCoordinatesAndUpdate();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, introduce coordenadas válidas.',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _translateType(String type) {
    if (type == 'water') return 'Fuente de Agua';
    if (type == 'shade') return 'Zona de Sombra';
    if (type == 'indoor') return 'Refugio Interior';
    return 'Desconocido';
  }

  IconData _iconForType(String type) {
    if (type == 'shade') return Icons.park_rounded;
    if (type == 'indoor') return Icons.ac_unit_rounded;
    return Icons.water_drop_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cyan = theme.colorScheme.primary;
    final total = _coordinates.length + _dbCoordinates.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar de Oasis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDbCoordinatesAndUpdate,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: total == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.radar_rounded,
                    size: 64,
                    color: cyan.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin Oasis registrados',
                    style: GoogleFonts.poppins(
                      color: Colors.white30,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pulsa + para añadir el primero',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: total,
              itemBuilder: (context, index) {
                if (index < _coordinates.length) {
                  final coord = _coordinates[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white10,
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: Colors.white38,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Histórico',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${coord[1]}, ${coord[2]}',
                        style: GoogleFonts.poppins(
                          color: Colors.white30,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }

                final dbIndex = index - _coordinates.length;
                final coord = _dbCoordinates[dbIndex];
                final bool op = coord[4] == '1';
                final Color accentColor = op ? cyan : theme.colorScheme.error;

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (widget.onJumpToMap != null) {
                        widget.onJumpToMap!(
                          double.parse(coord[1]),
                          double.parse(coord[2]),
                        );
                      }
                    },
                    onLongPress: () => _showUpdateDialog(
                      coord[0],
                      coord[1],
                      coord[2],
                      coord[3],
                      coord[4],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          // Ícono con fondo circular
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor.withOpacity(0.12),
                              border: Border.all(
                                color: accentColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              _iconForType(coord[3]),
                              color: accentColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Contenido
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _translateType(coord[3]),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        op ? 'ACTIVO' : 'AVERÍA',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: accentColor,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${coord[1]}, ${coord[2]}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botón borrar
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: theme.colorScheme.error.withOpacity(0.6),
                              size: 20,
                            ),
                            onPressed: () => _showDeleteDialog(coord[0]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddManualDialog,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text(
          'Nuevo Oasis',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}
