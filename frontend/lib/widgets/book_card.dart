import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final dynamic book;

  BookCard(this.book);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// BOOK COVER (WITH FALLBACK)
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
  book['image'] ?? "",
  height: 120,
  fit: BoxFit.cover,
  errorBuilder: (_, __, ___) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.menu_book, size: 40),
    );
  },
),
            ),
          ),

          SizedBox(height: 8),

          /// TITLE
          Text(
            book['title'] ?? "No Title",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 4),

          /// RATING
          Row(
            children: [
              Icon(Icons.star, size: 14, color: Colors.orange),
              SizedBox(width: 4),
              Text(
                "${book['rating'] ?? 'N/A'}",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}