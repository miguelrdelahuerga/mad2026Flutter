import 'package:flutter/material.dart';

class ThirdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Alertas'),
        backgroundColor: Colors.orangeAccent, // Color de alerta
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Avisos Activos en Madrid',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 1. SnackBar: Alerta Meteorológica
            ElevatedButton.icon(
              icon: const Icon(Icons.wb_sunny),
              label: const Text('Comprobar Estado del Tiempo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Aquí usamos el SnackBar que pide el snippet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ ALERTA NARANJA: Se esperan 40ºC entre las 14:00 y las 18:00. ¡Busca un oasis cercano!'),
                    backgroundColor: Colors.deepOrange,
                    duration: Duration(seconds: 4),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 2. AlertDialog: Consejos de Salud
            ElevatedButton.icon(
              icon: const Icon(Icons.health_and_safety),
              label: const Text('Protocolo: Golpe de Calor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Aquí usamos el AlertDialog que pide el snippet
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Prevención de Golpe de Calor'),
                      content: const Text(
                          '1. Bebe agua cada 30 minutos aunque no tengas sed.\n\n'
                              '2. Evita la exposición directa al sol.\n\n'
                              '3. Si sientes mareos, abre el mapa y busca un Refugio Interior inmediatamente.'
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Entendido'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. BottomSheet / SimpleDialog: Avisos de la comunidad
            ElevatedButton.icon(
              icon: const Icon(Icons.campaign),
              label: const Text('Último Aviso Comunitario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Otro elemento visual extra para sumar nota
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_damage, size: 50, color: Colors.blue),
                          SizedBox(height: 16),
                          Text(
                              'Fuente fuera de servicio',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Varios usuarios acaban de reportar que la fuente del Campus Sur no tiene agua. El mapa se ha actualizado para reflejar este corte.',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
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