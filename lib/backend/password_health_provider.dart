// lib/backend/password_health_provider.dart
//
// Computes password health metrics from the user's vault in real-time.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vault_item.dart';
import 'vault_notifier.dart';

/// Password strength classification.
enum PasswordStrength { strong, medium, weak }

/// Immutable snapshot of the computed health data.
class PasswordHealthData {
  final int totalPasswords;
  final int strongCount;
  final int mediumCount;
  final int weakCount;
  final int reusedCount;

  /// 0–100 score derived from quality of passwords.
  final int score;

  /// Human-readable label for the score band.
  final String scoreLabel;

  const PasswordHealthData({
    required this.totalPasswords,
    required this.strongCount,
    required this.mediumCount,
    required this.weakCount,
    required this.reusedCount,
    required this.score,
    required this.scoreLabel,
  });

  static const PasswordHealthData empty = PasswordHealthData(
    totalPasswords: 0,
    strongCount: 0,
    mediumCount: 0,
    weakCount: 0,
    reusedCount: 0,
    score: 0,
    scoreLabel: 'No Data',
  );

  /// Progress value [0.0 – 1.0] for a CircularProgressIndicator.
  double get progress => totalPasswords == 0 ? 0 : score / 100;
}

/// Classifies a single password string.
PasswordStrength _classify(String password) {
  final hasUpper = password.contains(RegExp(r'[A-Z]'));
  final hasLower = password.contains(RegExp(r'[a-z]'));
  final hasDigit = password.contains(RegExp(r'[0-9]'));
  final hasSpecial = password.contains(RegExp(r'[^A-Za-z0-9]'));
  final length = password.length;

  if (length >= 12 && hasUpper && hasLower && hasDigit && hasSpecial) {
    return PasswordStrength.strong;
  }
  if (length >= 8 && (hasDigit || hasSpecial)) {
    return PasswordStrength.medium;
  }
  return PasswordStrength.weak;
}

/// Reactive provider — recomputes whenever the vault changes.
final passwordHealthProvider = Provider<PasswordHealthData>((ref) {
  final allItems = ref.watch(vaultNotifierProvider);

  // Only analyse login items that actually have a password stored.
  final loginItems = allItems
      .where(
        (item) =>
            item.type == VaultItemType.login &&
            item.password != null &&
            item.password!.isNotEmpty,
      )
      .toList();

  if (loginItems.isEmpty) return PasswordHealthData.empty;

  final total = loginItems.length;
  int strong = 0;
  int medium = 0;
  int weak = 0;

  // Count by strength
  for (final item in loginItems) {
    switch (_classify(item.password!)) {
      case PasswordStrength.strong:
        strong++;
        break;
      case PasswordStrength.medium:
        medium++;
        break;
      case PasswordStrength.weak:
        weak++;
        break;
    }
  }

  // Detect reused passwords (same exact string on >1 item)
  final passwordFrequency = <String, int>{};
  for (final item in loginItems) {
    final pw = item.password!;
    passwordFrequency[pw] = (passwordFrequency[pw] ?? 0) + 1;
  }
  final reused = passwordFrequency.values.where((count) => count > 1).length;

  // Score formula:
  //   Base = (strong * 1.0 + medium * 0.5) / total * 100
  //   Penalty = reused / total * 20   (up to -20 pts for reuse)
  final base = ((strong * 1.0 + medium * 0.5) / total * 100);
  final penalty = (reused / total * 20);
  final rawScore = (base - penalty).clamp(0.0, 100.0);
  final score = rawScore.round();

  final label = score >= 90
      ? 'Excellent'
      : score >= 75
      ? 'Good'
      : score >= 50
      ? 'Fair'
      : 'Weak';

  return PasswordHealthData(
    totalPasswords: total,
    strongCount: strong,
    mediumCount: medium,
    weakCount: weak,
    reusedCount: reused,
    score: score,
    scoreLabel: label,
  );
});
