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
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.blue[900],
        ),
        home: const HomeScreens(),
      ),
    );
  }
}
