import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  bool _isLoadingWeather = false;

  Future<void> _fetchRealTimeWeather() async {
    setState(() => _isLoadingWeather = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('El GPS está desactivado.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw Exception('Permisos de ubicación denegados.');
      }
      if (permission == LocationPermission.deniedForever)
        throw Exception('Permisos bloqueados en ajustes.');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final String apiUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current_weather=true';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['current_weather']['temperature'];
        String mensaje;
        Color colorAlerta;

        if (temp >= 35) {
          mensaje = '⚠️ ALERTA ROJA: ${temp}ºC en tu zona. ¡Peligro extremo!';
          colorAlerta = const Color(0xFFFF4757);
        } else if (temp >= 30) {
          mensaje = '🟠 ALERTA NARANJA: ${temp}ºC. Busca un Oasis.';
          colorAlerta = Colors.deepOrange;
        } else {
          mensaje = '✅ TEMPERATURA SEGURA: ${temp}ºC. Todo en orden.';
          colorAlerta = const Color(0xFF69FFDB);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mensaje,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            backgroundColor: colorAlerta,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: const Color(0xFF0A1628),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingWeather = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cyan = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Centro de Alertas')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Header visual
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.08),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.satellite_alt_rounded,
                    size: 46,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'RADAR METEOROLÓGICO',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white30,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Condiciones en tu Zona',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 40),

              // Botón GPS + API
              _AlertButton(
                icon: _isLoadingWeather
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: const Color(0xFF050D1A),
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded),
                label: _isLoadingWeather
                    ? 'Localizando...'
                    : 'COMPROBAR ALERTA EN MI ZONA',
                color: Colors.orange,
                onPressed: _isLoadingWeather ? null : _fetchRealTimeWeather,
              ),
              const SizedBox(height: 14),

              // Botón protocolo
              _AlertButton(
                icon: const Icon(Icons.health_and_safety_rounded),
                label: 'PROTOCOLO: GOLPE DE CALOR',
                color: const Color(0xFFFF4757),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Prevención Médica'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ProtocolStep(
                            number: '01',
                            text: 'Bebe agua cada 30 minutos.',
                          ),
                          _ProtocolStep(
                            number: '02',
                            text: 'Evita el sol en las horas centrales.',
                          ),
                          _ProtocolStep(
                            number: '03',
                            text: 'Usa el mapa para buscar refugios.',
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          child: const Text('ENTENDIDO'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cyan.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: cyan.withOpacity(0.6),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Datos en tiempo real via Open-Meteo API. Precisión alta.',
                        style: GoogleFonts.poppins(
                          color: Colors.white30,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _AlertButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolStep extends StatelessWidget {
  final String number;
  final String text;
  const _ProtocolStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            number,
            style: GoogleFonts.poppins(
              color: cyan,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
