import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokemonProvider with ChangeNotifier {
  final PokemonService _pokemonService = PokemonService();
  List<Pokemon> _pokemons = [];
  bool _isLoading = false;
  String _error = '';

  List<Pokemon> get pokemons => _pokemons;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadPokemons() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _pokemons = await _pokemonService.getPokemons();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
} 