import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/breakpoints.dart';
import '../widgets/about.dart';
import '../widgets/common/page_scroll.dart';
import '../widgets/contact.dart';
import '../widgets/cta.dart';
import '../widgets/footer.dart';
import '../widgets/furniture.dart';
import '../widgets/hero.dart';
import '../widgets/mobile_menu.dart';
import '../widgets/navbar.dart';
import '../widgets/philosophy.dart';
import '../widgets/projects.dart';
import '../widgets/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _offset = ValueNotifier<double>(0);

  final Map<NavTarget, GlobalKey> _sectionKeys = {
    for (final target in NavTarget.values) target: GlobalKey(),
  };

  late final AnimationController _menu;

  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _menu = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.hasClients) _offset.value = _scroll.offset;
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _offset.dispose();
    _menu.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _menuOpen = !_menuOpen;
      if (_menuOpen) {
        _menu.forward();
      } else {
        _menu.reverse();
      }
    });
  }

  void _closeMenu() {
    if (!_menuOpen) return;
    setState(() {
      _menuOpen = false;
      _menu.reverse();
    });
  }

  Future<void> _scrollTo(NavTarget target) async {
    _closeMenu();
    if (!_scroll.hasClients) return;

    final reduce = context.reduceMotion;
    final navHeight = context.navHeightCollapsed;
    // Let the menu start closing before the page moves, otherwise the overlay
    // masks the motion entirely.
    if (!reduce) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    if (!mounted || !_scroll.hasClients) return;

    double destination;
    if (target == NavTarget.home) {
      destination = 0;
    } else {
      final anchor = _sectionKeys[target]?.currentContext;
      if (anchor == null || !anchor.mounted) return;
      final box = anchor.findRenderObject() as RenderBox?;
      if (box == null) return;
      destination =
          _scroll.offset + box.localToGlobal(Offset.zero).dy - navHeight;
    }

    final clamped = destination.clamp(
      _scroll.position.minScrollExtent,
      _scroll.position.maxScrollExtent,
    );

    if (reduce) {
      _scroll.jumpTo(clamped);
    } else {
      await _scroll.animateTo(
        clamped,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Widget _anchor(NavTarget target, Widget child) =>
      KeyedSubtree(key: _sectionKeys[target], child: child);

  @override
  Widget build(BuildContext context) {
    // The overlay menu only exists below the desktop breakpoint — if the window
    // is widened while it is open, dismiss it.
    if (context.isDesktop && _menuOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _closeMenu();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: PageScroll(
        controller: _scroll,
        offset: _offset,
        child: Stack(
          children: [
            Positioned.fill(
              child: PrimaryScrollController(
                controller: _scroll,
                child: SingleChildScrollView(
                  controller: _scroll,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _anchor(
                        NavTarget.home,
                        HeroSection(
                          onExploreWork: () => _scrollTo(NavTarget.projects),
                          onGetInTouch: () => _scrollTo(NavTarget.contact),
                        ),
                      ),
                      _anchor(
                        NavTarget.about,
                        AboutSection(
                          onDiscover: () => _scrollTo(NavTarget.services),
                        ),
                      ),
                      _anchor(NavTarget.services, const ServicesSection()),
                      _anchor(
                        NavTarget.projects,
                        ProjectsSection(
                          onEnquire: () => _scrollTo(NavTarget.contact),
                        ),
                      ),
                      const PhilosophySection(),
                      FurnitureSection(
                        onEnquire: () => _scrollTo(NavTarget.contact),
                      ),
                      CtaSection(
                        onGetInTouch: () => _scrollTo(NavTarget.contact),
                      ),
                      _anchor(NavTarget.contact, const ContactSection()),
                      FooterSection(onNavigate: _scrollTo),
                    ],
                  ),
                ),
              ),
            ),
            if (!context.isDesktop)
              Positioned.fill(
                child: MobileMenu(
                  animation: _menu,
                  onNavigate: _scrollTo,
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Navbar(
                onNavigate: _scrollTo,
                onToggleMenu: _toggleMenu,
                menuOpen: _menuOpen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
