import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db/database_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Position? _currentPosition;
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoading = true);
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
        _showError('Los permisos están denegados permanentemente.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = position);
    } catch (e) {
      _showError('Error al obtener la ubicación: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
    setState(() => _isLoading = false);
  }

  void _showAddOasisDialog() {
    if (_currentPosition == null) return;
    String selectedType = 'water';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Registrar Oasis'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Aquí el chip ya no lleva Expanded interno, por lo que no romperá el diálogo
              _CoordChip(
                label: 'LAT',
                value: _currentPosition!.latitude.toStringAsFixed(5),
              ),
              const SizedBox(height: 6),
              _CoordChip(
                label: 'LON',
                value: _currentPosition!.longitude.toStringAsFixed(5),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: const Color(0xFF0A1628),
                decoration: const InputDecoration(labelText: 'Tipo de Oasis'),
                items: const [
                  DropdownMenuItem(
                    value: 'water',
                    child: Text('💧   Fuente de agua'),
                  ),
                  DropdownMenuItem(
                    value: 'shade',
                    child: Text('🌿   Zona de sombra'),
                  ),
                  DropdownMenuItem(
                    value: 'indoor',
                    child: Text('❄️   Refugio Interior'),
                  ),
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
                await DatabaseHelper.instance.insertManualCoordinate(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  type: selectedType,
                );
                if (!mounted) return;
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Oasis registrado en el Radar!'),
                    backgroundColor: Color(0xFF69FFDB),
                  ),
                );
                setState(() => _currentPosition = null);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cyan = theme.colorScheme.primary;
    final mint = theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Sensor de Ubicación')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            // 🎯 SOLUCIÓN AL CENTRADO: Reparte los espacios muertos de forma equitativa
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícono pulsante central
              Center(
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cyan.withOpacity(0.4),
                        width: 2,
                      ),
                      color: cyan.withOpacity(0.06),
                      boxShadow: [
                        BoxShadow(
                          color: cyan.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(Icons.gps_fixed_rounded, size: 52, color: cyan),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'SENSOR GPS',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white30,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Captura tu Posición',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? Column(
                        key: const ValueKey('loading'),
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: cyan,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Localizando...',
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: SizedBox(
                          width:
                              260, // Ancho controlado y estético para el botón
                          child: ElevatedButton.icon(
                            key: const ValueKey('button'),
                            icon: const Icon(
                              Icons.location_searching_rounded,
                              size: 18,
                            ),
                            label: const Text('CAPTURAR MI UBICACIÓN'),
                            onPressed: _getLocation,
                          ),
                        ),
                      ),
              ),

              // Espaciador dinámico condicional para que la tarjeta de abajo guarde proporción
              if (_currentPosition != null) const SizedBox(height: 32),

              // Card de posición capturada
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _currentPosition != null
                    ? Column(
                        key: const ValueKey('position'),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A1628),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: mint.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.my_location_rounded,
                                      size: 16,
                                      color: mint,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'POSICIÓN CAPTURADA',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: mint,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    // 🛠️ El 'Expanded' se aplica aquí afuera, en la fila donde sí corresponde distribuirse
                                    Expanded(
                                      child: _CoordChip(
                                        label: 'LAT',
                                        value: _currentPosition!.latitude
                                            .toStringAsFixed(5),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _CoordChip(
                                        label: 'LON',
                                        value: _currentPosition!.longitude
                                            .toStringAsFixed(5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.add_location_alt_rounded,
                                size: 18,
                              ),
                              label: const Text('AÑADIR PUNTO DE OASIS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mint,
                                foregroundColor: const Color(0xFF050D1A),
                              ),
                              onPressed: _showAddOasisDialog,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoordChip extends StatelessWidget {
  final String label;
  final String value;
  const _CoordChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;

    // ✨ Se eliminó el Expanded de la raíz del widget para independizarlo
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cyan.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cyan,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
