import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../db/database_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Position? _currentPosition;
  bool _isLoading = false;

  Future<void> _getLocation() async {
    setState(() { _isLoading = true; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Los servicios de ubicación están deshabilitados.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Los permisos de ubicación fueron denegados.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Los permisos están denegados permanentemente en ajustes.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // SOLO guardamos la posición en pantalla, YA NO la subimos a SQLite aquí
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      _showError('Error al obtener la ubicación: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    setState(() { _isLoading = false; });
  }

  // Nuevo Popup para añadir la coordenada mostrada
  void _showAddOasisDialog() {
    if (_currentPosition == null) return;

    String selectedType = 'water';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setStateSB) {
                return AlertDialog(
                  title: const Text("Registrar este Oasis"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Latitud: ${_currentPosition!.latitude}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Longitud: ${_currentPosition!.longitude}", style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  actions: [
                    TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.of(context).pop()),
                    ElevatedButton(
                      child: const Text("Guardar en Radar"),
                      onPressed: () async {
                        // AQUÍ es donde lo subimos de verdad a la base de datos
                        await DatabaseHelper.instance.insertManualCoordinate(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            type: selectedType
                        );
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Oasis guardado! Búscalo en el Radar.'), backgroundColor: Colors.green),
                        );

                        // Reseteamos la pantalla para el siguiente
                        setState(() { _currentPosition = null; });
                      },
                    )
                  ],
                );
              }
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor de Ubicación')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gps_fixed, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              icon: const Icon(Icons.location_searching),
              label: const Text('Capturar Mi Ubicación'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              onPressed: _getLocation,
            ),
            const SizedBox(height: 40),

            // Si ya hemos capturado la ubicación, mostramos la tarjeta
            if (_currentPosition != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Text('📍 Posición Actual:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Lat: ${_currentPosition!.latitude}'),
                    Text('Lon: ${_currentPosition!.longitude}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Añadir Punto de Oasis'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                ),
                onPressed: _showAddOasisDialog,
              ),
            ]
          ],
        ),
      ),
    );
  }
}