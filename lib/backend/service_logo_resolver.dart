import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'vault_item.dart';

class ServiceLogoData {
  final Object icon;
  final Color color;
  final String? assetPath;
  final String? monogram;

  const ServiceLogoData({
    required this.icon,
    required this.color,
    this.assetPath,
    this.monogram,
  });

  Widget buildWidget({required double size, Color? fallbackColor}) {
    if (monogram != null && monogram!.isNotEmpty) {
      return Text(
        monogram!,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: TextStyle(
          color: fallbackColor ?? color,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.58,
          letterSpacing: 0.2,
        ),
      );
    }

    Widget buildIcon() {
      if (icon is FaIconData) {
        return FaIcon(icon as FaIconData, color: fallbackColor ?? color, size: size);
      }
      return Icon(icon as IconData, color: fallbackColor ?? color, size: size);
    }

    if (assetPath == null) {
      return buildIcon();
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          assetPath!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) {
            return buildIcon();
          },
        ),
      ),
    );
  }
}

class ServiceLogoResolver {
  static const Color _defaultBrandColor = Color(0xFF6C63FF);
  static const List<Color> _fallbackPalette = [
    Color(0xFF5A67D8),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
  ];

  static final Map<String, ServiceLogoData> _knownByKeyword = {
    'gmail': const ServiceLogoData(
      icon: FontAwesomeIcons.google,
      color: Color(0xFFEA4335),
      assetPath: 'assets/logos/brands/gmail.png',
    ),
    'google': const ServiceLogoData(
      icon: FontAwesomeIcons.google,
      color: Color(0xFF4285F4),
      assetPath: 'assets/logos/brands/google.png',
    ),
    'google maps': const ServiceLogoData(
      icon: FontAwesomeIcons.mapLocationDot,
      color: Color(0xFF34A853),
      assetPath: 'assets/logos/brands/google_maps.png',
    ),
    'maps': const ServiceLogoData(
      icon: FontAwesomeIcons.mapLocationDot,
      color: Color(0xFF34A853),
    ),
    'netflix': const ServiceLogoData(
      icon: FontAwesomeIcons.n,
      color: Color(0xFFE50914),
      assetPath: 'assets/logos/brands/netflix.png',
    ),
    'github': const ServiceLogoData(
      icon: FontAwesomeIcons.github,
      color: Color(0xFF238636),
      assetPath: 'assets/logos/brands/github.png',
    ),
    'amazon': const ServiceLogoData(
      icon: FontAwesomeIcons.amazon,
      color: Color(0xFFFF9900),
      assetPath: 'assets/logos/brands/amazon.png',
    ),
    'flipkart': const ServiceLogoData(
      icon: Icons.shopping_cart_outlined,
      color: Color(0xFF2874F0),
    ),
    'twitter': const ServiceLogoData(
      icon: FontAwesomeIcons.twitter,
      color: Color(0xFF1DA1F2),
      assetPath: 'assets/logos/brands/twitter.png',
    ),
    'x.com': const ServiceLogoData(
      icon: FontAwesomeIcons.xTwitter,
      color: Color(0xFF111111),
      assetPath: 'assets/logos/brands/x.png',
    ),
    'x ': const ServiceLogoData(
      icon: FontAwesomeIcons.xTwitter,
      color: Color(0xFF111111),
    ),
    'facebook': const ServiceLogoData(
      icon: FontAwesomeIcons.facebook,
      color: Color(0xFF1877F2),
      assetPath: 'assets/logos/brands/facebook.png',
    ),
    'instagram': const ServiceLogoData(
      icon: FontAwesomeIcons.instagram,
      color: Color(0xFFE1306C),
      assetPath: 'assets/logos/brands/instagram.png',
    ),
    'linkedin': const ServiceLogoData(
      icon: FontAwesomeIcons.linkedin,
      color: Color(0xFF0A66C2),
      assetPath: 'assets/logos/brands/linkedin.png',
    ),
    'spotify': const ServiceLogoData(
      icon: FontAwesomeIcons.spotify,
      color: Color(0xFF1DB954),
      assetPath: 'assets/logos/brands/spotify.png',
    ),
    'apple': const ServiceLogoData(
      icon: FontAwesomeIcons.apple,
      color: Color(0xFF555555),
      assetPath: 'assets/logos/brands/apple.png',
    ),
    'microsoft': const ServiceLogoData(
      icon: FontAwesomeIcons.microsoft,
      color: Color(0xFF00A4EF),
      assetPath: 'assets/logos/brands/microsoft.png',
    ),
    'slack': const ServiceLogoData(
      icon: FontAwesomeIcons.slack,
      color: Color(0xFF4A154B),
    ),
    'discord': const ServiceLogoData(
      icon: FontAwesomeIcons.discord,
      color: Color(0xFF5865F2),
      assetPath: 'assets/logos/brands/discord.png',
    ),
    'notion': const ServiceLogoData(
      icon: Icons.sticky_note_2_outlined,
      color: Color(0xFF000000),
    ),
    'dropbox': const ServiceLogoData(
      icon: FontAwesomeIcons.dropbox,
      color: Color(0xFF0061FF),
      assetPath: 'assets/logos/brands/dropbox.png',
    ),
    'paypal': const ServiceLogoData(
      icon: FontAwesomeIcons.paypal,
      color: Color(0xFF003087),
      assetPath: 'assets/logos/brands/paypal.png',
    ),
    'rupay': const ServiceLogoData(
      icon: FontAwesomeIcons.indianRupeeSign,
      color: Color(0xFF1A73E8),
      assetPath: 'assets/logos/brands/rupay.png',
    ),
    'ru pay': const ServiceLogoData(
      icon: FontAwesomeIcons.indianRupeeSign,
      color: Color(0xFF1A73E8),
    ),
    'visa': const ServiceLogoData(
      icon: FontAwesomeIcons.ccVisa,
      color: Color(0xFF1A1F71),
      assetPath: 'assets/logos/brands/visa.png',
    ),
    'mastercard': const ServiceLogoData(
      icon: FontAwesomeIcons.ccMastercard,
      color: Color(0xFFEB001B),
      assetPath: 'assets/logos/brands/mastercard.png',
    ),
    'amex': const ServiceLogoData(
      icon: FontAwesomeIcons.ccAmex,
      color: Color(0xFF2E77BB),
      assetPath: 'assets/logos/brands/amex.png',
    ),
    'stripe': const ServiceLogoData(
      icon: FontAwesomeIcons.stripe,
      color: Color(0xFF635BFF),
    ),
    'zoom': const ServiceLogoData(
      icon: Icons.videocam_outlined,
      color: Color(0xFF2D8CFF),
    ),
    'youtube': const ServiceLogoData(
      icon: FontAwesomeIcons.youtube,
      color: Color(0xFFFF0000),
      assetPath: 'assets/logos/brands/youtube.png',
    ),
    'whatsapp': const ServiceLogoData(
      icon: FontAwesomeIcons.whatsapp,
      color: Color(0xFF25D366),
      assetPath: 'assets/logos/brands/whatsapp.png',
    ),
    'telegram': const ServiceLogoData(
      icon: FontAwesomeIcons.telegram,
      color: Color(0xFF2AABEE),
      assetPath: 'assets/logos/brands/telegram.png',
    ),
    'bank': const ServiceLogoData(
      icon: Icons.account_balance_outlined,
      color: Color(0xFF1565C0),
    ),
  };

  static ServiceLogoData fromServiceName(
    String serviceName, {
    VaultItemType? itemType,
    Color? fallbackColor,
  }) {
    final normalized = serviceName.toLowerCase().trim();
    for (final entry in _knownByKeyword.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    final type = itemType ?? VaultItemType.login;
    final seededColor = fallbackColor ?? _seededFallbackColor(normalized);
    final initials = _initialsFromServiceName(serviceName);

    switch (type) {
      case VaultItemType.login:
        return ServiceLogoData(
          icon: Icons.lock_outline,
          color: seededColor,
          monogram: initials,
        );
      case VaultItemType.secureNote:
        return ServiceLogoData(
          icon: Icons.sticky_note_2_rounded,
          color: const Color(0xFF2DD4BF),
        );
      case VaultItemType.card:
        return ServiceLogoData(
          icon: FontAwesomeIcons.indianRupeeSign,
          color: seededColor,
          monogram: initials,
        );
      case VaultItemType.contact:
        return ServiceLogoData(
          icon: Icons.contacts_outlined,
          color: seededColor,
          monogram: initials,
        );
      case VaultItemType.document:
        return ServiceLogoData(
          icon: Icons.description_outlined,
          color: seededColor,
          monogram: initials,
        );
      case VaultItemType.address:
        return ServiceLogoData(
          icon: FontAwesomeIcons.mapLocationDot,
          color: const Color(0xFF34A853),
          assetPath: 'assets/logos/brands/google_maps.png',
        );
    }
  }

  static Color _seededFallbackColor(String normalizedName) {
    if (normalizedName.isEmpty) return _defaultBrandColor;
    final idx = normalizedName.hashCode.abs() % _fallbackPalette.length;
    return _fallbackPalette[idx];
  }

  static String _initialsFromServiceName(String serviceName) {
    final parts = serviceName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      final single = parts.first;
      if (single.length == 1) return single.toUpperCase();
      return single.substring(0, 2).toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static VaultItemType fromActivityItemType(String? itemType) {
    final normalized = (itemType ?? '').toLowerCase().trim();
    if (normalized.contains('password') || normalized.contains('login')) {
      return VaultItemType.login;
    }
    if (normalized.contains('note')) {
      return VaultItemType.secureNote;
    }
    if (normalized.contains('card')) {
      return VaultItemType.card;
    }
    if (normalized.contains('contact')) {
      return VaultItemType.contact;
    }
    if (normalized.contains('doc')) {
      return VaultItemType.document;
    }
    if (normalized.contains('address')) {
      return VaultItemType.address;
    }
    return VaultItemType.login;
  }
}
