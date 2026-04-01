import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../../services/api_service.dart';
import 'package:collection/collection.dart';
import '../novel/novel_detail_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../library/library_screen.dart';

// ─── PALETTE ─────────────────────────────────────────────────────────────────
class _P {
  static const Color bg = Color(0xFFF7F3EF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color rose = Color(0xFFD4899A);
  static const Color roseSoft = Color(0xFFF2D5DC);
  static const Color lavender = Color(0xFFB8A9D9);
  static const Color lavenderSoft = Color(0xFFEDE8F5);
  static const Color mint = Color(0xFFA3C9B8);
  static const Color mintSoft = Color(0xFFDCEDE6);
  static const Color peach = Color(0xFFE8B99A);
  static const Color peachSoft = Color(0xFFF5E4DA);
  static const Color sky = Color(0xFF9DC4E0);
  static const Color skySoft = Color(0xFFDCECF5);
  static const Color textPrimary = Color(0xFF3D3047);
  static const Color textSub = Color(0xFF7A6E8A);
  static const Color textHint = Color(0xFFA89BB5);
}

const Map<String, Color> _gA = {
  'Romance': _P.rose,
  'Comedy': _P.peach,
  'Horror': _P.lavender,
  'Science Fiction': _P.sky,
  'Mystery': _P.mint,
};
const Map<String, Color> _gAS = {
  'Romance': _P.roseSoft,
  'Comedy': _P.peachSoft,
  'Horror': _P.lavenderSoft,
  'Science Fiction': _P.skySoft,
  'Mystery': _P.mintSoft,
};

const List<Color> _cS = [
  _P.roseSoft,
  _P.lavenderSoft,
  _P.mintSoft,
  _P.peachSoft,
  _P.skySoft,
];
const List<Color> _cH = [_P.rose, _P.lavender, _P.mint, _P.peach, _P.sky];

// ═════════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Novel>> _novelsFuture;
  bool _drawerOpen = false;
  late AnimationController _dCtrl;
  late Animation<double> _dSlide;
  List<String> _userGenres = [];

  List<Novel> _filterByGenre(List<Novel> novels) {
    if (_userGenres.isEmpty) return [];
    return novels.where((n) => _userGenres.contains(n.genre)).toList();
  }

  Future<void> _loadUserGenres() async {
    try {
      final genres = await ApiService.fetchUserGenres(widget.userId);
      print("Fetching genres for user ${widget.userId}");
      setState(() => _userGenres = genres);
    } catch (e) {
      debugPrint("Failed to load user genres: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _novelsFuture = ApiService.fetchAllNovels();
    _loadUserGenres();
    _dCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _dSlide = CurvedAnimation(parent: _dCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _dCtrl.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _drawerOpen = !_drawerOpen;
    });
    _drawerOpen ? _dCtrl.forward() : _dCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final double dw = (sw * 0.76).clamp(280, 380).toDouble();

    return Scaffold(
      backgroundColor: _P.bg,
      body: Stack(
        children: [
          // ── main scroll ──
          Column(
            children: [
              _AppBar(userId: widget.userId, onProfile: _toggleDrawer),
              Expanded(
                child: FutureBuilder<List<Novel>>(
                  future: _novelsFuture,
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (snap.hasError) {
                      return Center(child: Text('Failed to load novels'));
                    }

                    final allNovels = snap.data!;
                    final genreNovels = _filterByGenre(allNovels);

                    return _Body(
                      genreNovels: genreNovels,
                      allNovels: allNovels,
                      userId: widget.userId,
                    );
                  },
                ),
              ),
            ],
          ),
          // ── overlay ──
          AnimatedBuilder(
            animation: _dSlide,
            builder: (_, __) => _dSlide.value > 0
                ? Positioned.fill(
                    child: GestureDetector(
                      onTap: _toggleDrawer,
                      child: Container(
                        color: Colors.black.withOpacity(_dSlide.value * 0.35),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // ── drawer ──
          AnimatedBuilder(
            animation: _dSlide,
            builder: (_, child) => Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: dw,
              child: Transform.translate(
                offset: Offset(dw * (1 - _dSlide.value), 0),
                child: child,
              ),
            ),
            child: _ProfileDrawer(
              key: UniqueKey(),
              userId: widget.userId,
              onClose: _toggleDrawer,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  APP BAR
// ═════════════════════════════════════════════════════════════════════════════
class _AppBar extends StatelessWidget {
  final int userId;
  final VoidCallback onProfile;
  const _AppBar({required this.userId, required this.onProfile});

  @override
  Widget build(BuildContext context) => Container(
    color: _P.bg,
    padding: const EdgeInsets.only(top: 54, left: 22, right: 22, bottom: 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_P.roseSoft, _P.lavenderSoft],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _P.rose.withOpacity(0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_stories, color: _P.rose, size: 21),
            ),
            const SizedBox(width: 10),
            const Text(
              'BookNest',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _P.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _PillIcon(
              icon: Icons.library_books_rounded,
              color: _P.lavender,
              bg: _P.lavenderSoft,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _PillIcon(
              icon: Icons.person_rounded,
              color: _P.rose,
              bg: _P.roseSoft,
              onTap: onProfile,
            ),
          ],
        ),
      ],
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  BODY  ─  hero banner → featured row → novel list
// ═════════════════════════════════════════════════════════════════════════════
class _Body extends StatefulWidget {
  final List<Novel> genreNovels;
  final List<Novel> allNovels;
  final int userId;

  const _Body({
    required this.genreNovels,
    required this.allNovels,
    required this.userId,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  // hero entrance
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late Animation<double> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic);
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allNovels.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<Novel> source = widget.genreNovels.isNotEmpty
        ? widget.genreNovels
        : widget.allNovels;

    final featured = source.take(8).toList();
    final hero = source.first;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // ─── HERO BANNER ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: AnimatedBuilder(
              animation: _heroCtrl,
              builder: (_, child) => Opacity(
                opacity: _heroFade.value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - _heroSlide.value)),
                  child: child,
                ),
              ),
              child: _HeroBanner(novel: hero),
            ),
          ),

          const SizedBox(height: 24),

          // ─── FEATURED ROW ────────────────────────────────────────────────
          _SectionTitle(title: '✨ Featured', sub: 'Handpicked for you'),
          const SizedBox(height: 14),
          SizedBox(
            height: 195, // card height = cover 140 + info 55
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              itemCount: featured.length,
              itemBuilder: (_, i) => _FeaturedCard(
                novel: featured[i],
                index: i,
                userId: widget.userId,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ─── ALL NOVELS ──────────────────────────────────────────────────
          _SectionTitle(
            title: '📖 All Novels',
            sub: '${widget.allNovels.length} novels',
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: widget.allNovels
                  .mapIndexed((i, n) => _NovelRow(novel: n, index: i, userId: widget.userId))
                  .toList(),
            ),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  HERO BANNER  ─  big cinematic card with floating cover + gradient overlay
// ═════════════════════════════════════════════════════════════════════════════
class _HeroBanner extends StatefulWidget {
  final Novel novel;
  const _HeroBanner({required this.novel});
  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _floatAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOutSine));
    _floatCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [_P.roseSoft, _P.lavenderSoft, _P.mintSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _P.rose.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── decorative blobs ──
          Positioned(
            top: -30,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _P.lavenderSoft.withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            bottom: -25,
            left: 60,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _P.mintSoft.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _P.peachSoft.withOpacity(0.55),
              ),
            ),
          ),

          // ── content row ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // floating cover
                AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                      0,
                      -5 * _floatAnim.value,
                    ), // gentle bob up/down
                    child: child,
                  ),
                  child: Container(
                    width: 105,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 14,
                          offset: const Offset(2, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      widget.novel.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _P.roseSoft,
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: _P.rose,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                // info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Now Reading" badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _P.rose.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _P.rose.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _P.rose,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Now Reading',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _P.rose,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.novel.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: _P.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'by ${widget.novel.author}',
                        style: const TextStyle(fontSize: 13, color: _P.textSub),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: _P.peach,
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.novel.rating} (${widget.novel.ratedBy})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _P.textSub,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _GenrePill(text: widget.novel.genre),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  FEATURED CARD  ─  horizontal scroll, fixed 140px cover, staggered slide-in
// ═════════════════════════════════════════════════════════════════════════════
class _FeaturedCard extends StatefulWidget {
  final Novel novel;
  final int index;
  final int userId;
  const _FeaturedCard({
    required this.novel,
    required this.index,
    required this.userId,
  });
  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ci = widget.index % _cS.length;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value,
        child: Transform.translate(
          offset: Offset(30 * (1 - _anim.value), 0),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: GestureDetector(
          onTapDown: (_) => setState(() {
            _scale = 0.93;
          }),
          onTapUp: (_) => setState(() {
            _scale = 1.0;
          }),
          onTapCancel: () => setState(() {
            _scale = 1.0;
          }),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NovelDetailScreen(
                  userId: widget.userId,
                  novel: widget.novel,
                ),
              ),
            );
          },

          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: SizedBox(
              width: 135,
              height: 195, // total card height
              child: Container(
                decoration: BoxDecoration(
                  color: _P.card,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // cover ── fixed 140 px tall
                    SizedBox(
                      height: 140,
                      child: Image.network(
                        widget.novel.imageUrl,
                        width: 135,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _cS[ci],
                          child: Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: _cH[ci],
                              size: 38,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // info ── remaining 55 px
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.novel.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _P.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: _P.peach,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${widget.novel.rating}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _P.textSub,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  NOVEL ROW  ─  vertical list card (horizontal layout inside)
// ═════════════════════════════════════════════════════════════════════════════
class _NovelRow extends StatefulWidget {
  final Novel novel;
  final int index;
  final int userId;
  const _NovelRow({required this.novel, required this.index, required this.userId});
  @override
  State<_NovelRow> createState() => _NovelRowState();
}

class _NovelRowState extends State<_NovelRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    final delay = (widget.index * 55).clamp(0, 500);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ci = widget.index % _cS.length;
    final tropes = widget.novel.tropes.split('|').map((e) => e.trim()).toList();

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - _anim.value)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTapDown: (_) => setState(() {
            _scale = 0.97;
          }),
          onTapUp: (_) => setState(() {
            _scale = 1.0;
          }),
          onTapCancel: () => setState(() {
            _scale = 1.0;
          }),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NovelDetailScreen(
                  userId: widget.userId,
                  novel: widget.novel,
                ),
              ),
            );
          },

          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                color: _P.card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // cover ── fixed size, no flex
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: SizedBox(
                        width: 82,
                        height: 123,
                        child: Image.network(
                          widget.novel.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _cS[ci],
                            child: Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: _cH[ci],
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 13),

                    // details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.novel.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _P.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'by ${widget.novel.author}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _P.textHint,
                            ),
                          ),
                          const SizedBox(height: 7),

                          // rating + genre
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _P.peachSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: _P.peach,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${widget.novel.rating} (${widget.novel.ratedBy})',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: _P.textSub,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _GenrePill(text: widget.novel.genre),
                            ],
                          ),

                          const SizedBox(height: 7),

                          // tropes
                          Wrap(
                            spacing: 5,
                            runSpacing: 4,
                            children: tropes
                                .take(3)
                                .map(
                                  (t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _P.lavenderSoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: _P.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 6),

                          // synopsis
                          Text(
                            widget.novel.synopsis,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _P.textSub,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  PROFILE DRAWER
// ═════════════════════════════════════════════════════════════════════════════
class _ProfileDrawer extends StatefulWidget {
  final int userId;
  final VoidCallback onClose;

  const _ProfileDrawer({Key? key, required this.userId, required this.onClose})
    : super(key: key);

  @override
  State<_ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<_ProfileDrawer> {
  String name = "";
  String email = "";
  List<String> genres = [];

  int libraryCount = 0;
  int wishlistCount = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = await ApiService.fetchUser(widget.userId);
      final wishlist = await ApiService.fetchWishlist(widget.userId);
      final library = await ApiService.fetchLibrary(widget.userId);
      final userGenres = await ApiService.fetchUserGenres(widget.userId);

      setState(() {
        name = user["name"];
        email = user["email"];
        genres = userGenres;

        libraryCount = library.length;
        wishlistCount = wishlist.length;
      });
    } catch (e) {
      debugPrint("Profile load error: $e");
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _P.card,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.14),
          blurRadius: 28,
          offset: const Offset(-8, 0),
        ),
      ],
    ),
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 22, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: _P.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _P.bg,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: _P.textSub,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // avatar
          Center(
            child: Column(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_P.roseSoft, _P.lavenderSoft],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _P.rose.withOpacity(0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _P.rose,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _P.textPrimary,
                  ),
                ),

                Text(
                  email,
                  style: const TextStyle(fontSize: 13, color: _P.textHint),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _Div(),

          // stats
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(value: "$libraryCount", label: 'Reading'),
                const _Stat(value: '0', label: 'Finished'),
                _Stat(value: "$wishlistCount", label: 'Wishlist'),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _Div(),

          // genres
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Genres',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _P.textSub,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: genres.map((g) {
                    final a = _gA[g] ?? _P.lavender;
                    final as = _gAS[g] ?? _P.lavenderSoft;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: as,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: a.withOpacity(0.35)),
                      ),
                      child: Text(
                        g,
                        style: TextStyle(
                          fontSize: 13,
                          color: a,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _Div(),

          // menu
          const SizedBox(height: 8),

          _DrawerTile(
            icon: Icons.library_books_rounded,
            label: 'My Library',
            color: _P.lavender,
            bg: _P.lavenderSoft,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LibraryScreen(userId: widget.userId),
                ),
              );
            },
          ),

          _DrawerTile(
            icon: Icons.bookmark_add_rounded,
            label: 'Wishlist',
            color: _P.mint,
            bg: _P.mintSoft,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WishlistScreen(userId: widget.userId),
                ),
              );
            },
          ),

          _DrawerTile(
            icon: Icons.settings_rounded,
            label: 'Settings',
            color: _P.peach,
            bg: _P.peachSoft,
            onTap: () {},
          ),

          const Spacer(),

          // logout
          Padding(
            padding: const EdgeInsets.all(22),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: _P.roseSoft,
                border: Border.all(color: _P.rose.withOpacity(0.3)),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: _P.rose, size: 19),
                    SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _P.rose,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  SKELETON  ─  shimmer placeholders matching the real layout
// ═════════════════════════════════════════════════════════════════════════════
class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // hero placeholder
        _Shimmer(w: double.infinity, h: 180, r: 24),
        const SizedBox(height: 24),
        _Shimmer(w: 130, h: 18),
        const SizedBox(height: 14),
        // featured row
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _Shimmer(w: 135, h: 195, r: 18),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _Shimmer(w: 120, h: 18),
        const SizedBox(height: 14),
        // novel rows
        ...[123.0, 123.0, 123.0, 123.0].map(
          (h) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _Shimmer(
              w: double.infinity,
              h: h + 26,
              r: 18,
            ), // 26 = padding
          ),
        ),
      ],
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  ERROR
// ═════════════════════════════════════════════════════════════════════════════
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off_rounded, size: 54, color: _P.textHint),
        const SizedBox(height: 14),
        const Text(
          'Something went wrong',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _P.textSub,
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_P.rose, _P.lavender]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _P.rose.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _PillIcon extends StatefulWidget {
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;
  const _PillIcon({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  @override
  State<_PillIcon> createState() => _PillIconState();
}

class _PillIconState extends State<_PillIcon> {
  double _s = 1.0;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() {
      _s = 0.85;
    }),
    onTapUp: (_) => setState(() {
      _s = 1.0;
    }),
    onTapCancel: () => setState(() {
      _s = 1.0;
    }),
    onTap: widget.onTap,
    child: AnimatedScale(
      scale: _s,
      duration: const Duration(milliseconds: 130),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.bg,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(widget.icon, color: widget.color, size: 21),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title, sub;
  const _SectionTitle({required this.title, required this.sub});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _P.textPrimary,
          ),
        ),
        Text(sub, style: const TextStyle(fontSize: 13, color: _P.textHint)),
      ],
    ),
  );
}

class _GenrePill extends StatelessWidget {
  final String text;
  const _GenrePill({required this.text});
  @override
  Widget build(BuildContext context) {
    final a = _gA[text] ?? _P.lavender;
    final as = _gAS[text] ?? _P.lavenderSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: as,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: a, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _P.textPrimary,
        ),
      ),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 12, color: _P.textHint)),
    ],
  );
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Container(height: 1, color: _P.bg),
  );
}

class _DrawerTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  @override
  State<_DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<_DrawerTile> {
  bool _p = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() {
      _p = true;
    }),
    onTapUp: (_) => setState(() {
      _p = false;
    }),
    onTapCancel: () => setState(() {
      _p = false;
    }),
    onTap: widget.onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _p ? widget.bg : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, color: widget.bg),
            child: Icon(widget.icon, color: widget.color, size: 19),
          ),
          const SizedBox(width: 14),
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _P.textPrimary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: _P.textHint, size: 20),
        ],
      ),
    ),
  );
}

// animated shimmer box
class _Shimmer extends StatefulWidget {
  final double w, h, r;
  const _Shimmer({required this.w, required this.h, this.r = 10});
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _a = Tween<double>(begin: -1.0, end: 2.0).animate(_c);
    _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, __) => Container(
      width: widget.w,
      height: widget.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.r),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFEBE7E3),
            Color(0xFFF5F2EF),
            Color(0xFFEBE7E3),
          ],
          stops: [
            (_a.value - 0.3).clamp(0, 1),
            _a.value.clamp(0, 1),
            (_a.value + 0.3).clamp(0, 1),
          ],
        ),
      ),
    ),
  );
}
