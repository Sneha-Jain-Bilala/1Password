// lib/services/platform_icon_service.dart
//
// Maps a platform/site name to a favicon URL via Google's Favicon API.
// Falls back to a default icon widget when the image fails to load.

import 'package:flutter/material.dart';

class PlatformIconService {
  // Known domain overrides — add more as needed.
  static const Map<String, String> _domainMap = {
    'netflix': 'netflix.com',
    'github': 'github.com',
    'binance': 'binance.com',
    'binance vault': 'binance.com',
    'google': 'google.com',
    'gmail': 'gmail.com',
    'facebook': 'facebook.com',
    'instagram': 'instagram.com',
    'twitter': 'twitter.com',
    'x': 'x.com',
    'linkedin': 'linkedin.com',
    'spotify': 'spotify.com',
    'apple': 'apple.com',
    'amazon': 'amazon.com',
    'dropbox': 'dropbox.com',
    'notion': 'notion.so',
    'slack': 'slack.com',
    'discord': 'discord.com',
    'twitch': 'twitch.tv',
    'reddit': 'reddit.com',
    'paypal': 'paypal.com',
    'stripe': 'stripe.com',
    'figma': 'figma.com',
    'dribbble': 'dribbble.com',
    'dribbble pro': 'dribbble.com',
    'adobe': 'adobe.com',
    'microsoft': 'microsoft.com',
    'outlook': 'outlook.com',
    'yahoo': 'yahoo.com',
    'steam': 'steampowered.com',
    'epic games': 'epicgames.com',
    'coinbase': 'coinbase.com',
    'kraken': 'kraken.com',
    'twitter/x': 'x.com',
  };

  /// Returns a favicon URL for a given platform name.
  /// Uses Google's favicon service (size=64 for crisp rendering at 48dp).
  static String? getFaviconUrl(String platformName) {
    final key = platformName.trim().toLowerCase();
    final domain = _domainMap[key] ?? _inferDomain(key);
    if (domain == null) return null;
    return 'https://www.google.com/s2/favicons?sz=64&domain=$domain';
  }

  /// Tries to infer a domain for unknown platforms (e.g. "My Bank" → null).
  static String? _inferDomain(String name) {
    // Only infer if name looks like a single word / brand (no spaces = treat as TLD).
    if (!name.contains(' ') && name.length > 2) {
      return '$name.com';
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// PlatformIcon widget
// ---------------------------------------------------------------------------

class PlatformIcon extends StatelessWidget {
  final String platformName;
  final double size;

  const PlatformIcon({super.key, required this.platformName, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = PlatformIconService.getFaviconUrl(platformName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(size * 0.33),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? Padding(
              padding: EdgeInsets.all(size * 0.18),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                // Graceful fallback if network image fails
                errorBuilder: (_, _, _) => _fallbackIcon(theme),
                // Show fallback while loading
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _fallbackIcon(theme);
                },
              ),
            )
          : _fallbackIcon(theme),
    );
  }

  Widget _fallbackIcon(ThemeData theme) {
    return Icon(
      Icons.language,
      size: size * 0.5,
      color: theme.colorScheme.primary,
    );
  }
}
