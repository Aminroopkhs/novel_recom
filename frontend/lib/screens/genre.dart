import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api.dart';
import 'home.dart';

// ─────────────────────────────────────────────
//  Floating book particle model
// ─────────────────────────────────────────────
class _BookParticle {
  final double startX;
  final double startY;
  final double size;
  final double speed;
  final double phase;
  final double drift;
  final IconData icon;
  final Color color;
  final double rotation;

  const _BookParticle({
    required this.startX,
    required this.startY,
    required this.size,
    required this.speed,
    required this.phase,
    required this.drift,
    required this.icon,
    required this.color,
    required this.rotation,
  });
}

// ─────────────────────────────────────────────
//  Genre model
// ─────────────────────────────────────────────
class _Genre {
  final String label;
  final IconData icon;
  final Color accent;         // chip border / icon bg when selected
  final Color chipBg;         // unselected chip bg
  final Color selectedBg;     // selected chip bg
  final Color textColor;      // label color

  const _Genre({
    required this.label,
    required this.icon,
    required this.accent,
    required this.chipBg,
    required this.selectedBg,
    required this.textColor,
  });
}

// ─────────────────────────────────────────────
//  Page
// ─────────────────────────────────────────────
class GenrePage extends StatefulWidget {
  final int userId;
  const GenrePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> with TickerProviderStateMixin {

  // Only 4 genres, pastel palette
  static const _genres = [
    _Genre(
      label: "Science Fiction",
      icon: Icons.rocket_launch_rounded,
      accent: Color(0xFF8B7CF6),
      chipBg: Color(0xFFF0EEFF),
      selectedBg: Color(0xFFDDD8FF),
      textColor: Color(0xFF5B4FCF),
    ),
    _Genre(
      label: "Horror",
      icon: Icons.nightlight_round,
      accent: Color(0xFFE07C7C),
      chipBg: Color(0xFFFFF0F0),
      selectedBg: Color(0xFFFFD6D6),
      textColor: Color(0xFFB94F4F),
    ),
    _Genre(
      label: "Romance",
      icon: Icons.favorite_rounded,
      accent: Color(0xFFE879A0),
      chipBg: Color(0xFFFFF0F6),
      selectedBg: Color(0xFFFFD6E8),
      textColor: Color(0xFFC0527A),
    ),
    _Genre(
      label: "Comedy",
      icon: Icons.sentiment_very_satisfied_rounded,
      accent: Color(0xFFD4A017),
      chipBg: Color(0xFFFFFBEE),
      selectedBg: Color(0xFFFFF0C2),
      textColor: Color(0xFFAA7F0A),
    ),
  ];

  final Set<int> _selected = {};
  bool _loading = false;

  late final List<_BookParticle> _particles;
  late final AnimationController _floatCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _btnCtrl;
  late final List<AnimationController> _tapCtrls;
  late final List<Animation<double>> _tapScales;

  @override
  void initState() {
    super.initState();

    final rng = Random(42);
    final icons = [
      Icons.menu_book_rounded,
      Icons.auto_stories_rounded,
      Icons.book_rounded,
      Icons.library_books_rounded,
      Icons.bookmark_rounded,
      Icons.import_contacts_rounded,
      Icons.chrome_reader_mode_rounded,
    ];
    // Soft pastel particle colors
    final colors = [
      const Color(0xFFB39DDB),
      const Color(0xFFF48FB1),
      const Color(0xFF80DEEA),
      const Color(0xFFFFCC80),
      const Color(0xFFA5D6A7),
      const Color(0xFFEF9A9A),
      const Color(0xFF90CAF9),
    ];

    _particles = List.generate(18, (i) => _BookParticle(
      startX:   rng.nextDouble(),
      startY:   rng.nextDouble(),
      size:     16 + rng.nextDouble() * 22,
      speed:    0.4 + rng.nextDouble() * 0.6,
      phase:    rng.nextDouble(),
      drift:    10 + rng.nextDouble() * 20,
      icon:     icons[i % icons.length],
      color:    colors[i % colors.length].withOpacity(0.30 + rng.nextDouble() * 0.30),
      rotation: (rng.nextDouble() - 0.5) * pi / 2.5,
    ));

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))..forward();
    _btnCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));

    _tapCtrls = List.generate(_genres.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 100)));
    _tapScales = _tapCtrls.map((c) =>
      Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeOut))
    ).toList();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _entryCtrl.dispose();
    _btnCtrl.dispose();
    for (final c in _tapCtrls) c.dispose();
    super.dispose();
  }

  void _toggle(int i) {
    if (_loading) return;
    setState(() => _selected.contains(i) ? _selected.remove(i) : _selected.add(i));
  }

  Future<void> _confirm() async {
    if (_selected.isEmpty || _loading) return;
    setState(() => _loading = true);

    for (final i in _selected) {
      await ApiService.setGenre(widget.userId, _genres[i].label);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => HomePage(userId: widget.userId),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeIn), child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          // ── Pastel gradient background ───────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDEFF4), Color(0xFFF3EFFF), Color(0xFFECF6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Soft blobs ───────────────────────
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8DDFF).withOpacity(0.55),
              ),
            ),
          ),
          Positioned(
            bottom: -80, left: -50,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD6E8).withOpacity(0.45),
              ),
            ),
          ),

          // ── Floating book particles ──────────
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, __) => Stack(
              children: _particles.map((p) {
                final t   = (_floatCtrl.value + p.phase) % 1.0;
                final s   = sin(t * pi);
                final y   = p.startY * size.height - s * 50 * p.speed;
                final x   = p.startX * size.width  + sin(t * pi * 2) * p.drift;
                final rot = p.rotation + s * 0.15;
                return Positioned(
                  left: x, top: y,
                  child: Transform.rotate(
                    angle: rot,
                    child: Icon(p.icon, size: p.size, color: p.color),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Main content ─────────────────────
          SafeArea(
            child: AnimatedBuilder(
              animation: _entryCtrl,
              builder: (_, child) {
                final t = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack).value.clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, 28 * (1 - t)),
                  child: Opacity(opacity: t, child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    Expanded(child: _buildChips()),
                    const SizedBox(height: 16),
                    _buildContinueButton(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon badge
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFB39DDB), Color(0xFFF48FB1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, 4),
                color: const Color(0xFFB39DDB).withOpacity(0.4),
              ),
            ],
          ),
          child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 25),
        ),
        const SizedBox(height: 14),

        const Text(
          "Pick Your Genres",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: Color(0xFF2D2251),
          ),
        ),
        const SizedBox(height: 4),

        Row(
          children: [
            Text(
              "Choose one or more to start reading",
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF2D2251).withOpacity(0.45),
              ),
            ),
            const SizedBox(width: 8),
            // Count badge
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selected.isEmpty
                  ? const SizedBox.shrink(key: ValueKey('e'))
                  : Container(
                      key: ValueKey(_selected.length),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFFE8DDFF),
                        border: Border.all(color: const Color(0xFFB39DDB).withOpacity(0.6)),
                      ),
                      child: Text(
                        "${_selected.length}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7B5EA7),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Chips ────────────────────────────────────
  Widget _buildChips() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_genres.length, _buildChip),
      ),
    );
  }

  Widget _buildChip(int i) {
    final g   = _genres[i];
    final sel = _selected.contains(i);

    return AnimatedBuilder(
      animation: _tapScales[i],
      builder: (_, child) => Transform.scale(scale: _tapScales[i].value, child: child),
      child: GestureDetector(
        onTapDown:   (_) => _tapCtrls[i].forward(),
        onTapUp:     (_) async { await _tapCtrls[i].reverse(); _toggle(i); },
        onTapCancel: () => _tapCtrls[i].reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: sel ? g.selectedBg : g.chipBg,
            border: Border.all(
              color: sel ? g.accent.withOpacity(0.7) : g.accent.withOpacity(0.2),
              width: sel ? 1.5 : 1,
            ),
            boxShadow: sel
                ? [BoxShadow(blurRadius: 12, spreadRadius: -3,
                    offset: const Offset(0, 3),
                    color: g.accent.withOpacity(0.25))]
                : [BoxShadow(blurRadius: 6, offset: const Offset(0, 2),
                    color: Colors.black.withOpacity(0.05))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? g.accent.withOpacity(0.9) : g.accent.withOpacity(0.12),
                ),
                child: Icon(g.icon, size: 14,
                  color: sel ? Colors.white : g.accent),
              ),
              const SizedBox(width: 9),

              // Label
              Text(
                g.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? g.textColor : g.textColor.withOpacity(0.7),
                  letterSpacing: -0.1,
                ),
              ),

              // Checkmark
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: sel
                    ? Padding(
                        key: const ValueKey('chk'),
                        padding: const EdgeInsets.only(left: 7),
                        child: Icon(Icons.check_circle_rounded, size: 15, color: g.accent),
                      )
                    : const SizedBox(key: ValueKey('none'), width: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Continue button ──────────────────────────
  Widget _buildContinueButton() {
    final active = _selected.isNotEmpty && !_loading;

    return GestureDetector(
      onTapDown:   (_) { if (active) _btnCtrl.forward(); },
      onTapUp:     (_) async { await _btnCtrl.reverse(); _confirm(); },
      onTapCancel: () => _btnCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _btnCtrl,
        builder: (_, child) =>
            Transform.scale(scale: 1.0 - _btnCtrl.value * 0.025, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFFB39DDB), Color(0xFFF48FB1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFE8E2F4), Color(0xFFF0EAF8)],
                  ),
            boxShadow: active
                ? [BoxShadow(blurRadius: 20, spreadRadius: -4, offset: const Offset(0, 4),
                    color: const Color(0xFFB39DDB).withOpacity(0.45))]
                : [],
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _selected.isEmpty ? "Select at least one genre" : "Continue  →",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: active
                          ? Colors.white
                          : const Color(0xFF2D2251).withOpacity(0.3),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}