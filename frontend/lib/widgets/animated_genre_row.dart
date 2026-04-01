import 'package:flutter/material.dart';

class AnimatedGenreRow extends StatefulWidget {
  const AnimatedGenreRow({super.key});

  @override
  State<AnimatedGenreRow> createState() => _AnimatedGenreRowState();
}

class _AnimatedGenreRowState extends State<AnimatedGenreRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(-200 * _controller.value, 0),
            child: Row(
              children: const [
                GenreChip(text: "Romance 💕"),
                GenreChip(text: "Horror 👻"),
                GenreChip(text: "Sci-Fi 🚀"),
                GenreChip(text: "Comedy 😂"),
                GenreChip(text: "Mystery 🕵️"),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GenreChip extends StatelessWidget {
  final String text;

  const GenreChip({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
