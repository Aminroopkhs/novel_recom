import 'package:flutter/material.dart';
// import 'package:novel_recommendation_app/screens/auth/login_screen.dart';
// import 'package:novel_recommendation_app/screens/home/home_screen.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';

class GenreSelectionScreen extends StatefulWidget {
  final int userId;
  const GenreSelectionScreen({super.key, required this.userId});

  @override
  State<GenreSelectionScreen> createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  List<String> genres = [];
  Set<String> selectedGenres = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadGenres();
    // print("User ID in GenreSelectionScreen: ${widget.userId}");
  }

  Future<void> loadGenres() async {
    try {
      final result = await ApiService.fetchGenres();
      setState(() {
        genres = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load genres";
        isLoading = false;
      });
    }
  }

  Future<void> savePreferences() async {
    if (selectedGenres.isEmpty) {
      setState(() {
        errorMessage = "Please select at least one genre";
      });
      return;
    }

    try {
      await ApiService.saveUserGenres(
        userId: widget.userId,
        genres: selectedGenres.toList(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(userId: widget.userId)),
      );
    } catch (e) {
      setState(() {
        errorMessage = "Could not save preferences";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Choose your genres",
          style: TextStyle(color: Color(0xFF3D3047)),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF3D3047)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Select what you love to read 📚",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D3047),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---------- ERROR ----------
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6EA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFB3261E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Color(0xFF3D3047)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ---------- GENRES ----------
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: genres.map((genre) {
                        final isSelected = selectedGenres.contains(genre);
                        return ChoiceChip(
                          label: Text(genre),
                          selected: isSelected,
                          selectedColor: const Color(0xFF97BEDD),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3D3047),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              errorMessage = null;
                              if (selected) {
                                selectedGenres.add(genre);
                              } else {
                                selectedGenres.remove(genre);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // ---------- CONTINUE ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF97BEDD),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: savePreferences,
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
