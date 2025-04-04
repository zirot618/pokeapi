import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import '../providers/pokemon_provider.dart';
import 'pokemon_detail_screen.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  // Mapa de colores para los tipos de Pokémon
  final Map<String, Color> typeColors = {
    'grass': Colors.green,
    'poison': Colors.purple,
    'fire': Colors.red,
    'bug': Colors.lightGreen,
    'normal': Colors.grey,
    'flying': Colors.grey[400]!,
    'electric': Colors.yellow,
    'ground': Colors.brown,
    'fairy': Colors.pink,
    'psychic': Colors.yellow[200]!,
    'dark': Colors.black,
    'steel': Colors.grey[600]!,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => context.read<PokemonProvider>().loadPokemons(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePokemons();
    }
  }

  Future<void> _loadMorePokemons() async {
    if (!_isLoadingMore) {
      _isLoadingMore = true;
      await context.read<PokemonProvider>().loadPokemons();
      _isLoadingMore = false;
    }
  }

  Color _getTypeColor(String type) {
    return typeColors[type.toLowerCase()] ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Consumer<PokemonProvider>(
        builder: (context, pokemonProvider, child) {
          if (pokemonProvider.isLoading && pokemonProvider.pokemons.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (pokemonProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pokemonProvider.error,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => pokemonProvider.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => pokemonProvider.refresh(),
            child: Stack(
              children: [
                // Título en la parte superior
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue[900]!,
                        Colors.blue[900]!.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'PokeApi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Sección inferior con lista de Pokémon
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Swiper(
                    itemBuilder: (context, index) {
                      final pokemon = pokemonProvider.pokemons[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokemonDetailScreen(
                                pokemon: pokemon,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: pokemon.imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 8,
                                    bottom: 16,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        pokemon.name.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black12,
                                              offset: Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        alignment: WrapAlignment.center,
                                        children: pokemon.types.map((type) {
                                          final typeColor = _getTypeColor(type);
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: typeColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: typeColor,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              type,
                                              style: TextStyle(
                                                color: typeColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black.withOpacity(0.2),
                                                    offset: const Offset(1, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: pokemonProvider.pokemons.length,
                    pagination: const SwiperPagination(
                      builder: FractionPaginationBuilder(
                        fontSize: 12,
                        color: Colors.black,
                        activeColor: Colors.black,
                      ),
                    ),
                    control: const SwiperControl(),
                    onIndexChanged: (index) {
                      if (index >= pokemonProvider.pokemons.length - 5) {
                        _loadMorePokemons();
                      }
                    },
                  ),
                ),
                // Indicador de carga al final de la lista
                if (_isLoadingMore)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
