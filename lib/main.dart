import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screens.dart';
import 'providers/pokemon_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PokemonProvider(),
      child: MaterialApp(
        title: 'Pokédex',
        theme: ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
        ),
        home: const HomeScreens(),
      ),
    );
  }
}
