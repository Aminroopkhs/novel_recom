import 'dart:convert';
import 'package:http/http.dart' as http;

// const baseUrl = "http://10.0.2.2:8000";
const baseUrl = "http://127.0.0.1:8000";

class ApiService {

  static Future signup(String u, String p) async {
    final res = await http.post(
      Uri.parse("$baseUrl/signup?username=$u&password=$p"),
    );
    return jsonDecode(res.body);
  }

  static Future login(String u, String p) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login?username=$u&password=$p"),
    );
    return jsonDecode(res.body);
  }

  static Future setGenre(int userId, String genre) async {
    await http.post(
      Uri.parse("$baseUrl/set-genre/$userId?genre=$genre"),
    );
  }

  static Future homepage(int userId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/homepage/$userId"),
    );
    return jsonDecode(res.body);
  }

  static Future addWishlist(int u, int b) async {
    await http.post(Uri.parse("$baseUrl/wishlist/$u/$b"));
  }

  static Future addLibrary(int u, int b) async {
    await http.post(Uri.parse("$baseUrl/library/$u/$b"));
  }

  static Future getWishlist(int u) async {
    final res = await http.get(Uri.parse("$baseUrl/wishlist/$u"));
    return jsonDecode(res.body);
  }

  static Future getLibrary(int u) async {
    final res = await http.get(Uri.parse("$baseUrl/library/$u"));
    return jsonDecode(res.body);
  }
  static Future removeWishlist(int userId, int bookId) async {
  await http.delete(
    Uri.parse("$baseUrl/wishlist/$userId/$bookId"),
  );
}

  static Future removeLibrary(int userId, int bookId) async {
    await http.delete(
      Uri.parse("$baseUrl/library/$userId/$bookId"),
    );
  }
  static Future getProfile(int userId) async {
  var res = await http.get(
    Uri.parse("$baseUrl/profile/$userId"),
  );

  return jsonDecode(res.body);
}
}