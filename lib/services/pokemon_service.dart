import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> getPokemons({int limit = 20, int offset = 0}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      
      List<Pokemon> pokemons = [];
      for (var result in results) {
        try {
          final pokemonResponse = await http.get(Uri.parse(result['url']));
          if (pokemonResponse.statusCode == 200) {
            final pokemonData = json.decode(pokemonResponse.body);
            final speciesResponse = await http.get(Uri.parse(pokemonData['species']['url']));
            if (speciesResponse.statusCode == 200) {
              final speciesData = json.decode(speciesResponse.body);
              pokemonData['species'] = speciesData;
              
              // Obtener la cadena de evolución
              if (speciesData['evolution_chain'] != null) {
                try {
                  final evolutionResponse = await http.get(
                    Uri.parse(speciesData['evolution_chain']['url']),
                  );
                  if (evolutionResponse.statusCode == 200) {
                    final evolutionData = json.decode(evolutionResponse.body);
                    final List<String> evolutions = [];
                    _extractEvolutions(evolutionData['chain'], evolutions);
                    pokemonData['evolutions'] = evolutions;
                  }
                } catch (e) {
                  pokemonData['evolutions'] = [];
                }
              } else {
                pokemonData['evolutions'] = [];
              }
              
              pokemons.add(Pokemon.fromJson(pokemonData));
            }
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
} 