import 'package:flutter/material.dart';

/// Which Browse bucket this item belongs to.
enum VaultItemType {
  login,       // → Passwords
  secureNote,  // → Secure Notes
  card,        // → Cards
  contact,     // → Contacts
  document,    // → Docs
  address,     // → Address
}

/// Maps a [VaultItemType] to the Browse grid label.
extension VaultItemTypeX on VaultItemType {
  String get browseLabel {
    switch (this) {
      case VaultItemType.login:      return 'Passwords';
      case VaultItemType.secureNote: return 'Secure Notes';
      case VaultItemType.card:       return 'Cards';
      case VaultItemType.contact:    return 'Contacts';
      case VaultItemType.document:   return 'Docs';
      case VaultItemType.address:    return 'Address';
    }
  }
}

/// Core vault entry. Immutable value object.
class VaultItem {
  final String id;
  final VaultItemType type;

  // ── service identity ──────────────────────────────────────────
  final String serviceName;
  final String? domain;
  final Color? serviceColor; // display color from known-service DB

  // ── credentials ───────────────────────────────────────────────
  final String? username;
  final String? password;
  final String? totpSecret;

  // ── metadata ──────────────────────────────────────────────────
  final String? notes;
  final String? folderName;
  final Map<String, String> customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultItem({
    required this.id,
    required this.type,
    required this.serviceName,
    this.domain,
    this.serviceColor,
    this.username,
    this.password,
    this.totpSecret,
    this.notes,
    this.folderName,
    this.customFields = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  VaultItem copyWith({
    String? serviceName,
    String? domain,
    Color? serviceColor,
    String? username,
    String? password,
    String? totpSecret,
    String? notes,
    String? folderName,
    Map<String, String>? customFields,
  }) {
    return VaultItem(
      id: id,
      type: type,
      serviceName: serviceName ?? this.serviceName,
      domain: domain ?? this.domain,
      serviceColor: serviceColor ?? this.serviceColor,
      username: username ?? this.username,
      password: password ?? this.password,
      totpSecret: totpSecret ?? this.totpSecret,
      notes: notes ?? this.notes,
      folderName: folderName ?? this.folderName,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Initials shown in the identity card (max 2 chars).
  String get initials {
    final words = serviceName.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    if (serviceName.length >= 2) return serviceName.substring(0, 2).toUpperCase();
    return serviceName.toUpperCase();
  }
}
