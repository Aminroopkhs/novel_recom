import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../../services/api_service.dart';
import '../novel/novel_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final int userId;

  const LibraryScreen({super.key, required this.userId});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {

  late Future<List<Novel>> _libraryFuture;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  void _loadLibrary() {
    _libraryFuture = ApiService.fetchLibrary(widget.userId);
  }

  Future<void> _removeNovel(int novelId) async {

    await ApiService.removeFromLibrary(widget.userId, novelId);

    setState(() {
      _loadLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Library"),
      ),

      body: FutureBuilder<List<Novel>>(
        future: _libraryFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Your library is empty"));
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
                      builder: (_) => NovelDetailScreen(userId: widget.userId,novel: novel),
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