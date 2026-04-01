import 'package:flutter/material.dart';
import '../services/api.dart';
import 'book_details.dart';

class LibraryPage extends StatefulWidget {
  final int userId;
  LibraryPage({required this.userId});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  var books;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    var res = await ApiService.getLibrary(widget.userId);
    setState(() {
      books = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (books == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Library")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (books.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Library")),
        body: Center(child: Text("No Library items")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Library")),
      body: ListView(
        children: books.map<Widget>((b) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),

              /// 📘 ICON (NO IMAGE BUG)
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book),
              ),

              /// TITLE
              title: Text(
                b['title'] ?? "No Title",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              /// AUTHOR
              subtitle: Text(
                "by ${b['author'] ?? 'Unknown'}",
                style: TextStyle(color: Colors.grey),
              ),

              /// RATING
              trailing: Text("⭐ ${b['rating']?.toString() ?? ''}"),

              /// 🔥 NAVIGATION TO DETAILS
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetails(
                      userId: widget.userId,
                      book: b,
                    ),
                  ),
                ).then((_) => load()); // refresh after back
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}