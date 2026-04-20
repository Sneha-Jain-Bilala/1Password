import 'package:flutter/material.dart';

/// Activity type enum to track different vault operations.
enum ActivityType {
  passwordAdded, // New password added
  passwordUpdated, // Password changed
  passwordDeleted, // Password deleted/trashed
  noteAdded, // New note added
  noteUpdated, // Note updated
  noteDeleted, // Note deleted
  cardAdded, // New card added
  cardUpdated, // Card updated
  cardDeleted, // Card deleted
  contactAdded, // New contact added
  contactUpdated, // Contact updated
  contactDeleted, // Contact deleted
  documentAdded, // New document added
  documentUpdated, // Document updated
  documentDeleted, // Document deleted
  addressAdded, // New address added
  addressUpdated, // Address updated
  addressDeleted, // Address deleted
  passwordCopied, // Password copied to clipboard
  biometricUnlock, // App unlocked with biometric
  masterPasswordUnlock, // App unlocked with master password
  itemViewed, // Item details viewed
  itemFavourited, // Item marked as favourite
  itemUnfavourited, // Item unmarked from favourite
  syncStarted, // Sync with Supabase started
  syncCompleted, // Sync completed successfully
  syncFailed, // Sync failed
}

/// Extension for activity type display labels.
extension ActivityTypeX on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.passwordAdded:
        return 'Password Added';
      case ActivityType.passwordUpdated:
        return 'Password Changed';
      case ActivityType.passwordDeleted:
        return 'Password Deleted';
      case ActivityType.noteAdded:
        return 'Note Added';
      case ActivityType.noteUpdated:
        return 'Note Updated';
      case ActivityType.noteDeleted:
        return 'Note Deleted';
      case ActivityType.cardAdded:
        return 'Card Added';
      case ActivityType.cardUpdated:
        return 'Card Updated';
      case ActivityType.cardDeleted:
        return 'Card Deleted';
      case ActivityType.contactAdded:
        return 'Contact Added';
      case ActivityType.contactUpdated:
        return 'Contact Updated';
      case ActivityType.contactDeleted:
        return 'Contact Deleted';
      case ActivityType.documentAdded:
        return 'Document Added';
      case ActivityType.documentUpdated:
        return 'Document Updated';
      case ActivityType.documentDeleted:
        return 'Document Deleted';
      case ActivityType.addressAdded:
        return 'Address Added';
      case ActivityType.addressUpdated:
        return 'Address Updated';
      case ActivityType.addressDeleted:
        return 'Address Deleted';
      case ActivityType.passwordCopied:
        return 'Password Copied';
      case ActivityType.biometricUnlock:
        return 'Biometric Unlock';
      case ActivityType.masterPasswordUnlock:
        return 'Master Password Unlock';
      case ActivityType.itemViewed:
        return 'Item Viewed';
      case ActivityType.itemFavourited:
        return 'Added to Favourites';
      case ActivityType.itemUnfavourited:
        return 'Removed from Favourites';
      case ActivityType.syncStarted:
        return 'Sync Started';
      case ActivityType.syncCompleted:
        return 'Sync Completed';
      case ActivityType.syncFailed:
        return 'Sync Failed';
    }
  }

  /// Get icon for this activity type.
  IconData get icon {
    switch (this) {
      case ActivityType.passwordAdded:
      case ActivityType.passwordUpdated:
        return Icons.vpn_key;
      case ActivityType.passwordDeleted:
        return Icons.delete_outline;
      case ActivityType.noteAdded:
      case ActivityType.noteUpdated:
        return Icons.note;
      case ActivityType.noteDeleted:
        return Icons.delete_outline;
      case ActivityType.cardAdded:
      case ActivityType.cardUpdated:
        return Icons.credit_card;
      case ActivityType.cardDeleted:
        return Icons.delete_outline;
      case ActivityType.contactAdded:
      case ActivityType.contactUpdated:
        return Icons.person;
      case ActivityType.contactDeleted:
        return Icons.delete_outline;
      case ActivityType.documentAdded:
      case ActivityType.documentUpdated:
        return Icons.description;
      case ActivityType.documentDeleted:
        return Icons.delete_outline;
      case ActivityType.addressAdded:
      case ActivityType.addressUpdated:
        return Icons.location_on;
      case ActivityType.addressDeleted:
        return Icons.delete_outline;
      case ActivityType.passwordCopied:
        return Icons.content_copy;
      case ActivityType.biometricUnlock:
        return Icons.fingerprint;
      case ActivityType.masterPasswordUnlock:
        return Icons.lock_open;
      case ActivityType.itemViewed:
        return Icons.visibility;
      case ActivityType.itemFavourited:
        return Icons.star;
      case ActivityType.itemUnfavourited:
        return Icons.star_outline;
      case ActivityType.syncStarted:
      case ActivityType.syncCompleted:
        return Icons.sync;
      case ActivityType.syncFailed:
        return Icons.sync_problem;
    }
  }

  /// Get color for this activity type.
  Color? getColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (this) {
      case ActivityType.passwordAdded:
      case ActivityType.noteAdded:
      case ActivityType.cardAdded:
      case ActivityType.contactAdded:
      case ActivityType.documentAdded:
      case ActivityType.addressAdded:
      case ActivityType.itemFavourited:
      case ActivityType.syncCompleted:
        return theme.colorScheme.secondary; // Green for additions
      case ActivityType.passwordUpdated:
      case ActivityType.noteUpdated:
      case ActivityType.cardUpdated:
      case ActivityType.contactUpdated:
      case ActivityType.documentUpdated:
      case ActivityType.addressUpdated:
        return theme.colorScheme.primary; // Blue for updates
      case ActivityType.passwordDeleted:
      case ActivityType.noteDeleted:
      case ActivityType.cardDeleted:
      case ActivityType.contactDeleted:
      case ActivityType.documentDeleted:
      case ActivityType.addressDeleted:
      case ActivityType.syncFailed:
        return theme.colorScheme.error; // Red for deletions/errors
      default:
        return null;
    }
  }
}

/// Core activity entry. Immutable value object.
class ActivityItem {
  final String id;
  final ActivityType type;
  final String
  itemName; // The name of the vault item involved (e.g., "Netflix", "GitHub")
  final String? itemType; // Type of item (login, note, card, etc.)
  final String? description; // Optional additional details
  final DateTime timestamp;
  final bool
  isHighlighted; // Mark important activities (e.g., deletions, password changes)

  const ActivityItem({
    required this.id,
    required this.type,
    required this.itemName,
    this.itemType,
    this.description,
    required this.timestamp,
    this.isHighlighted = false,
  });

  /// Create a copy with modified fields.
  ActivityItem copyWith({
    String? id,
    ActivityType? type,
    String? itemName,
    String? itemType,
    String? description,
    DateTime? timestamp,
    bool? isHighlighted,
  }) {
    return ActivityItem(
      id: id ?? this.id,
      type: type ?? this.type,
      itemName: itemName ?? this.itemName,
      itemType: itemType ?? this.itemType,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  /// Get time difference label (e.g., "2 hours ago").
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).ceil()}w ago';
    } else {
      return '${(difference.inDays / 30).ceil()}mo ago';
    }
  }
}
