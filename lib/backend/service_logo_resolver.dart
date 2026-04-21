import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'vault_item.dart';

class ServiceLogoData {
  final IconData icon;
  final Color color;
  final String? assetPath;

  const ServiceLogoData({
    required this.icon,
    required this.color,
    this.assetPath,
  });

  Widget buildWidget({required double size, Color? fallbackColor}) {
    if (assetPath == null) {
      return Icon(icon, color: fallbackColor ?? color, size: size);
    }

    return Image.asset(
      assetPath!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Icon(icon, color: fallbackColor ?? color, size: size);
      },
    );
  }
}

class ServiceLogoResolver {
  static const Color _defaultBrandColor = Color(0xFF6C63FF);

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
    switch (type) {
      case VaultItemType.login:
        return ServiceLogoData(
          icon: Icons.lock_outline,
          color: fallbackColor ?? _defaultBrandColor,
        );
      case VaultItemType.secureNote:
        return ServiceLogoData(
          icon: FontAwesomeIcons.noteSticky,
          color: fallbackColor ?? const Color(0xFF006B55),
        );
      case VaultItemType.card:
        return ServiceLogoData(
          icon: FontAwesomeIcons.indianRupeeSign,
          color: fallbackColor ?? const Color(0xFF1A73E8),
        );
      case VaultItemType.contact:
        return ServiceLogoData(
          icon: Icons.contacts_outlined,
          color: fallbackColor ?? const Color(0xFF0A66C2),
        );
      case VaultItemType.document:
        return ServiceLogoData(
          icon: Icons.description_outlined,
          color: fallbackColor ?? const Color(0xFF546E7A),
        );
      case VaultItemType.address:
        return ServiceLogoData(
          icon: FontAwesomeIcons.mapLocationDot,
          color: fallbackColor ?? const Color(0xFF34A853),
        );
    }
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
