import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokemonProvider with ChangeNotifier {
  final PokemonService _pokemonService = PokemonService();
  List<Pokemon> _pokemons = [];
  bool _isLoading = false;
  String _error = '';
  int _currentPage = 0;
  bool _hasMore = true;

  List<Pokemon> get pokemons => _pokemons;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadPokemons({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _currentPage = 0;
      _pokemons = [];
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newPokemons = await _pokemonService.getPokemons(page: _currentPage);
      if (newPokemons.isEmpty) {
        _hasMore = false;
      } else {
        _pokemons.addAll(newPokemons);
        _currentPage++;
      }
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadPokemons(refresh: true);
  }
} 