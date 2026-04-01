import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../../services/api_service.dart';
import '../novel/novel_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  final int userId;

  const WishlistScreen({super.key, required this.userId});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {

  late Future<List<Novel>> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  void _loadWishlist() {
    _wishlistFuture = ApiService.fetchWishlist(widget.userId);
  }

  Future<void> _removeNovel(int novelId) async {

    await ApiService.removeFromWishlist(widget.userId, novelId);

    setState(() {
      _loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
      ),

      body: FutureBuilder<List<Novel>>(
        future: _wishlistFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Your wishlist is empty"));
          }

          final novels = snapshot.data!;

          return ListView.builder(
            itemCount: novels.length,
            itemBuilder: (context, index) {

              final novel = novels[index];

              return ListTile(
                leading: Image.network(
                  novel.imageUrl,
                  width: 50,
                  fit: BoxFit.cover,
                ),

                title: Text(novel.title),
                subtitle: Text(novel.author),

                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeNovel(novel.id),
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NovelDetailScreen(userId: widget.userId, novel: novel),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}