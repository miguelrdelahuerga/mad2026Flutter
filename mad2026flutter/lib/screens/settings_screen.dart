import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Función real para cerrar sesión en Firebase
    Future<void> _signOut() async {
      await FirebaseAuth.instance.signOut();
      // Al igual que en el login, el StreamBuilder del main.dart
      // detectará que la sesión ha muerto y te echará al Login automáticamente.
    }

    // Diálogo de confirmación exacto del snippet
    Future<void> _showLogoutConfirmationDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // Obliga a pulsar un botón para salir
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to logout?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Logout'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo de alerta
                  _signOut(); // Llama a Firebase para destruir la sesión
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ElevatedButton(
          onPressed: _showLogoutConfirmationDialog,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}