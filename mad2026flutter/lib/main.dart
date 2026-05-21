import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generado por flutterfire
import 'app.dart';             // Importamos tu clase MyApp

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enciende Firebase antes de que arranque la interfaz
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}