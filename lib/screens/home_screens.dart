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
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<PokemonProvider>().loadPokemons(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Consumer<PokemonProvider>(
        builder: (context, pokemonProvider, child) {
          if (pokemonProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (pokemonProvider.error.isNotEmpty) {
            return Center(
              child: Text(
                pokemonProvider.error,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
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
                          color: Colors.white,
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
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      pokemon.name.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.blue[900],
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: pokemon.types.map((type) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            type,
                                            style: TextStyle(
                                              color: Colors.blue[900],
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
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
                    builder: DotSwiperPaginationBuilder(
                      activeColor: Colors.white,
                      color: Colors.white70,
                    ),
                  ),
                  control: const SwiperControl(
                    color: Colors.white,
                    padding: EdgeInsets.all(16),
                  ),
                ),
              ),
              // Sección superior con título
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
                    'POKÉDEX',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
