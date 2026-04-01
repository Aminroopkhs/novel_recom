import 'package:flutter/material.dart';
import '../services/api.dart';
import 'signup.dart';
import 'home.dart';
import 'genre.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F2F2),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// ICON
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.pink.shade100,
                child: Icon(Icons.menu_book, color: Colors.pink),
              ),

              SizedBox(height: 20),

              /// TITLE
              Text("Welcome to BookNest",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              SizedBox(height: 5),

              Text("Dive into your next great read",
                  style: TextStyle(color: Colors.grey)),

              SizedBox(height: 20),

              /// EMAIL FIELD
              TextField(
                controller: email,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.pink.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),

              SizedBox(height: 15),

              /// PASSWORD
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.pink.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),

              SizedBox(height: 20),

              /// LOGIN BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Login"),
                onPressed: () async {
                  setState(() => isLoading = true);

                  var res = await ApiService.login(
                      email.text, password.text);

                  setState(() => isLoading = false);

                  if (res['error'] != null) return;

                  int userId = res['user_id'];

                  if (res['genre'] == null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => GenrePage(userId: userId)));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => HomePage(userId: userId)));
                  }
                },
              ),

              SizedBox(height: 10),

              /// SIGNUP
              TextButton(
                child: Text("New here? Sign up"),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SignupPage()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}