import 'package:flutter/material.dart';
import 'dart:ui';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import '../onboarding/genre_selection_screen.dart';
import 'signup_screen.dart';

bool isValidEmail(String email) {
  return RegExp(
    r'^[a-zA-Z][a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);
}

// ─── PASTEL PALETTE ──────────────────────────────────────────────────────────
class _P {
  static const Color bg          = Color(0xFFF7F3EF);   // warm cream
  static const Color card        = Color(0xFFFFFFFF);
  static const Color rose        = Color(0xFFD4899A);   // dusty rose accent
  static const Color roseSoft    = Color(0xFFF2D5DC);
  static const Color lavender    = Color(0xFFB8A9D9);
  static const Color lavenderSoft= Color(0xFFEDE8F5);
  static const Color mint        = Color(0xFFA3C9B8);
  static const Color mintSoft    = Color(0xFFDCEDE6);
  static const Color peach       = Color(0xFFE8B99A);
  static const Color peachSoft   = Color(0xFFF5E4DA);
  static const Color textPrimary = Color(0xFF3D3047);   // deep plum
  static const Color textHint    = Color(0xFFA89BB5);
}

// ─── Mini book ───────────────────────────────────────────────────────────────
class _MiniBook extends StatelessWidget {
  final Color spineColor;
  final Color coverColor;
  final double width;
  final double height;
  final double rotation;

  const _MiniBook({
    required this.spineColor,
    required this.coverColor,
    this.width = 28,
    this.height = 40,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: coverColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(3),
            bottomRight: Radius.circular(3),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 4, offset: const Offset(1.5, 2.5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: spineColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 1.5, width: double.infinity, color: Colors.white.withOpacity(0.55)),
                    const SizedBox(height: 3),
                    Container(height: 1.5, width: width * 0.55, color: Colors.white.withOpacity(0.4)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated floating book ─────────────────────────────────────────────────
class _FloatingBook extends StatefulWidget {
  final Color spineColor;
  final Color coverColor;
  final double width;
  final double height;
  final double rotation;
  final Duration delay;

  const _FloatingBook({
    required this.spineColor,
    required this.coverColor,
    this.width = 28,
    this.height = 40,
    this.rotation = 0,
    this.delay = const Duration(),
  });

  @override
  State<_FloatingBook> createState() => _FloatingBookState();
}

class _FloatingBookState extends State<_FloatingBook>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bob;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    _bob = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    Future.delayed(widget.delay, () { if (mounted) _controller.repeat(reverse: true); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bob,
      builder: (_, child) => Transform.translate(offset: Offset(0, _bob.value), child: child),
      child: _MiniBook(
        spineColor: widget.spineColor, coverColor: widget.coverColor,
        width: widget.width, height: widget.height, rotation: widget.rotation,
      ),
    );
  }
}

// ─── Blurred atmosphere blob ────────────────────────────────────────────────
class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.38)),
      ),
    );
  }
}

// ─── LOGIN SCREEN ────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _P.bg,
        child: Stack(
          children: [
            // ── Background blobs ──────────────────────────────────────────
            Positioned(top: -70,  left: -70,                          child: _Blob(color: _P.roseSoft,    size: 250)),
            Positioned(top: size.height * 0.28, right: -90,           child: _Blob(color: _P.lavenderSoft,size: 230)),
            Positioned(bottom: -80, left: size.width * 0.25,          child: _Blob(color: _P.mintSoft,    size: 270)),
            Positioned(bottom: size.height * 0.22, left: -55,         child: _Blob(color: _P.peachSoft,   size: 190)),

            // ── Floating books ────────────────────────────────────────────
            Positioned(top: size.height * 0.07,  left: 24,  child: _FloatingBook(spineColor: _P.rose,     coverColor: _P.roseSoft,     width: 24, height: 36, rotation: -0.20, delay: const Duration(milliseconds: 0))),
            Positioned(top: size.height * 0.11,  left: 56,  child: _FloatingBook(spineColor: _P.lavender, coverColor: _P.lavenderSoft, width: 19, height: 29, rotation:  0.14, delay: const Duration(milliseconds: 450))),
            Positioned(top: size.height * 0.05,  right: 26, child: _FloatingBook(spineColor: _P.mint,     coverColor: _P.mintSoft,     width: 22, height: 34, rotation:  0.22, delay: const Duration(milliseconds: 200))),
            Positioned(top: size.height * 0.09,  right: 60, child: _FloatingBook(spineColor: _P.peach,    coverColor: _P.peachSoft,    width: 17, height: 27, rotation: -0.12, delay: const Duration(milliseconds: 600))),
            Positioned(top: size.height * 0.40,  left: 16,  child: _FloatingBook(spineColor: _P.mint,     coverColor: _P.mintSoft,     width: 20, height: 30, rotation: -0.28, delay: const Duration(milliseconds: 800))),
            Positioned(top: size.height * 0.43,  right: 20, child: _FloatingBook(spineColor: _P.lavender, coverColor: _P.lavenderSoft, width: 21, height: 32, rotation:  0.18, delay: const Duration(milliseconds: 300))),
            Positioned(bottom: size.height * 0.09, left: 32,  child: _FloatingBook(spineColor: _P.peach,    coverColor: _P.peachSoft,    width: 23, height: 35, rotation:  0.18, delay: const Duration(milliseconds: 500))),
            Positioned(bottom: size.height * 0.13, left: 64,  child: _FloatingBook(spineColor: _P.rose,     coverColor: _P.roseSoft,     width: 16, height: 25, rotation: -0.10, delay: const Duration(milliseconds: 900))),
            Positioned(bottom: size.height * 0.07, right: 28, child: _FloatingBook(spineColor: _P.lavender, coverColor: _P.lavenderSoft, width: 24, height: 36, rotation: -0.18, delay: const Duration(milliseconds: 100))),
            Positioned(bottom: size.height * 0.12, right: 60, child: _FloatingBook(spineColor: _P.mint,     coverColor: _P.mintSoft,     width: 18, height: 28, rotation:  0.24, delay: const Duration(milliseconds: 700))),

            // ── Card ──────────────────────────────────────────────────────
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: 380,
                    padding: const EdgeInsets.all(34),
                    decoration: BoxDecoration(
                      color: _P.card,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 8)),
                        BoxShadow(color: _P.rose.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, -4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 74, height: 74,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [_P.roseSoft, _P.lavenderSoft], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            boxShadow: [BoxShadow(color: _P.rose.withOpacity(0.22), blurRadius: 16, offset: const Offset(0, 4))],
                          ),
                          child: Icon(Icons.auto_stories, color: _P.rose, size: 34),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text("Welcome to BookNest", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _P.textPrimary, letterSpacing: -0.3), textAlign: TextAlign.center),
                        const SizedBox(height: 6),
                        Text("Dive into your next great read", style: TextStyle(fontSize: 14, color: _P.textHint, letterSpacing: 0.1), textAlign: TextAlign.center),

                        // Book divider
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(height: 1, width: 36, color: _P.textHint.withOpacity(0.3)),
                            const SizedBox(width: 10),
                            _MiniBook(spineColor: _P.rose,     coverColor: _P.roseSoft,     width: 13, height: 19),
                            const SizedBox(width: 5),
                            _MiniBook(spineColor: _P.lavender, coverColor: _P.lavenderSoft, width: 11, height: 17, rotation:  0.07),
                            const SizedBox(width: 5),
                            _MiniBook(spineColor: _P.mint,     coverColor: _P.mintSoft,     width: 13, height: 19, rotation: -0.05),
                            const SizedBox(width: 10),
                            Container(height: 1, width: 36, color: _P.textHint.withOpacity(0.3)),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Fields
                        CustomTextField(hint: "Email",    icon: Icons.email_outlined, controller: emailController),
                        const SizedBox(height: 14),
                        CustomTextField(hint: "Password", icon: Icons.lock_outline,   controller: passwordController, obscure: true),
                        const SizedBox(height: 28),

                        // Login
                        CustomButton(
                          text: "Login",
                          onTap: () async {
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          // ❌ empty fields
                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please fill all fields")),
                            );
                            return;
                          }

                          // ❌ invalid email
                          if (!isValidEmail(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Enter a valid email")),
                            );
                            return;
                          }

                          try {
                            final result = await ApiService.login(
                              email: email,
                              password: password,
                            );
                            print(result);

                            final bool isNewUser = result["genre"]==null;
                            final int userId = result["user_id"];

                            if (isNewUser) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GenreSelectionScreen(userId: userId),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HomeScreen(userId: userId),
                                ),
                              );
                            }
                          } catch (e) {
                            final message = e.toString().contains("Invalid")
                                ? "Invalid email or password"
                                : "Login failed. Try again";

                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(message)));
                          }
                        },
                        ),
                        const SizedBox(height: 20),

                        // Sign up link
                        TextButton(
                          onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())); },
                          style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(text: "New here? ", style: TextStyle(color: _P.textHint, fontSize: 14)),
                              TextSpan(text: "Sign up",   style: TextStyle(color: _P.rose, fontSize: 14, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}