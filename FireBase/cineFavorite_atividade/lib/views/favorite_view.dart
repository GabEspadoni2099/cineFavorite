import 'dart:io';

import 'package:cinefavorite_atvd/controllers/movie_firestore_controller.dart';
import 'package:cinefavorite_atvd/models/movie.dart';
import 'package:cinefavorite_atvd/views/search_movie_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Novas cores baseadas no Figma
const Color kDarkBlue = Color(0xFF0B0B5B);
const Color kStrongBlue = Color(0xFF3000FF);
const Color kLightGray = Color(0xFFD9D9D9);
const Color kGreen = Color(0xFF58E68A);
const Color kRed = Color(0xFFE50914);
const Color kYellow = Color(0xFFFDD835);
const Color kCyan = Color(0xFF00BCD4);

class FavoriteView extends StatelessWidget {
  final _movieController = MovieFirestoreController();
  FavoriteView({super.key});

  void _avaliarFilme(BuildContext context, Movie movie) async {
    double novaNota = movie.rating;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kDarkBlue,
          title: const Text("Avaliar Filme", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nota: ${novaNota.toStringAsFixed(1)}", style: TextStyle(color: Colors.white)),
              Slider(
                value: novaNota,
                min: 0,
                max: 10,
                divisions: 20,
                activeColor: kGreen,
                inactiveColor: kLightGray,
                label: novaNota.toStringAsFixed(1),
                onChanged: (value) {
                  novaNota = value;
                  (context as Element).markNeedsBuild();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: kLightGray)),
            ),
            ElevatedButton(
              onPressed: () async {
                _movieController.updateMovieRating(movie.id, novaNota);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  void _removerFilme(BuildContext context, Movie movie) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkBlue,
        title: const Text("Remover Filme", style: TextStyle(color: Colors.white)),
        content: Text(
          "Deseja remover '${movie.title}' dos favoritos?",
          style: const TextStyle(color: kLightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar", style: TextStyle(color: kLightGray)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            child: const Text("Remover"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _movieController.removeMovie(movie.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBlue,
      appBar: AppBar(
        backgroundColor: kStrongBlue,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 20, // barra mínima visual como no Figma
      ),
      body: StreamBuilder<List<Movie>>(
        stream: _movieController.getFavoriteMovies(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Erro ao carregar favoritos", style: TextStyle(color: Colors.white)),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: kGreen));
          }

          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Nenhum filme favorito", style: TextStyle(color: Colors.white)),
            );
          }

          final favoriteMovies = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = favoriteMovies[index];
              return Card(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(movie.posterPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      color: kStrongBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.star),
                            color: kYellow,
                            tooltip: "Avaliar",
                            onPressed: () => _avaliarFilme(context, movie),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: kRed,
                            tooltip: "Remover",
                            onPressed: () => _removerFilme(context, movie),
                          ),
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            color: kCyan,
                            tooltip: "Detalhes",
                            onPressed: () {
                              // TODO: abrir detalhes se necessário
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchMovieView()),
        ),
        backgroundColor: kGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: BottomAppBar(
        color: kStrongBlue,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(height: 40),
      ),
    );
  }
}
