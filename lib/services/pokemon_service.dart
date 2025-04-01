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
        final pokemonResponse = await http.get(Uri.parse(result['url']));
        if (pokemonResponse.statusCode == 200) {
          final pokemonData = json.decode(pokemonResponse.body);
          pokemons.add(Pokemon.fromJson(pokemonData));
        }
      }
      return pokemons;
    } else {
      throw Exception('Error al cargar los pokémons');
    }
  }
} 