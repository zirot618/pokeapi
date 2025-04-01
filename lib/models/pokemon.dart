class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final String description;
  final List<String> evolutions;
  final List<Map<String, dynamic>> stats;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.description,
    required this.evolutions,
    required this.stats,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    String description = 'Sin descripción disponible';
    try {
      final entries = json['species']['flavor_text_entries'] as List;
      final spanishEntry = entries.firstWhere(
        (entry) => entry['language']['name'] == 'es',
        orElse: () => entries.first,
      );
      description = spanishEntry['flavor_text']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\f', ' ');
    } catch (e) {
      // Si no se encuentra la descripción, se mantiene el valor por defecto
    }

    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['front_default'] ?? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/0.png',
      types: (json['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
      height: json['height'],
      weight: json['weight'],
      description: description,
      evolutions: (json['evolutions'] as List?)?.cast<String>() ?? [],
      stats: (json['stats'] as List)
          .map((stat) => {
                'name': stat['stat']['name'],
                'value': stat['base_stat'],
              })
          .toList(),
    );
  }
} 