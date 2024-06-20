import 'package:flutter/material.dart';
import 'package:garagem/route_generation.dart';
import 'package:garagem/views/anuncios.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:provider/provider.dart';

final ThemeData temaPadrao = ThemeData(
  primaryColor: const Color(0xFF000080), // Cor primária do aplicativo
  colorScheme: const ColorScheme.light().copyWith(
    primary: const Color(0xFF000080), // Cor primária do esquema
    secondary: const Color(0xFF0000CD), // Cor secundária / de acentuação
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicialize o Firebase
  runApp(MaterialApp(
    title: "Garagem",
    home: const Anuncios(),
    theme: temaPadrao,
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
  ));
}
