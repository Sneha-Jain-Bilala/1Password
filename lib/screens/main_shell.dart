import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_nav.dart';

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late final AnimationController _animController;
  late final Animation<double> _scrimAnim;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrimAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      setState(() => _isOpen = true);
      _animController.forward();
    }
  }

  void _close() {
    _animController.reverse().then((_) {
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _navigate(String route) {
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() => _isOpen = false);
        context.push(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    // FAB bottom offset (same as FloatingActionButtonLocation.endFloat)
    const fabBottomMargin = 16.0;
    const fabSize = 56.0;
    const fabRightMargin = 16.0;
    final fabBottom = bottomPadding +
        kBottomNavigationBarHeight +
        fabBottomMargin;

    final options = <_FabOptionData>[
      _FabOptionData(
        icon: Icons.lock_outline,
        label: 'Password',
        color: const Color(0xFF4D41DF),
        bgColor: const Color(0xFFEEEDFF),
        darkColor: const Color(0xFFC4C0FF),
        darkBgColor: const Color(0xFF1F1D2E),
        route: '/add_password',
      ),
      _FabOptionData(
        icon: Icons.sticky_note_2_outlined,
        label: 'Secure Note',
        color: const Color(0xFF006B55),
        bgColor: const Color(0xFFE0FAF5),
        darkColor: const Color(0xFF41EEC2),
        darkBgColor: const Color(0xFF132922),
        route: '/add_note',
      ),
      _FabOptionData(
        icon: Icons.credit_card_outlined,
        label: 'Debit / Credit Card',
        color: const Color(0xFFC1282A),
        bgColor: const Color(0xFFFFF0F0),
        darkColor: const Color(0xFFFFB3B0),
        darkBgColor: const Color(0xFF2A1B1B),
        route: '/add_card',
      ),
      _FabOptionData(
        icon: Icons.place_outlined,
        label: 'Address',
        color: const Color(0xFFF57C00),
        bgColor: const Color(0xFFFFF4E5),
        darkColor: const Color(0xFFFFB74D),
        darkBgColor: const Color(0xFF2E241F),
        route: '/add_address',
      ),
    ];

    return Stack(
      children: [
        // ── 1. Main scaffold ────────────────────────────────────────
        Scaffold(
          body: widget.navigationShell,
          extendBody: true,
          bottomNavigationBar: AppBottomNav(
            currentIndex: widget.navigationShell.currentIndex,
            onTabSelected: (index) {
              if (_isOpen) _close();
              widget.navigationShell.goBranch(
                index,
                initialLocation: index == widget.navigationShell.currentIndex,
              );
            },
          ),
        ),

        // ── 2. Scrim (dismisses FAB on tap) ─────────────────────────
        if (_isOpen)
          AnimatedBuilder(
            animation: _scrimAnim,
            builder: (_, __) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: Container(
                width: screenSize.width,
                height: screenSize.height,
                color: Colors.black.withValues(alpha: 0.5 * _scrimAnim.value),
              ),
            ),
          ),

        // ── 3. Speed-dial options (above scrim) ─────────────────────
        if (_isOpen)
          Positioned(
            right: fabRightMargin,
            bottom: fabBottom + fabSize + 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: options.asMap().entries.map((entry) {
                final i = entry.key;
                final opt = entry.value;
                final delay = i * 0.12;
                return AnimatedBuilder(
                  animation: _expandAnim,
                  builder: (_, child) {
                    final t = ((_expandAnim.value - delay) / (1.0 - delay))
                        .clamp(0.0, 1.0);
                    return Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - t)),
                        child: child,
                      ),
                    );
                  },
                  child: _OptionRow(
                    data: opt,
                    isDark: isDark,
                    onTap: () => _navigate(opt.route),
                  ),
                );
              }).toList(),
            ),
          ),

        // ── 4. Main FAB (always on top) ──────────────────────────────
        Positioned(
          right: fabRightMargin,
          bottom: fabBottom,
          child: GestureDetector(
            onTap: _toggle,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (_, __) {
                final angle =
                    _animController.value * 0.625 * 2 * 3.14159;
                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: fabSize,
                    height: fabSize,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isOpen
                          ? const Icon(Icons.close,
                              size: 30,
                              color: Colors.white,
                              key: ValueKey('close'))
                          : const Icon(Icons.add,
                              size: 30,
                              color: Colors.white,
                              key: ValueKey('add')),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────
class _FabOptionData {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final Color darkColor;
  final Color darkBgColor;
  final String route;
  const _FabOptionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.darkColor,
    required this.darkBgColor,
    required this.route,
  });
}

// ── Option row widget (label pill + icon circle) ───────────────────────────
class _OptionRow extends StatelessWidget {
  final _FabOptionData data;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionRow({
    required this.data,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? data.darkColor : data.color;
    final bg = isDark ? data.darkBgColor : data.bgColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1A24) : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE5E0EE)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Colored icon circle
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(data.icon, color: iconColor, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
