import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/book_card.dart';
import '../widgets/section_title.dart';
import '../screens/wishlist.dart';
import '../screens/library.dart';
import '../screens/book_details.dart';
import '../screens/profile_page.dart';

class HomePage extends StatefulWidget {
  final int userId;
  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var data;
  bool isLoading = true;
  String error = "";
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    try {
      var res = await ApiService.homepage(widget.userId);
      setState(() {
        data = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F4FF),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6B21A8)),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F4FF),
        body: Center(
          child: Text("Error: $error",
              style: const TextStyle(color: Colors.redAccent)),
        ),
      );
    }

    final recommended = data['recommended'] ?? [];
    final randomBooks = data['random'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),

      // ── APP BAR ──────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B21A8),
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        title: const Text(
          "Discover",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      // ── BOTTOM NAV BAR ────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6B21A8),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 12,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WishlistPage(userId: widget.userId),
              ),
            );
          } else if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LibraryPage(userId: widget.userId),
              ),
            );
          } else if (i == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(userId: widget.userId),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: "Library",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),

      // ── MAIN CONTENT ──────────────────────────────────────────
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── RECOMMENDED SECTION ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recommended",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A0033),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See all",
                      style: TextStyle(
                        color: Color(0xFF6B21A8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            recommended.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No recommendations found"),
                  )
                : SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      itemCount: recommended.length,
                      itemBuilder: (context, index) {
                        final b = recommended[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetails(
                                userId: widget.userId,
                                book: b,
                              ),
                            ),
                          ),
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cover image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: (b['image'] != null &&
                                          b['image'] != "")
                                      ? Image.network(
                                          b['image'],
                                          width: 130,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 130,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFD8B4FE),
                                                Color(0xFF9333EA),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.menu_book,
                                            color: Colors.white,
                                            size: 48,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 6),
                                // Title
                                Text(
                                  b['title'] ?? "No Title",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF1A0033),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Rating
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Color(0xFFF59E0B), size: 14),
                                    const SizedBox(width: 3),
                                    Text(
                                      "${b['rating'] ?? '—'}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            // ── EXPLORE SECTION ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Explore",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A0033),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See all",
                      style: TextStyle(
                        color: Color(0xFF6B21A8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            randomBooks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No books available"),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: randomBooks.take(12).map<Widget>((b) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetails(
                                userId: widget.userId,
                                book: b,
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.shade50,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: (b['image'] != null &&
                                          b['image'] != "")
                                      ? Image.network(
                                          b['image'],
                                          width: 52,
                                          height: 68,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 52,
                                          height: 68,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFE9D5FF),
                                                Color(0xFFC084FC),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.menu_book,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 14),
                                // Text info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b['title'] ?? "No Title",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Color(0xFF1A0033),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "by ${b['author'] ?? 'Unknown'}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (b['rating'] != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Color(0xFFF59E0B),
                                                size: 13),
                                            const SizedBox(width: 3),
                                            Text(
                                              "${b['rating']}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}