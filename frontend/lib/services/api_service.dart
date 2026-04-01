import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/novel.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  // ---------- AUTH ----------

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body["detail"] ?? "Signup failed");
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final loginUri = Uri.parse("$baseUrl/login").replace(
      queryParameters: {"username": email, "password": password},
    );

    final response = await http.post(
      loginUri,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"username": email, "password": password},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Invalid email or password");
    }
  }

  // ------USER-----
  static Future<Map<String, dynamic>> fetchUser(int userId) async {

    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load user");
    }
  }
  // ---------- NOVELS ----------

  static Future<List<Novel>> fetchAllNovels() async {
    final response = await http.get(Uri.parse("$baseUrl/books"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Novel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load novels");
    }
  }

  static Future<List<String>> fetchGenres() async {
    final response = await http.get(Uri.parse("$baseUrl/genres"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data["genres"]);
    } else {
      throw Exception("Failed to load genres");
    }
  }

  // ---------- GENRES ----------

  static Future<void> saveUserGenres({
    required int userId,
    required List<String> genres,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/user/preferences"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "genres": genres}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save genres");
    }
  }

  static Future<void> addToLibrary(int userId, int novelId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/library/$userId/$novelId"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to add to library");
    }
  }

  static Future<void> addToWishlist(int userId, int novelId) async {

  final response = await http.post(
    Uri.parse("$baseUrl/wishlist/$userId/$novelId"),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to add to wishlist");
  }
}

static Future<void> removeFromWishlist(int userId, int novelId) async {

  final response = await http.post(
    Uri.parse("$baseUrl/wishlist/remove?user_id=$userId&novel_id=$novelId"),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to remove from wishlist");
  }
}

// ─────────────────────────────────────────────────────────
// WISHLIST
// ─────────────────────────────────────────────────────────

static Future<List<Novel>> fetchWishlist(int userId) async {
  final res = await http.get(Uri.parse("$baseUrl/wishlist/$userId"));
  if (res.statusCode != 200) throw Exception("Failed to fetch wishlist");

  final List data = jsonDecode(res.body);
  return data.map((e) => Novel.fromJson(e)).toList();
}


// ─────────────────────────────────────────────────────────
// LIBRARY
// ─────────────────────────────────────────────────────────

static Future<List<Novel>> fetchLibrary(int userId) async {
  final res = await http.get(Uri.parse("$baseUrl/library/$userId"));
  if (res.statusCode != 200) throw Exception("Failed to fetch library");

  final List data = jsonDecode(res.body);
  return data.map((e) => Novel.fromJson(e)).toList();
}


static Future<void> removeFromLibrary(int userId, int novelId) async {
  await http.post(
    Uri.parse("$baseUrl/library/remove"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"user_id": userId, "novel_id": novelId}),
  );
}

// static Future<List<String>> fetchUserGenres(int userId) async {
//   final response = await http.post(
//     Uri.parse("$baseUrl/user/preferences?user_id=$userId"),
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({"user_id": userId}),
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return List<String>.from(data["genres"]);
//   } else {
//     throw Exception("Failed to fetch user genres");
//   }
// }

static Future<List<String>> fetchUserGenres(int userId) async {

  final response = await http.get(
    Uri.parse("$baseUrl/user/preferences?user_id=$userId"),
  );

  if (response.statusCode == 200) {

    final data = jsonDecode(response.body);

    return List<String>.from(data["genres"]);

  } else {
    throw Exception("Failed to load genres");
  }
}



}
