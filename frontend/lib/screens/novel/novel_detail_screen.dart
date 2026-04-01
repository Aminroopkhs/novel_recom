import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../../services/api_service.dart';

// ─── PALETTE ─────────────────────────────────────────────
class _P {
  static const Color bg = Color(0xFFF7F3EF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF3D3047);
  static const Color textSub = Color(0xFF7A6E8A);
  static const Color textHint = Color(0xFFA89BB5);
  static const Color peach = Color(0xFFE8B99A);
  static const Color peachSoft = Color(0xFFF5E4DA);
  static const Color mint = Color(0xFFA3C9B8);
  static const Color mintSoft = Color(0xFFDCEDE6);
}

class NovelDetailScreen extends StatefulWidget {
  final Novel novel;
  final int userId;

  const NovelDetailScreen({
    super.key,
    required this.novel,
    required this.userId,
  });

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {

  bool inWishlist = false;
  bool inLibrary = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // ─────────────────────────────────────────────
  // Check if novel already exists in wishlist/library
  // ─────────────────────────────────────────────
  Future<void> _checkStatus() async {

    try {

      final wishlist =
          await ApiService.fetchWishlist(widget.userId);

      final library =
          await ApiService.fetchLibrary(widget.userId);

      setState(() {
        inWishlist =
            wishlist.any((n) => n.id == widget.novel.id);

        inLibrary =
            library.any((n) => n.id == widget.novel.id);
      });

    } catch (e) {
      debugPrint("Status check error: $e");
    }
  }

  // ─────────────────────────────────────────────
  // Toggle Wishlist
  // ─────────────────────────────────────────────
  Future<void> toggleWishlist() async {

    try {

      if (inWishlist) {

        await ApiService.removeFromWishlist(
          widget.userId,
          widget.novel.id,
        );

      } else {

        await ApiService.addToWishlist(
          widget.userId,
          widget.novel.id,
        );

      }

      setState(() {
        inWishlist = !inWishlist;
      });

    } catch (e) {
      debugPrint("Wishlist error: $e");
    }
  }

  // ─────────────────────────────────────────────
  // Toggle Library
  // ─────────────────────────────────────────────
  Future<void> toggleLibrary() async {

    try {

      if (inLibrary) {

        await ApiService.removeFromLibrary(
          widget.userId,
          widget.novel.id,
        );

      } else {

        await ApiService.addToLibrary(
          widget.userId,
          widget.novel.id,
        );

      }

      setState(() {
        inLibrary = !inLibrary;
      });

    } catch (e) {
      debugPrint("Library error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    final novel = widget.novel;

    final tropes =
        novel.tropes.split('|').map((e) => e.trim()).toList();

    return Scaffold(
      backgroundColor: _P.bg,

      appBar: AppBar(
        backgroundColor: _P.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _P.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          novel.title,
          style: const TextStyle(
            color: _P.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── COVER ─────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 20),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),

                  child: Image.network(
                    novel.imageUrl,
                    height: 320,
                    width: 220,
                    fit: BoxFit.cover,

                    errorBuilder: (_, __, ___) => Container(
                      height: 320,
                      width: 220,
                      color: _P.peachSoft,
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 64,
                        color: _P.peach,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 26),

            // ─── TITLE + AUTHOR ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    novel.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _P.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'by ${novel.author}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _P.textHint,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ─── RATING + GENRE ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),

              child: Row(
                children: [

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: _P.peachSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Row(
                      children: [

                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: _P.peach,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          '${novel.rating} (${novel.ratedBy})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _P.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Chip(label: Text(novel.genre)),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ─── TROPES ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),

              child: Wrap(
                spacing: 8,
                runSpacing: 8,

                children: tropes.map((t) {

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: _P.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _P.peachSoft),
                    ),

                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _P.textPrimary,
                      ),
                    ),
                  );

                }).toList(),
              ),
            ),

            const SizedBox(height: 26),

            // ─── SYNOPSIS ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _P.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    novel.synopsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _P.textSub,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ─── ACTION BUTTONS ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),

              child: Column(
                children: [

                  // Wishlist Button
                  ElevatedButton.icon(

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          inWishlist ? _P.peachSoft : _P.peach,
                      foregroundColor: _P.textPrimary,
                      minimumSize:
                          const Size(double.infinity, 50),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    icon: Icon(
                      inWishlist
                          ? Icons.bookmark_remove_rounded
                          : Icons.bookmark_add_rounded,
                    ),

                    label: Text(
                      inWishlist
                          ? 'Remove from Wishlist'
                          : 'Add to Wishlist',
                    ),

                    onPressed: toggleWishlist,
                  ),

                  const SizedBox(height: 14),

                  // Library Button
                  ElevatedButton.icon(

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          inLibrary ? _P.mintSoft : _P.mint,
                      foregroundColor: _P.textPrimary,
                      minimumSize:
                          const Size(double.infinity, 50),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    icon: Icon(
                      inLibrary
                          ? Icons.remove_circle_outline
                          : Icons.library_add_rounded,
                    ),

                    label: Text(
                      inLibrary
                          ? 'Remove from Library'
                          : 'Add to Library',
                    ),

                    onPressed: toggleLibrary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}