import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../backend/vault_item.dart';
import '../backend/vault_notifier.dart';

// ─── State enum ─────────────────────────────────────────────────────
enum _ServiceState { none, known, custom }

// ─── Service model ───────────────────────────────────────────────────
class _Service {
  final String name;
  final String domain;
  final String initials;
  final Color color;
  const _Service(this.name, this.domain, this.initials, this.color);
}

// ─── Full service database ───────────────────────────────────────────
// Quick-picks (shown as circles)
const _kQuickPicks = [
  _Service('Gmail', 'gmail.com · google.com', 'G', Color(0xFF4285F4)),
  _Service('Netflix', 'netflix.com', 'N', Color(0xFFE50914)),
  _Service('GitHub', 'github.com', 'Gh', Color(0xFF238636)),
  _Service('Amazon', 'amazon.com', 'A', Color(0xFFFF9900)),
];

// Full searchable database (includes quick-picks + more)
const _kServiceDb = [
  _Service('Gmail', 'gmail.com', 'G', Color(0xFF4285F4)),
  _Service('Google', 'google.com', 'Go', Color(0xFF4285F4)),
  _Service('Netflix', 'netflix.com', 'N', Color(0xFFE50914)),
  _Service('GitHub', 'github.com', 'Gh', Color(0xFF238636)),
  _Service('Amazon', 'amazon.com', 'A', Color(0xFFFF9900)),
  _Service('Flipkart', 'flipkart.com', 'Fk', Color(0xFF2874F0)),
  _Service('Twitter', 'twitter.com', 'Tw', Color(0xFF1DA1F2)),
  _Service('Facebook', 'facebook.com', 'Fb', Color(0xFF1877F2)),
  _Service('Instagram', 'instagram.com', 'In', Color(0xFFE1306C)),
  _Service('LinkedIn', 'linkedin.com', 'Li', Color(0xFF0A66C2)),
  _Service('Spotify', 'spotify.com', 'Sp', Color(0xFF1DB954)),
  _Service('Apple', 'apple.com', 'Ap', Color(0xFF555555)),
  _Service('Microsoft', 'microsoft.com', 'Ms', Color(0xFF00A4EF)),
  _Service('Slack', 'slack.com', 'Sl', Color(0xFF4A154B)),
  _Service('Discord', 'discord.com', 'Di', Color(0xFF5865F2)),
  _Service('Notion', 'notion.so', 'No', Color(0xFF000000)),
  _Service('Dropbox', 'dropbox.com', 'Db', Color(0xFF0061FF)),
  _Service('PayPal', 'paypal.com', 'Pp', Color(0xFF003087)),
  _Service('Stripe', 'stripe.com', 'St', Color(0xFF635BFF)),
  _Service('Zoom', 'zoom.us', 'Zo', Color(0xFF2D8CFF)),
];

const _kViolet = Color(0xFF6C63FF);

List<_Service> _searchServices(String query) {
  if (query.trim().isEmpty) return [];
  final q = query.toLowerCase().trim();
  return _kServiceDb
      .where(
        (s) =>
            s.name.toLowerCase().contains(q) ||
            s.domain.toLowerCase().contains(q),
      )
      .toList();
}

// ─── Main Screen ─────────────────────────────────────────────────────
class AddPasswordScreen extends ConsumerStatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  ConsumerState<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends ConsumerState<AddPasswordScreen> {
  _ServiceState _state = _ServiceState.none;
  _Service? _selected;

  // custom service data
  String _customName = '';

  // website or app toggle: true = Website, false = App, null = not chosen
  bool? _isWebsite;

  // search
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchActive = false; // true while search field has text
  List<_Service> _searchResults = [];

  // credentials form
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _passVisible = false;
  bool _isFavourite = false;

  // more options form
  bool _moreOptionsExpanded = false;
  final _notesCtrl = TextEditingController();
  final _folderCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _searchFocus.addListener(() => setState(() {}));
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text;
    setState(() {
      _searchActive = q.trim().isNotEmpty;
      _searchResults = _searchServices(q);
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _notesCtrl.dispose();
    _folderCtrl.dispose();
    super.dispose();
  }

  // ── Password strength ──────────────────────────────────────────
  int get _strength {
    final pass = _passCtrl.text;
    if (pass.isEmpty) return 0;

    int score = 0;
    if (pass.length >= 8) score += 1;
    if (pass.length >= 12) score += 1;

    final hasLower = RegExp(r'[a-z]').hasMatch(pass);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pass);
    final hasDigit = RegExp(r'\d').hasMatch(pass);
    final hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(pass);

    final typeCount =
        (hasLower ? 1 : 0) +
        (hasUpper ? 1 : 0) +
        (hasDigit ? 1 : 0) +
        (hasSpecial ? 1 : 0);

    if (typeCount == 4) {
      score += 2;
    } else if (typeCount == 3) {
      score += 1;
    }

    if (score == 0 && pass.isNotEmpty) {
      score = 1;
    }
    return score.clamp(1, 4);
  }

  void _generatePassword() {
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digits = '0123456789';
    const specials = '!@#\$%^&*()-_=+[]{}|;:,.<>?';
    const allChars = lower + upper + digits + specials;

    String pass = '';
    final random = math.Random.secure();

    // Ensure at least one of each type
    pass += lower[random.nextInt(lower.length)];
    pass += upper[random.nextInt(upper.length)];
    pass += digits[random.nextInt(digits.length)];
    pass += specials[random.nextInt(specials.length)];

    // Fill the rest (total 16 chars)
    for (int i = 0; i < 12; i++) {
      pass += allChars[random.nextInt(allChars.length)];
    }

    // Shuffle the characters
    final List<String> chars = pass.split('');
    chars.shuffle(random);

    setState(() {
      _passCtrl.text = chars.join('');
    });
  }

  String get _strengthLabel =>
      ['', 'Weak', 'Fair', 'Good', 'Strong'][_strength];
  Color get _strengthColor => const [
    Colors.transparent,
    Color(0xFFF16161),
    Color(0xFFFFB3B0),
    Color(0xFF41EEC2),
    Color(0xFF28DFB5),
  ][_strength];

  // ── Selection helpers ──────────────────────────────────────────
  void _selectKnown(_Service s) {
    _searchCtrl.clear();
    _searchFocus.unfocus();
    setState(() {
      _selected = s;
      _state = _ServiceState.known;
      _searchActive = false;
      _searchResults = [];
    });
  }

  /// Carry typed text as custom name (Scenario C)
  void _useAsCustom(String typedName) {
    final name = typedName.trim();
    _searchCtrl.clear();
    setState(() {
      _customName = name;
      _state = _ServiceState.custom;
      _searchActive = false;
      _searchResults = [];
    });
  }

  void _reset() => setState(() {
    _state = _ServiceState.none;
    _selected = null;
    _customName = '';
    _isWebsite = null;
    _emailCtrl.clear();
    _passCtrl.clear();
    _searchCtrl.clear();
    _searchActive = false;
    _searchResults = [];
  });

  void _openCustomSheet({bool prefill = false}) {
    final nameCtrl = TextEditingController(text: prefill ? _customName : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomServiceSheet(
        nameCtrl: nameCtrl,
        onConfirm: (name) {
          setState(() {
            _customName = name;
          });
        },
      ),
    );
  }

  bool get _canSave =>
      _emailCtrl.text.trim().isNotEmpty && _passCtrl.text.isNotEmpty;

  Future<void> _save() async {
    if (!_canSave) return;

    final name = _state == _ServiceState.known ? _selected!.name : _customName;
    final color = _state == _ServiceState.known ? _selected!.color : _kViolet;

    final item = VaultItem(
      id: '',
      type: VaultItemType.login,
      serviceName: name,
      serviceColor: color,
      username: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isWebsite: _isWebsite,
    );

    await ref.read(vaultNotifierProvider.notifier).addItem(item);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$name" saved to Passwords'),
          backgroundColor: _kViolet,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kViolet : const Color(0xFF4D41DF);

    return GestureDetector(
      onTap: () {
        //_searchFocus.unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? const Color(0xFFC4C0FF) : const Color(0xFF1A1A2E),
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Add Password',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: true,
          actions: [
            // Favourite button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _isFavourite
                  ? ElevatedButton.icon(
                      onPressed: () =>
                          setState(() => _isFavourite = !_isFavourite),
                      icon: const Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Favourite',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _isFavourite = !_isFavourite),
                      icon: Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: accentColor,
                      ),
                      label: Text(
                        'Favourite',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: accentColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
            ),

            // Save button (existing)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ListenableBuilder(
                listenable: Listenable.merge([_emailCtrl, _passCtrl]),
                builder: (context, _) => Opacity(
                  opacity: _canSave ? 1.0 : 0.4,
                  child: ElevatedButton(
                    onPressed: _canSave ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            _state == _ServiceState.none
                ? _buildPickerCard(context, isDark)
                : _buildServiceHeader(context, isDark),
            const SizedBox(height: 24),
            _buildForm(context, isDark),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _isFavourite
                      ? ElevatedButton.icon(
                          onPressed: () =>
                              setState(() => _isFavourite = !_isFavourite),
                          icon: const Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Favourite',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _isFavourite = !_isFavourite),
                          icon: Icon(
                            Icons.favorite_border,
                            size: 18,
                            color: accentColor,
                          ),
                          label: Text(
                            'Favourite',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: accentColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: accentColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _canSave ? _save : null,
                    icon: const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      disabledBackgroundColor: accentColor.withValues(
                        alpha: 0.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── STATE 1: Picker card with live search ──────────────────────
  Widget _buildPickerCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1C1A24) : Colors.white;
    final borderColor = isDark
        ? _kViolet.withValues(alpha: 0.35)
        : _kViolet.withValues(alpha: 0.28);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          // ── Icon + header (hidden when result dropdown is shown)
          _searchActive
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _kViolet.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: _kViolet,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Which app or website?',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: isDark
                            ? const Color(0xFFE5E0EE)
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search or pick a popular service',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _kViolet,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

          // ── Search field ──────────────────────────────────────
          Container(
            key: const ValueKey('search_field_container'),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13121B) : const Color(0xFFF3F3FA),
              borderRadius: _searchActive
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : BorderRadius.circular(12),
              border: Border.all(
                color: _searchFocus.hasFocus
                    ? _kViolet.withValues(alpha: 0.6)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : const Color(0xFFC7C4D8).withValues(alpha: 0.5)),
                width: _searchFocus.hasFocus ? 1.5 : 1.0,
              ),
            ),
            child: TextField(
              key: const ValueKey('search_field'),
              controller: _searchCtrl,
              focusNode: _searchFocus,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFE5E0EE)
                    : const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                hintText: 'Search Gmail, Netflix, GitHub…',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : const Color(0xFF464555).withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: _searchFocus.hasFocus
                      ? _kViolet.withValues(alpha: 0.6)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : const Color(0xFF464555).withValues(alpha: 0.4)),
                ),
                suffixIcon: _searchActive
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : const Color(0xFF464555).withValues(alpha: 0.5),
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          //_searchFocus.unfocus();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),

          // ── Live dropdown results ─────────────────────────────
          if (_searchActive)
            _buildSearchDropdown(context, isDark)
          else ...[
            // ── Quick-pick row (dims when search is active)  ───
            const SizedBox(height: 20),
            Opacity(
              opacity: _searchActive ? 0.3 : 1.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ..._kQuickPicks.map(
                    (s) => _buildQuickPick(
                      label: s.initials,
                      title: s.name,
                      color: s.color,
                      isDark: isDark,
                      onTap: () => _selectKnown(s),
                    ),
                  ),
                  _buildQuickPickCustom(isDark),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Inline dropdown panel ────────────────────────────────────
  Widget _buildSearchDropdown(BuildContext context, bool isDark) {
    final bg = isDark ? const Color(0xFF13121B) : const Color(0xFFF3F3FA);
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFC7C4D8).withValues(alpha: 0.4);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        border: Border(
          left: BorderSide(color: _kViolet.withValues(alpha: 0.4), width: 1.5),
          right: BorderSide(color: _kViolet.withValues(alpha: 0.4), width: 1.5),
          bottom: BorderSide(
            color: _kViolet.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Best match results ─────────────────────────────
          if (_searchResults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Text(
                'BEST MATCH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: isDark
                      ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
                      : const Color(0xFF464555).withValues(alpha: 0.55),
                ),
              ),
            ),
            ...(_searchResults
                .take(4)
                .map((s) => _buildDropdownItem(context, s, isDark))),
            Divider(height: 1, color: divColor, indent: 14, endIndent: 14),
          ],

          // ── "Use as custom" — always shown at bottom ────────
          InkWell(
            onTap: () => _useAsCustom(_searchCtrl.text),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _kViolet.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _kViolet.withValues(alpha: 0.35),
                        width: 1.2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Icon(Icons.add, color: _kViolet, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFE5E0EE)
                                  : const Color(0xFF1A1A2E),
                            ),
                            children: [
                              const TextSpan(text: 'Use "'),
                              TextSpan(
                                text: _searchCtrl.text.trim(),
                                style: const TextStyle(color: _kViolet),
                              ),
                              const TextSpan(text: '" as custom'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Not in our list? No problem.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
                                : const Color(
                                    0xFF464555,
                                  ).withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: _kViolet.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(BuildContext context, _Service s, bool isDark) {
    return InkWell(
      onTap: () => _selectKnown(s),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: s.color.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  s.initials,
                  style: TextStyle(
                    color: s.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFE5E0EE)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    s.domain,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
                          : const Color(0xFF464555).withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.north_west,
              size: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : const Color(0xFF464555).withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPick({
    required String label,
    required String title,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? const Color(0xFFC7C4D8).withValues(alpha: 0.7)
                  : const Color(0xFF464555).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPickCustom(bool isDark) {
    return GestureDetector(
      onTap: () => _openCustomSheet(),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _kViolet.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(Icons.add, color: _kViolet, size: 22),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Custom',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _kViolet.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ── STATE 2 & 3: Service identity header ───────────────────────
  Widget _buildServiceHeader(BuildContext context, bool isDark) {
    final isCustom = _state == _ServiceState.custom;
    final name = isCustom ? _customName : _selected!.name;
    final initials = isCustom
        ? (name.length >= 2
              ? name.substring(0, 2).toUpperCase()
              : name.toUpperCase())
        : _selected!.initials;
    final color = isCustom ? _kViolet : _selected!.color;
    final cardBg = isDark ? const Color(0xFF1C1A24) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCustom
              ? _kViolet.withValues(alpha: isDark ? 0.5 : 0.35)
              : color.withValues(alpha: isDark ? 0.25 : 0.15),
          width: isCustom ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          // Initials avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(14),
              border: isCustom
                  ? Border.all(
                      color: _kViolet.withValues(alpha: 0.5),
                      width: 1.5,
                      style: BorderStyle.solid,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name & type badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark
                        ? const Color(0xFFE5E0EE)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
                if (_isWebsite != null) ...[
                  const SizedBox(height: 4),
                  _TypeBadge(isWebsite: _isWebsite!, isDark: isDark),
                ],
              ],
            ),
          ),
          // Change / Edit chip
          GestureDetector(
            onTap: isCustom ? () => _openCustomSheet(prefill: true) : _reset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFF3F3FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isCustom ? 'Edit' : 'Change',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFC7C4D8)
                      : const Color(0xFF464555),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form sections ──────────────────────────────────────────────
  Widget _buildForm(BuildContext context, bool isDark) {
    final locked = _state == _ServiceState.none;
    return Opacity(
      opacity: locked ? 0.28 : 1.0,
      child: IgnorePointer(
        ignoring: locked,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (locked)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: Text(
                    '+ More fields unlocked after selecting service',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFC7C4D8).withValues(alpha: 0.6)
                          : const Color(0xFF464555).withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            _buildTypeToggleCard(context, isDark),
            const SizedBox(height: 14),
            _buildCredentialsCard(context, isDark),
            const SizedBox(height: 14),
            _buildMoreCard(context, isDark),
          ],
        ),
      ),
    );
  }

  // ── Website or App toggle card ────────────────────────────────
  Widget _buildTypeToggleCard(BuildContext context, bool isDark) {
    return _FormCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('IS THIS A WEBSITE OR AN APP?', isDark),
          const SizedBox(height: 6),
          Text(
            'This helps VaultKey organise and recognise your passwords',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
                  : const Color(0xFF464555).withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TypeToggleButton(
                  label: 'Website',
                  icon: Icons.language_rounded,
                  selected: _isWebsite == true,
                  isDark: isDark,
                  onTap: () => setState(() => _isWebsite = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeToggleButton(
                  label: 'App',
                  icon: Icons.smartphone_rounded,
                  selected: _isWebsite == false,
                  isDark: isDark,
                  onTap: () => setState(() => _isWebsite = false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Credentials ────────────────────────────────────────────────
  Widget _buildCredentialsCard(BuildContext context, bool isDark) {
    return _FormCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('CREDENTIALS', isDark),
          const SizedBox(height: 14),
          _FieldLabel('Email / Username', isDark),
          const SizedBox(height: 6),
          _StyledField(
            controller: _emailCtrl,
            hint: _state == _ServiceState.known
                ? 'alex.vanguard@${_selected?.domain.split(' ').first ?? ''}'
                : 'Enter email or username',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _FieldLabel('Password', isDark),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13121B) : const Color(0xFFF3F3FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFC7C4D8).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passCtrl,
                    obscureText: !_passVisible,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      color: isDark
                          ? const Color(0xFFE5E0EE)
                          : const Color(0xFF1A1A2E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter or generate password',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontFamily: 'sans-serif',
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : const Color(0xFF464555).withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _passVisible ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : const Color(0xFF464555).withValues(alpha: 0.5),
                  ),
                  onPressed: () => setState(() => _passVisible = !_passVisible),
                ),

                if (_passCtrl.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: 20,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color(0xFF464555).withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _passCtrl.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Password copied to clipboard'),
                          backgroundColor: _kViolet,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          if (_passCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: List.generate(4, (i) {
                final active = i < _strength;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: active
                          ? _strengthColor
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(
                                    0xFFC7C4D8,
                                  ).withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _strengthLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _strengthColor,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _generatePassword,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _kViolet.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kViolet.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Generate password',
                  style: TextStyle(
                    color: _kViolet,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── More options ────────────────────────────────────────────────
  Widget _buildMoreCard(BuildContext context, bool isDark) {
    if (_moreOptionsExpanded) {
      return _FormCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _SectionLabel('MORE OPTIONS', isDark)),
                GestureDetector(
                  onTap: () => setState(() => _moreOptionsExpanded = false),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: isDark
                        ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
                        : const Color(0xFF464555).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FieldLabel('Notes', isDark),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF13121B)
                    : const Color(0xFFF3F3FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : const Color(0xFFC7C4D8).withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFE5E0EE)
                      : const Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  hintText: 'Add securely encrypted notes...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : const Color(0xFF464555).withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Folder', isDark),
            const SizedBox(height: 6),
            _StyledField(
              controller: _folderCtrl,
              hint: 'e.g. Personal, Work, Finance',
              isDark: isDark,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _moreOptionsExpanded = true),
      child: _FormCard(
        isDark: isDark,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('MORE OPTIONS', isDark),
                  const SizedBox(height: 6),
                  Text(
                    'Notes · Folder',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFFC7C4D8).withValues(alpha: 0.6)
                          : const Color(0xFF464555).withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark
                  ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
                  : const Color(0xFF464555).withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helper widgets ──────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _FormCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1A24) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.35),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: child,
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  const _StyledField({
    required this.controller,
    required this.hint,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13121B) : const Color(0xFFF3F3FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : const Color(0xFF464555).withValues(alpha: 0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: isDark
            ? const Color(0xFFC7C4D8).withValues(alpha: 0.55)
            : const Color(0xFF464555).withValues(alpha: 0.6),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark
            ? const Color(0xFFE5E0EE).withValues(alpha: 0.85)
            : const Color(0xFF1A1A2E).withValues(alpha: 0.8),
      ),
    );
  }
}

// ─── Website/App Type Toggle Button ─────────────────────────────────
class _TypeToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? _kViolet.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? const Color(0xFF13121B) : const Color(0xFFF3F3FA)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? _kViolet.withValues(alpha: 0.8)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : const Color(0xFFC7C4D8).withValues(alpha: 0.5)),
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: selected
                  ? _kViolet
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.35)
                        : const Color(0xFF464555).withValues(alpha: 0.45)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? _kViolet
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : const Color(0xFF464555).withValues(alpha: 0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Type Badge (shown in service header after selection) ────────────
class _TypeBadge extends StatelessWidget {
  final bool isWebsite;
  final bool isDark;

  const _TypeBadge({required this.isWebsite, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kViolet.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWebsite ? Icons.language_rounded : Icons.smartphone_rounded,
            size: 11,
            color: _kViolet,
          ),
          const SizedBox(width: 4),
          Text(
            isWebsite ? 'Website' : 'App',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _kViolet,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom service bottom sheet ─────────────────────────────────────
class _CustomServiceSheet extends StatefulWidget {
  final TextEditingController nameCtrl;
  final void Function(String name) onConfirm;

  const _CustomServiceSheet({required this.nameCtrl, required this.onConfirm});

  @override
  State<_CustomServiceSheet> createState() => _CustomServiceSheetState();
}

class _CustomServiceSheetState extends State<_CustomServiceSheet> {
  @override
  void initState() {
    super.initState();
    widget.nameCtrl.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasName = widget.nameCtrl.text.trim().isNotEmpty;
    final rawName = widget.nameCtrl.text.trim();
    final initials = rawName.isEmpty
        ? '?'
        : (rawName.length >= 2
              ? rawName.substring(0, 2).toUpperCase()
              : rawName.toUpperCase());

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1A24) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFC7C4D8).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Name your service',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: isDark
                    ? const Color(0xFFE5E0EE)
                    : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the app or website you\'re saving credentials for',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFFC7C4D8).withValues(alpha: 0.6)
                    : const Color(0xFF464555).withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF13121B)
                    : const Color(0xFFF3F3FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasName
                      ? _kViolet
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFC7C4D8).withValues(alpha: 0.5)),
                  width: hasName ? 1.5 : 1.0,
                ),
              ),
              child: TextField(
                controller: widget.nameCtrl,
                autofocus: !hasName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFE5E0EE)
                      : const Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. My Company Portal',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : const Color(0xFF464555).withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            // Live preview
            if (hasName) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _kViolet.withValues(alpha: isDark ? 0.12 : 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kViolet.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _kViolet.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _kViolet.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: _kViolet,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: _kViolet,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            const TextSpan(text: 'Will appear as "'),
                            TextSpan(text: rawName),
                            const TextSpan(text: '"'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasName
                    ? () {
                        widget.onConfirm(widget.nameCtrl.text.trim());
                        Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasName
                      ? _kViolet
                      : (isDark
                            ? const Color(0xFF2A2933)
                            : const Color(0xFFE7E8EE)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: hasName
                        ? Colors.white
                        : (isDark
                              ? const Color(0xFFC7C4D8).withValues(alpha: 0.35)
                              : const Color(0xFF464555).withValues(alpha: 0.4)),
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
