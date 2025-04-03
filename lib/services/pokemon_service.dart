import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const int _pageSize = 50;
  static Map<String, dynamic> _cache = {};

  Future<List<Pokemon>> getPokemons({int page = 0}) async {
    final offset = page * _pageSize;
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon?limit=$_pageSize&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      
      List<Pokemon> pokemons = [];
      for (var result in results) {
        try {
          final pokemon = await _getPokemonDetails(result['url']);
          if (pokemon != null) {
            pokemons.add(pokemon);
          }
        } catch (e) {
          print('Error al cargar el Pokémon ${result['name']}: $e');
          continue;
        }
      }
      return pokemons;
    } else {
      throw Exception('Error al cargar los pokémons');
    }
  }

  Future<Pokemon?> _getPokemonDetails(String url) async {
    if (_cache.containsKey(url)) {
      return Pokemon.fromJson(_cache[url]);
    }

    final pokemonResponse = await http.get(Uri.parse(url));
    if (pokemonResponse.statusCode == 200) {
      final pokemonData = json.decode(pokemonResponse.body);
      
      // Cargar datos de especie de forma asíncrona
      final speciesUrl = pokemonData['species']['url'];
      final speciesData = await _getSpeciesData(speciesUrl);
      pokemonData['species'] = speciesData;
      
      // Cargar evolución de forma asíncrona
      if (speciesData['evolution_chain'] != null) {
        try {
          final evolutionUrl = speciesData['evolution_chain']['url'];
          final evolutionData = await _getEvolutionData(evolutionUrl);
          final List<String> evolutions = [];
          _extractEvolutions(evolutionData['chain'], evolutions);
          pokemonData['evolutions'] = evolutions;
        } catch (e) {
          pokemonData['evolutions'] = [];
        }
      } else {
        pokemonData['evolutions'] = [];
      }
      
      _cache[url] = pokemonData;
      return Pokemon.fromJson(pokemonData);
    }
    return null;
  }

  Future<Map<String, dynamic>> _getSpeciesData(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _cache[url] = data;
      return data;
    }
    throw Exception('Error al cargar datos de especie');
  }

  Future<Map<String, dynamic>> _getEvolutionData(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _cache[url] = data;
      return data;
    }
    throw Exception('Error al cargar datos de evolución');
  }

  void _extractEvolutions(Map<String, dynamic> chain, List<String> evolutions) {
    if (chain['species'] != null) {
      evolutions.add(chain['species']['name']);
    }
    if (chain['evolves_to'] != null && chain['evolves_to'].isNotEmpty) {
      for (var evolution in chain['evolves_to']) {
        _extractEvolutions(evolution, evolutions);
      }
    }
  }

  Future<int> getPokemonIdByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pokemon/$name'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'];
      }
    } catch (e) {
      print('Error al obtener ID del Pokémon $name: $e');
    }
    return 1;
  }
} 