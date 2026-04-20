import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../backend/vault_item.dart';
import '../backend/vault_notifier.dart';

const _kOrange = Color(0xFFFFB74D);
const _kOrangeDark = Color(0xFFF57C00);

// Common list of countries for the dropdown
const _kCountries = [
  'India',
  'United States',
  'United Kingdom',
  'Canada',
  'Australia',
  'Germany',
  'France',
  'Japan',
  'Singapore',
  'UAE',
  'Other',
];

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _fullNameCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  String _country = 'India';
  final _labelCtrl = TextEditingController();
  bool _isFavourite = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _fullNameCtrl.text.trim().isNotEmpty &&
      _streetCtrl.text.trim().isNotEmpty &&
      _cityCtrl.text.trim().isNotEmpty;

  String get _addressPreview {
    final parts = <String>[
      if (_fullNameCtrl.text.trim().isNotEmpty) _fullNameCtrl.text.trim(),
      if (_streetCtrl.text.trim().isNotEmpty) _streetCtrl.text.trim(),
      if (_cityCtrl.text.trim().isNotEmpty)
        '${_cityCtrl.text.trim()}${_stateCtrl.text.trim().isEmpty ? '' : ', ${_stateCtrl.text.trim()}'}',
      if (_postalCtrl.text.trim().isNotEmpty) _postalCtrl.text.trim(),
      _country,
    ];
    return parts.isEmpty ? 'Your address preview' : parts.join('\n');
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final label = _labelCtrl.text.trim().isEmpty
        ? '${_fullNameCtrl.text.trim()}, ${_cityCtrl.text.trim()}'
        : _labelCtrl.text.trim();
    final notes = [
      _fullNameCtrl.text.trim(),
      _streetCtrl.text.trim(),
      '${_cityCtrl.text.trim()}, ${_stateCtrl.text.trim()} ${_postalCtrl.text.trim()}'
          .trim(),
      _country,
    ].join('\n');
    final item = VaultItem(
      id: '',
      type: VaultItemType.address,
      serviceName: label,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFavourite: _isFavourite,
    );
    await ref.read(vaultNotifierProvider.notifier).addItem(item);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$label" saved to Addresses'),
          backgroundColor: _kOrangeDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kOrange : _kOrangeDark;

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
            'Add Address',
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
                      icon: Icon(Icons.favorite, size: 16, color: Colors.white),
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

            // Save button
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  _fullNameCtrl,
                  _streetCtrl,
                  _cityCtrl,
                ]),
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
                      elevation: 0,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            // ── Address Preview Card ──────────────────────────────
            _buildPreviewCard(isDark, accentColor),
            const SizedBox(height: 24),

            // ── Form ──────────────────────────────────────────────
            _SectionLabel(isDark: isDark, label: 'FULL NAME'),
            const SizedBox(height: 8),
            _AddressField(
              controller: _fullNameCtrl,
              isDark: isDark,
              accentColor: accentColor,
              hintText: 'e.g. Jane Doe',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            _SectionLabel(isDark: isDark, label: 'STREET ADDRESS'),
            const SizedBox(height: 8),
            _AddressField(
              controller: _streetCtrl,
              isDark: isDark,
              accentColor: accentColor,
              hintText: 'e.g. 123 MG Road, Apt 4B',
              icon: Icons.home_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(isDark: isDark, label: 'CITY'),
                      const SizedBox(height: 8),
                      _AddressField(
                        controller: _cityCtrl,
                        isDark: isDark,
                        accentColor: accentColor,
                        hintText: 'City',
                        icon: Icons.location_city_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(isDark: isDark, label: 'STATE'),
                      const SizedBox(height: 8),
                      _AddressField(
                        controller: _stateCtrl,
                        isDark: isDark,
                        accentColor: accentColor,
                        hintText: 'State',
                        icon: Icons.map_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(isDark: isDark, label: 'POSTAL CODE'),
                      const SizedBox(height: 8),
                      _AddressField(
                        controller: _postalCtrl,
                        isDark: isDark,
                        accentColor: accentColor,
                        hintText: 'Postal code',
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(isDark: isDark, label: 'COUNTRY'),
                      const SizedBox(height: 8),
                      _CountryDropdown(
                        isDark: isDark,
                        accentColor: accentColor,
                        value: _country,
                        onChanged: (v) => setState(() => _country = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _SectionLabel(isDark: isDark, label: 'LABEL (OPTIONAL)'),
            const SizedBox(height: 8),
            _AddressField(
              controller: _labelCtrl,
              isDark: isDark,
              accentColor: accentColor,
              hintText: 'e.g. Home, Office…',
              icon: Icons.label_outline,
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: _isFavourite
                      ? ElevatedButton.icon(
                          onPressed: () =>
                              setState(() => _isFavourite = !_isFavourite),
                          icon: Icon(
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

  Widget _buildPreviewCard(bool isDark, Color accentColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E241F) : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.place_outlined, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _addressPreview,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: isDark
                    ? const Color(0xFFE5E0EE)
                    : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────────────────────

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

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color accentColor;
  final String hintText;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  const _AddressField({
    required this.controller,
    required this.isDark,
    required this.accentColor,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
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
        maxLines: maxLines,
        keyboardType: keyboardType,
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
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Icon(
              icon,
              color: accentColor.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: maxLines > 1
              ? const EdgeInsets.symmetric(vertical: 14, horizontal: 16)
              : const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  final bool isDark;
  final Color accentColor;
  final String value;
  final ValueChanged<String?> onChanged;
  const _CountryDropdown({
    required this.isDark,
    required this.accentColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1A24) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.4),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1C1A24) : Colors.white,
          icon: Icon(
            Icons.expand_more_rounded,
            color: accentColor.withValues(alpha: 0.6),
            size: 20,
          ),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
          ),
          items: _kCountries
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
