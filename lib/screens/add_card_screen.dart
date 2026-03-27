import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_card_scanner/ml_card_scanner.dart';
import '../backend/vault_item.dart';
import '../backend/vault_notifier.dart';

const _kCoral = Color(0xFFFFB3B0);
const _kCoralDark = Color(0xFFC1282A);

enum _CardType { visa, mastercard, amex, rupay, other }

extension _CardTypeX on _CardType {
  String get label {
    switch (this) {
      case _CardType.visa:
        return 'VISA';
      case _CardType.mastercard:
        return 'Mastercard';
      case _CardType.amex:
        return 'Amex';
      case _CardType.rupay:
        return 'RuPay';
      case _CardType.other:
        return 'Card';
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case _CardType.visa:
        return [const Color(0xFF1A1F71), const Color(0xFF2D79F4)];
      case _CardType.mastercard:
        return [const Color(0xFF1A1A2E), const Color(0xFFC1282A)];
      case _CardType.amex:
        return [const Color(0xFF006FCF), const Color(0xFF00A1DE)];
      case _CardType.rupay:
        return [const Color(0xFF1A3A1A), const Color(0xFF2E7D32)];
      case _CardType.other:
        return [const Color(0xFF1A1A2E), const Color(0xFF4D41DF)];
    }
  }
}

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  bool _cvvVisible = false;
  _CardType _cardType = _CardType.other;

  @override
  void initState() {
    super.initState();
    _numberCtrl.addListener(_detectCardType);
  }

  void _detectCardType() {
    final n = _numberCtrl.text.replaceAll(' ', '');
    setState(() {
      if (n.startsWith('4')) {
        _cardType = _CardType.visa;
      } else if (n.startsWith('5') || n.startsWith('2')) {
        _cardType = _CardType.mastercard;
      } else if (n.startsWith('3')) {
        _cardType = _CardType.amex;
      } else if (n.startsWith('6')) {
        // RuPay starts with 60, 65, 81, 82, 508 — broadly '6'
        _cardType = _CardType.rupay;
      } else {
        _cardType = _CardType.other;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameCtrl.text.trim().isNotEmpty &&
      _numberCtrl.text.replaceAll(' ', '').length >= 13;

  String get _displayNumber {
    final raw = _numberCtrl.text.replaceAll(' ', '');
    if (raw.isEmpty) return '•••• •••• •••• ••••';
    final groups = <String>[];
    for (int i = 0; i < raw.length; i += 4) {
      groups.add(raw.substring(i, (i + 4).clamp(0, raw.length)));
    }
    return groups.join(' ').padRight(19, '•').substring(0, 19);
  }

  // ── Autofill from scanned data ────────────────────────────────────────────
  void _autofillFromScan(Map<String, String> data) {
    void set(TextEditingController ctrl, String? val) {
      if (val != null && val.isNotEmpty) {
        ctrl.text = val;
        ctrl.selection = TextSelection.collapsed(offset: val.length);
      }
    }

    set(_numberCtrl, data['number']);
    set(_nameCtrl, data['name']);
    set(_expiryCtrl, data['expiry']);
    _detectCardType();
  }

  // ── Open scan sheet ───────────────────────────────────────────────────────
  Future<void> _openScanSheet() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kCoral : _kCoralDark;

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CardScanSheet(isDark: isDark, accentColor: accentColor),
    );
    if (result != null && mounted) {
      _autofillFromScan(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Card details auto-filled!'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final cardNum = _numberCtrl.text.replaceAll(' ', '');
    final last4 = cardNum.length >= 4
        ? cardNum.substring(cardNum.length - 4)
        : cardNum;
    final item = VaultItem(
      id: '',
      type: VaultItemType.card,
      serviceName: _labelCtrl.text.trim().isEmpty
          ? '${_cardType.label} •••• $last4'
          : _labelCtrl.text.trim(),
      username: _nameCtrl.text.trim(),
      password: _numberCtrl.text.trim(),
      notes: 'Expiry: ${_expiryCtrl.text}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ref.read(vaultNotifierProvider.notifier).addItem(item);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.serviceName}" saved to Cards'),
          backgroundColor: _kCoralDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kCoral : _kCoralDark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
            'Add Card',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: true,
          actions: [
            // Scan button
            IconButton(
              onPressed: _openScanSheet,
              tooltip: 'Scan card',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.document_scanner_outlined,
                  color: accentColor,
                  size: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ListenableBuilder(
                listenable: Listenable.merge([_nameCtrl, _numberCtrl]),
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
            // ── Card Preview ──────────────────────────────────────────
            _buildCardPreview(isDark),
            const SizedBox(height: 16),

            // ── Scan chip hint ────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _openScanSheet,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? accentColor.withValues(alpha: 0.14)
                        : accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.document_scanner_outlined,
                        color: accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Scan Card to Auto-fill',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Form ─────────────────────────────────────────────────
            _SectionLabel(isDark: isDark, label: 'CARDHOLDER NAME'),
            const SizedBox(height: 8),
            _CardField(
              controller: _nameCtrl,
              isDark: isDark,
              accentColor: accentColor,
              hintText: 'Full name on card',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            _SectionLabel(isDark: isDark, label: 'CARD NUMBER'),
            const SizedBox(height: 8),
            _CardNumberField(
              controller: _numberCtrl,
              isDark: isDark,
              accentColor: accentColor,
              cardLabel: _cardType.label,
            ),
            const SizedBox(height: 4),

            // Card network chips
            //_buildNetworkChips(isDark),
            //const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(isDark: isDark, label: 'EXPIRY DATE'),
                      const SizedBox(height: 8),
                      _ExpiryField(
                        controller: _expiryCtrl,
                        isDark: isDark,
                        accentColor: accentColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(isDark: isDark, label: 'CVV'),
                      const SizedBox(height: 8),
                      _CvvField(
                        controller: _cvvCtrl,
                        isDark: isDark,
                        accentColor: accentColor,
                        visible: _cvvVisible,
                        onToggle: () =>
                            setState(() => _cvvVisible = !_cvvVisible),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _SectionLabel(isDark: isDark, label: 'LABEL (OPTIONAL)'),
            const SizedBox(height: 8),
            _CardField(
              controller: _labelCtrl,
              isDark: isDark,
              accentColor: accentColor,
              hintText: 'e.g. My HDFC Card',
              icon: Icons.label_outline,
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canSave ? _save : null,
                icon: const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Save Card',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  disabledBackgroundColor: accentColor.withValues(alpha: 0.3),
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
      ),
    );
  }

  // ── Network type chips ─────────────────────────────────────────────────────
  Widget _buildNetworkChips(bool isDark) {
    return Row(
      children: _CardType.values.map((type) {
        final isSelected = _cardType == type;
        final chipColor = isSelected
            ? type.gradientColors.last
            : (isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05));
        return GestureDetector(
          onTap: () {
            setState(() => _cardType = type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: isSelected ? 0.18 : 1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? type.gradientColors.last.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              type.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? type.gradientColors.last
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.4)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Card preview ───────────────────────────────────────────────────────────
  Widget _buildCardPreview(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 195,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: _cardType.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _cardType.gradientColors.last.withValues(alpha: 0.38),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _cardType.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                    Icon(
                      Icons.contactless_outlined,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 22,
                    ),
                  ],
                ),
                Container(
                  width: 38,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Text(
                  _displayNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    fontFamily: 'monospace',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARDHOLDER',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          _nameCtrl.text.isEmpty
                              ? 'YOUR NAME'
                              : _nameCtrl.text.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Real Card Scan Sheet (ml_card_scanner) ────────────────────────────────
class _CardScanSheet extends StatefulWidget {
  final bool isDark;
  final Color accentColor;
  const _CardScanSheet({required this.isDark, required this.accentColor});

  @override
  State<_CardScanSheet> createState() => _CardScanSheetState();
}

class _CardScanSheetState extends State<_CardScanSheet> {
  final ScannerWidgetController _controller = ScannerWidgetController();
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _controller.setCardListener((CardInfo? info) {
      if (!mounted || _scanned || info == null) return;
      setState(() => _scanned = true);
      _controller.disableCameraPreview();

      final number = info.number;
      final expiry = info.expiry;
      // ml_card_scanner does not extract cardholder name
      final Map<String, String> result = {'number': number, 'expiry': expiry};

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) Navigator.of(context).pop(result);
      });
    });
    _controller.setErrorListener((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanner error: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.disableCameraPreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final accent = widget.accentColor;
    final sheetBg = isDark ? const Color(0xFF0E0D16) : const Color(0xFF1A1A2E);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.85,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Scan Your Card',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hold your card steady inside the frame',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // ── Scanner widget ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ScannerWidget(
                        controller: _controller,
                        oneShotScanning: true,
                        scannerDelay: 400,
                        cameraResolution: CameraResolution.high,
                        overlayOrientation: CardOrientation.landscape,
                      ),
                      // Detected overlay
                      if (_scanned)
                        Container(
                          color: Colors.green.withValues(alpha: 0.3),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.greenAccent,
                                  size: 56,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Card Detected!',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
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

            const SizedBox(height: 16),
            // Access denied or tips row
            _buildTips(accent),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Enter manually instead',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTips(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.light_mode_outlined,
            color: accent.withValues(alpha: 0.7),
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            'Ensure good lighting and a flat surface',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final bool isDark;
  final String label;
  const _SectionLabel({required this.isDark, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: isDark
            ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
            : const Color(0xFF464555).withValues(alpha: 0.55),
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color accentColor;
  final String hintText;
  final IconData icon;
  const _CardField({
    required this.controller,
    required this.isDark,
    required this.accentColor,
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1A24) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.4),
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.25)
                : const Color(0xFF464555).withValues(alpha: 0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: accentColor.withValues(alpha: 0.6),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }
}

class _CardNumberField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color accentColor;
  final String cardLabel;

  const _CardNumberField({
    required this.controller,
    required this.isDark,
    required this.accentColor,
    required this.cardLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1A24) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.4),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 19,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _CardNumberFormatter(),
        ],
        style: TextStyle(
          fontSize: 16,
          letterSpacing: 3,
          fontFamily: 'monospace',
          color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: '•••• •••• •••• ••••',
          hintStyle: TextStyle(
            letterSpacing: 2,
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : const Color(0xFF464555).withValues(alpha: 0.35),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.credit_card_outlined,
            color: accentColor.withValues(alpha: 0.6),
            size: 20,
          ),
          suffixText: cardLabel,
          suffixStyle: TextStyle(
            color: accentColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }
}

class _ExpiryField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color accentColor;
  const _ExpiryField({
    required this.controller,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1A24) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.4),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 5,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _ExpiryFormatter(),
        ],
        style: TextStyle(
          fontSize: 14,
          letterSpacing: 1,
          color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: 'MM/YY',
          hintStyle: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.25)
                : const Color(0xFF464555).withValues(alpha: 0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
            color: accentColor.withValues(alpha: 0.6),
            size: 18,
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }
}

class _CvvField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color accentColor;
  final bool visible;
  final VoidCallback onToggle;
  const _CvvField({
    required this.controller,
    required this.isDark,
    required this.accentColor,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1A24) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.4),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        obscureText: !visible,
        maxLength: 4,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 14,
          letterSpacing: 3,
          color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: '•••',
          hintStyle: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.25)
                : const Color(0xFF464555).withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: accentColor.withValues(alpha: 0.6),
            size: 18,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : const Color(0xFF464555).withValues(alpha: 0.4),
            ),
            onPressed: onToggle,
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }
}

// ── Input Formatters ────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length >= 3) {
      final formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return newValue;
  }
}
