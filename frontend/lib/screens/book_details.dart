import 'package:flutter/material.dart';
import '../services/api.dart';

class BookDetails extends StatelessWidget {
  final int userId;
  final dynamic book;

  BookDetails({required this.userId, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F2F2),

      appBar: AppBar(
        title: Text(book['title'] ?? ""),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 📚 BOOK ICON (NO NETWORK IMAGE)
            Center(
              child: Container(
                height: 180,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(Icons.menu_book, size: 60),
                ),
              ),
            ),

            SizedBox(height: 20),

            /// 📖 TITLE
            Text(
              book['title'] ?? "",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 5),

            /// ✍️ AUTHOR
            Text(
              "by ${book['author'] ?? "Unknown"}",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 10),

            /// ⭐ RATING + GENRE
            Row(
              children: [

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.orange),
                      SizedBox(width: 4),
                      Text("${book['rating'] ?? 'N/A'}"),
                    ],
                  ),
                ),

                SizedBox(width: 10),

                if (book['genre'] != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(book['genre']),
                  ),
              ],
            ),

            SizedBox(height: 10),

            /// 🏷️ TROPES
            if (book['tropes'] != null)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(book['tropes']),
              ),

            SizedBox(height: 20),

            /// 📜 SYNOPSIS
            Text(
              "Synopsis",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 5),

            Text(book['synopsis'] ?? "No description available"),

            SizedBox(height: 30),

            /// ❤️ ADD TO WISHLIST
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.favorite_border),
                label: Text("Add to Wishlist"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade200,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  await ApiService.addWishlist(userId, book['id']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Added to Wishlist")),
                  );
                },
              ),
            ),

            SizedBox(height: 10),

            /// ❌ REMOVE FROM WISHLIST
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.delete),
                label: Text("Remove from Wishlist"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade200,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  await ApiService.removeWishlist(userId, book['id']);
                  Navigator.pop(context);
                },
              ),
            ),

            SizedBox(height: 15),

            /// 📚 ADD TO LIBRARY
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.library_add),
                label: Text("Add to Library"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade200,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  await ApiService.addLibrary(userId, book['id']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Added to Library")),
                  );
                },
              ),
            ),

            SizedBox(height: 10),

            /// ❌ REMOVE FROM LIBRARY
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.delete_outline),
                label: Text("Remove from Library"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  await ApiService.removeLibrary(userId, book['id']);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}