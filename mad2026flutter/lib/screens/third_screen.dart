import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para decodificar el JSON

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  bool _isLoadingWeather = false;

  // Llamada a la API pública de Open-Meteo
  Future<void> _fetchRealTimeWeather() async {
    setState(() { _isLoadingWeather = true; });
    try {
      // Coordenadas de Madrid integradas en la petición
      final response = await http.get(Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=40.4168&longitude=-3.7038&current_weather=true'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['current_weather']['temperature'];

        String mensaje;
        Color colorAlerta;

        // Lógica dinámica según el calor real
        if (temp >= 35) {
          mensaje = '⚠️ ALERTA ROJA: $tempºC en Madrid. ¡Peligro extremo!';
          colorAlerta = Colors.red;
        } else if (temp >= 30) {
          mensaje = '🟠 ALERTA NARANJA: $tempºC. Busca un Oasis cercano.';
          colorAlerta = Colors.deepOrange;
        } else {
          mensaje = '🟢 TEMPERATURA SEGURA: $tempºC. Todo en orden.';
          colorAlerta = Colors.green;
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            backgroundColor: colorAlerta,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor meteorológico.'), backgroundColor: Colors.grey),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoadingWeather = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Alertas'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.satellite_alt, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 16),
            const Text(
              'Radar Meteorológico',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // BOTÓN DINÁMICO (API)
            ElevatedButton.icon(
              icon: _isLoadingWeather
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.wb_sunny),
              label: Text(_isLoadingWeather ? 'Conectando...' : 'Comprobar Estado Real (API)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _isLoadingWeather ? null : _fetchRealTimeWeather,
            ),
            const SizedBox(height: 16),

            // BOTÓN ESTÁTICO (Protocolo)
            ElevatedButton.icon(
              icon: const Icon(Icons.health_and_safety),
              label: const Text('Protocolo: Golpe de Calor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Prevención Médica'),
                      content: const Text(
                          '1. Bebe agua cada 30 min.\n\n'
                              '2. Evita el sol directo en las horas centrales.\n\n'
                              '3. Usa el mapa para buscar refugios interiores.'
                      ),
                      actions: [
                        TextButton(child: const Text('Entendido'), onPressed: () => Navigator.of(context).pop()),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}