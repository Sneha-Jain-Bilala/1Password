import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../backend/vault_item.dart';
import '../backend/service_logo_resolver.dart';

class ItemDetailScreen extends StatefulWidget {
  final VaultItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final Set<String> _revealed = {};

  bool _isRevealed(String key) => _revealed.contains(key);

  void _toggleReveal(String key) {
    setState(() {
      if (_revealed.contains(key)) {
        _revealed.remove(key);
      } else {
        _revealed.add(key);
      }
    });
  }

  Future<void> _copy(BuildContext context, String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final item = widget.item;
    final logo = ServiceLogoResolver.fromServiceName(
      item.serviceName,
      itemType: item.type,
      fallbackColor: item.serviceColor,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? const Color(0xFFC4C0FF) : const Color(0xFF4D41DF),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          item.serviceName,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _TypeBadgeChip(type: item.type, isDark: isDark),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // ── Identity Hero Card ──────────────────────────────────
          _buildHeroCard(context, item, logo, isDark),
          const SizedBox(height: 24),

          // ── Fields by type ────────────────────────────────────
          ..._buildFields(context, item, isDark),

          // ── Metadata ─────────────────────────────────────────
          if (item.folderName != null && item.folderName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildField(
              context: context,
              label: 'Folder',
              value: item.folderName!,
              icon: Icons.folder_outlined,
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 8),
          _buildMetaRow(context, item, isDark),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    VaultItem item,
    ServiceLogoData logo,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1A24) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.3),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: logo.color.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(child: logo.buildWidget(size: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.serviceName,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: isDark
                        ? const Color(0xFFE5E0EE)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
                if (item.domain != null && item.domain!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.domain!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
                          : const Color(0xFF464555).withValues(alpha: 0.55),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      item.isFavourite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: item.isFavourite
                          ? const Color(0xFFFFB300)
                          : (isDark
                                ? const Color(0xFFC7C4D8).withValues(alpha: 0.35)
                                : const Color(0xFF464555).withValues(alpha: 0.35)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.isFavourite ? 'Favourite' : 'Not favourited',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFC7C4D8).withValues(alpha: 0.4)
                            : const Color(0xFF464555).withValues(alpha: 0.45),
                      ),
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

  List<Widget> _buildFields(BuildContext context, VaultItem item, bool isDark) {
    switch (item.type) {
      case VaultItemType.login:
        return _buildLoginFields(context, item, isDark);
      case VaultItemType.secureNote:
        return _buildNoteFields(context, item, isDark);
      case VaultItemType.card:
        return _buildCardFields(context, item, isDark);
      case VaultItemType.address:
        return _buildAddressFields(context, item, isDark);
      default:
        return _buildGenericFields(context, item, isDark);
    }
  }

  List<Widget> _buildLoginFields(
    BuildContext context,
    VaultItem item,
    bool isDark,
  ) {
    return [
      if (item.username != null && item.username!.isNotEmpty) ...[
        _buildField(
          context: context,
          label: 'Username / Email',
          value: item.username!,
          icon: Icons.person_outline,
          isDark: isDark,
          copyKey: 'username',
        ),
        const SizedBox(height: 10),
      ],
      if (item.password != null && item.password!.isNotEmpty) ...[
        _buildField(
          context: context,
          label: 'Password',
          value: item.password!,
          icon: Icons.lock_outline,
          isDark: isDark,
          isSecret: true,
          secretKey: 'password',
          copyKey: 'password',
        ),
        const SizedBox(height: 10),
      ],
      if (item.totpSecret != null && item.totpSecret!.isNotEmpty) ...[
        _buildField(
          context: context,
          label: '2FA Secret',
          value: item.totpSecret!,
          icon: Icons.qr_code_outlined,
          isDark: isDark,
          isSecret: true,
          secretKey: 'totp',
          copyKey: 'totp',
        ),
        const SizedBox(height: 10),
      ],
      if (item.notes != null && item.notes!.isNotEmpty) ...[
        _buildField(
          context: context,
          label: 'Notes',
          value: item.notes!,
          icon: Icons.notes_outlined,
          isDark: isDark,
          multiline: true,
        ),
        const SizedBox(height: 10),
      ],
      if (item.customFields.isNotEmpty) ...[
        _buildCustomFields(context, item, isDark),
      ],
    ];
  }

  List<Widget> _buildNoteFields(
    BuildContext context,
    VaultItem item,
    bool isDark,
  ) {
    return [
      if (item.notes != null && item.notes!.isNotEmpty)
        _buildField(
          context: context,
          label: 'Note Content',
          value: item.notes!,
          icon: Icons.sticky_note_2_outlined,
          isDark: isDark,
          multiline: true,
          copyKey: 'notes',
        ),
    ];
  }

  List<Widget> _buildCardFields(
    BuildContext context,
    VaultItem item,
    bool isDark,
  ) {
    final fields = item.customFields;
    return [
      if (fields['cardHolder'] != null && fields['cardHolder']!.isNotEmpty) ...[
        _buildField(
          context: context,
          label: 'Card Holder',
          value: fields['cardHolder']!,
          icon: Icons.person_outline,
          isDark: isDark,
          copyKey: 'cardHolder',
        ),
        const SizedBox(height: 10),
      ],
      if (fields['cardNumber'] != null && fields['cardNumber']!.isNotEmpty) ...[
        _buildField(
          context: context,
          label: 'Card Number',
          value: fields['cardNumber']!,
          icon: Icons.credit_card,
          isDark: isDark,
          isSecret: true,
          secretKey: 'cardNumber',
          copyKey: 'cardNumber',
          displayTransform: (v) =>
              _isRevealed('cardNumber') ? v : _maskCardNumber(v),
        ),
        const SizedBox(height: 10),
      ],
      if (fields['expiry'] != null && fields['expiry']!.isNotEmpty) ...[
        _buildField(
          context: context,
          label: 'Expiry Date',
          value: fields['expiry']!,
          icon: Icons.calendar_today_outlined,
          isDark: isDark,
          copyKey: 'expiry',
        ),
        const SizedBox(height: 10),
      ],
      if (fields['cvv'] != null && fields['cvv']!.isNotEmpty) ...[
        _buildField(
          context: context,
          label: 'CVV',
          value: fields['cvv']!,
          icon: Icons.security_outlined,
          isDark: isDark,
          isSecret: true,
          secretKey: 'cvv',
          copyKey: 'cvv',
        ),
        const SizedBox(height: 10),
      ],
      if (item.notes != null && item.notes!.isNotEmpty) ...[
        _buildField(
          context: context,
          label: 'Notes',
          value: item.notes!,
          icon: Icons.notes_outlined,
          isDark: isDark,
          multiline: true,
        ),
        const SizedBox(height: 10),
      ],
    ];
  }

  List<Widget> _buildAddressFields(
    BuildContext context,
    VaultItem item,
    bool isDark,
  ) {
    final f = item.customFields;
    final widgets = <Widget>[];

    final addressFields = [
      ('Full Name', 'fullName', Icons.person_outline),
      ('Phone', 'phone', Icons.phone_outlined),
      ('Email', 'email', Icons.email_outlined),
      ('Address Line 1', 'address1', Icons.home_outlined),
      ('Address Line 2', 'address2', Icons.home_work_outlined),
      ('City', 'city', Icons.location_city_outlined),
      ('State / Province', 'state', Icons.map_outlined),
      ('Postal Code', 'postalCode', Icons.markunread_mailbox_outlined),
      ('Country', 'country', Icons.public_outlined),
    ];

    for (final (label, key, icon) in addressFields) {
      if (f[key] != null && f[key]!.isNotEmpty) {
        widgets.add(
          _buildField(
            context: context,
            label: label,
            value: f[key]!,
            icon: icon,
            isDark: isDark,
            copyKey: key,
          ),
        );
        widgets.add(const SizedBox(height: 10));
      }
    }

    if (item.notes != null && item.notes!.isNotEmpty) {
      widgets.add(
        _buildField(
          context: context,
          label: 'Notes',
          value: item.notes!,
          icon: Icons.notes_outlined,
          isDark: isDark,
          multiline: true,
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildGenericFields(
    BuildContext context,
    VaultItem item,
    bool isDark,
  ) {
    final widgets = <Widget>[];
    if (item.username != null && item.username!.isNotEmpty) {
      widgets.add(
        _buildField(
          context: context,
          label: 'Username',
          value: item.username!,
          icon: Icons.person_outline,
          isDark: isDark,
          copyKey: 'username',
        ),
      );
      widgets.add(const SizedBox(height: 10));
    }
    if (item.notes != null && item.notes!.isNotEmpty) {
      widgets.add(
        _buildField(
          context: context,
          label: 'Notes',
          value: item.notes!,
          icon: Icons.notes_outlined,
          isDark: isDark,
          multiline: true,
        ),
      );
    }
    return widgets;
  }

  Widget _buildCustomFields(
    BuildContext context,
    VaultItem item,
    bool isDark,
  ) {
    final skipKeys = {
      'cardHolder',
      'cardNumber',
      'expiry',
      'cvv',
      'fullName',
      'phone',
      'email',
      'address1',
      'address2',
      'city',
      'state',
      'postalCode',
      'country',
    };

    final customEntries = item.customFields.entries
        .where((e) => !skipKeys.contains(e.key) && e.value.isNotEmpty)
        .toList();

    if (customEntries.isEmpty) return const SizedBox.shrink();

    return Column(
      children: customEntries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildField(
            context: context,
            label: _prettifyKey(e.key),
            value: e.value,
            icon: Icons.label_outline,
            isDark: isDark,
            copyKey: e.key,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    bool isSecret = false,
    String? secretKey,
    String? copyKey,
    bool multiline = false,
    String Function(String)? displayTransform,
  }) {
    final theme = Theme.of(context);
    final revealed = secretKey != null && _isRevealed(secretKey);
    final displayValue =
        displayTransform != null
            ? displayTransform(value)
            : (isSecret && !revealed)
            ? '•' * value.length.clamp(8, 20)
            : value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1A24) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.3),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: multiline ? 2 : 0),
            child: Icon(
              icon,
              size: 18,
              color: isDark
                  ? const Color(0xFFC4C0FF).withValues(alpha: 0.6)
                  : const Color(0xFF4D41DF).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontSize: 10,
                    color: isDark
                        ? const Color(0xFFC7C4D8).withValues(alpha: 0.45)
                        : const Color(0xFF464555).withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark
                        ? const Color(0xFFE5E0EE)
                        : const Color(0xFF1A1A2E),
                    letterSpacing: isSecret && !revealed ? 2 : 0,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (isSecret && secretKey != null)
            IconButton(
              icon: Icon(
                revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
              ),
              color: isDark
                  ? const Color(0xFFC7C4D8).withValues(alpha: 0.4)
                  : const Color(0xFF464555).withValues(alpha: 0.4),
              onPressed: () => _toggleReveal(secretKey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          if (copyKey != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 17),
              color: isDark
                  ? const Color(0xFFC7C4D8).withValues(alpha: 0.4)
                  : const Color(0xFF464555).withValues(alpha: 0.4),
              onPressed: () => _copy(context, value, label),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, VaultItem item, bool isDark) {
    final textColor = isDark
        ? const Color(0xFFC7C4D8).withValues(alpha: 0.4)
        : const Color(0xFF464555).withValues(alpha: 0.4);

    String formatDate(DateTime dt) {
      final months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            'Created ${formatDate(item.createdAt)}',
            style: TextStyle(fontSize: 12, color: textColor),
          ),
          const SizedBox(width: 16),
          Icon(Icons.edit_outlined, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            'Updated ${formatDate(item.updatedAt)}',
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ],
      ),
    );
  }

  String _maskCardNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 4) return number;
    final last4 = cleaned.substring(cleaned.length - 4);
    return '**** **** **** $last4';
  }

  String _prettifyKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
        .trim()
        .replaceFirst(key[0], key[0].toUpperCase());
  }
}

// ─── Type Badge Chip ──────────────────────────────────────────────────
class _TypeBadgeChip extends StatelessWidget {
  final VaultItemType type;
  final bool isDark;

  const _TypeBadgeChip({required this.type, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (type) {
      VaultItemType.login => (const Color(0xFF4D41DF), Icons.password),
      VaultItemType.secureNote => (const Color(0xFF006B55), Icons.sticky_note_2_outlined),
      VaultItemType.card => (const Color(0xFFC1282A), Icons.credit_card),
      VaultItemType.address => (const Color(0xFFF57C00), Icons.place_outlined),
      _ => (const Color(0xFF4D41DF), Icons.lock_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            type.browseLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
