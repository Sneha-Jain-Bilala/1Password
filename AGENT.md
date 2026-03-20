# VaultKey — Agent Instructions (AGENT.md)

> This file defines how AI coding agents (Cursor, GitHub Copilot, Claude Code, etc.) should understand and work within the VaultKey codebase. Read this file in full before making any changes.

---

## 1. Project Identity

**App Name:** VaultKey  
**Type:** Android Password Manager & Vault  
**Tech Stack:** Flutter (Dart) · Supabase · Hive · Riverpod  
**Minimum Android SDK:** 26 (Android 8.0 Oreo)  
**Target SDK:** 35 (Android 15)

---

## 2. Architecture

VaultKey follows **Clean Architecture** with strict layer separation.

```
lib/
├── core/                    # Shared utilities, constants, theme, DI
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── theme/               # Color palette, typography, component themes
│   └── utils/
├── features/                # Feature-first folder structure
│   ├── auth/                # Biometric + Master Password unlock flow
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── vault/               # All vault item CRUD
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── autofill/            # Android AutofillService integration
│   ├── health/              # Password health dashboard
│   ├── sync/                # Supabase sync logic
│   ├── onboarding/          # First-run flow
│   ├── settings/            # App settings
│   └── import_export/       # Import/export flows
├── shared/
│   ├── widgets/             # Reusable UI components
│   └── services/            # Encryption, biometric, clipboard services
└── main.dart
```

### Layer Rules

| Layer | Allowed Dependencies | Forbidden |
|-------|----------------------|-----------|
| `presentation/` | `domain/`, `shared/widgets/`, `core/` | Direct DB or API calls |
| `domain/` | `core/` | Flutter, Supabase, drift, any package |
| `data/` | `domain/`, packages | `presentation/` |
| `core/` | Dart stdlib only | All feature layers |

---

## 3. State Management

- **Riverpod** (flutter_riverpod + riverpod_annotation) is the ONLY state management solution.
- Use `@riverpod` code generation for providers.
- `AsyncNotifier` for async state, `Notifier` for sync state.
- Do NOT use `setState`, `InheritedWidget`, `Provider` (old), or `BLoC`.

```dart
// ✅ Correct
@riverpod
class VaultItemsNotifier extends _$VaultItemsNotifier {
  @override
  Future<List<VaultItem>> build() async => ref.watch(vaultRepositoryProvider).getAll();
}

// ❌ Wrong — don't do this
class VaultPage extends StatefulWidget { ... }
```

---

## 4. Security Rules

> **These rules are NON-NEGOTIABLE. Never bypass them.**

1. **Never log passwords, Master Passwords, encryption keys, or recovery codes.** Not even in debug mode.
2. **Never store the Master Password.** Derive an encryption key from it using Argon2id and store only the key in memory (never on disk).
3. **Biometric keys must be in Android Keystore** — use `local_auth` + `flutter_secure_storage` with Keystore-backed storage.
4. **All vault data encrypted at rest** — use `drift` with `sqflite_sqlcipher` or equivalent. The DB must be opened with a derived key, never a plaintext password.
5. **FLAG_SECURE** — apply `FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE)` on the vault screen to prevent screenshots.
6. **HaveIBeenPwned integration** — use k-anonymity model (first 5 chars of SHA-1 hash only). Never send full hash or password.
7. **Supabase sync = E2EE** — encrypt vault item JSON with AES-256-GCM on-device before any Supabase upsert. Supabase stores ciphertext only.
8. **TLS only** — no HTTP. All network calls over HTTPS/TLS 1.3+.
9. **No third-party analytics SDKs** unless explicitly approved. No crashlytics that capture screen content.

---

## 5. Encryption Implementation

```dart
// Canonical encryption approach — do not deviate without review
// Key derivation
final key = await Argon2id.derive(
  password: masterPasswordBytes,
  salt: storedSalt,         // 16 bytes random, stored in secure storage
  iterations: 3,
  memory: 65536,            // 64 MB
  parallelism: 4,
  keyLength: 32,            // 256 bits
);

// Encryption (per vault item)
final cipher = AesGcm.with256bits();
final nonce = generateRandomBytes(12);  // 96-bit nonce, unique per encryption
final encrypted = await cipher.encrypt(plaintext, secretKey: key, nonce: nonce);
// Store: nonce (12 bytes) + ciphertext + tag (16 bytes)

// Biometric key — stored in Android Keystore, never in app storage
final biometricKey = await FlutterSecureStorage().read(
  key: 'vault_key',
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);
```

---

## 6. Database Schema (drift)

```dart
// VaultItems table
class VaultItems extends Table {
  TextColumn get id => text()();                          // UUID v4
  TextColumn get type => text()();                        // 'password' | 'note' | 'card' | 'contact' | 'document'
  TextColumn get title => text()();                       // plaintext (searchable)
  BlobColumn get encryptedData => blob()();               // AES-256-GCM encrypted JSON
  TextColumn get folderId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();  // null = not deleted
  DateTimeColumn get syncedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

// Folders table
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('folder'))();
  DateTimeColumn get createdAt => dateTime()();
}
```

---

## 7. Supabase Schema

```sql
-- Run in Supabase SQL Editor
create table vault_items (
  id uuid primary key,
  user_id uuid references auth.users(id) on delete cascade,
  type text not null,
  title text not null,                    -- plaintext for server-side search (optional: encrypt too)
  encrypted_data bytea not null,          -- AES-256-GCM ciphertext
  folder_id uuid,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  deleted_at timestamptz,
  synced_at timestamptz
);

-- RLS: users can only access their own items
alter table vault_items enable row level security;
create policy "Users own their items"
  on vault_items for all
  using (auth.uid() = user_id);
```

---

## 8. Naming Conventions

| Entity | Convention | Example |
|--------|-----------|---------|
| Files | snake_case | `vault_item_repository.dart` |
| Classes | PascalCase | `VaultItemRepository` |
| Variables/Methods | camelCase | `getVaultItems()` |
| Constants | SCREAMING_SNAKE | `MAX_BIOMETRIC_ATTEMPTS` |
| Riverpod providers | camelCase + `Provider` suffix | `vaultItemsProvider` |
| DB tables | snake_case | `vault_items` |
| Supabase columns | snake_case | `encrypted_data` |
| Routes | lowercase + hyphens | `/vault/add-password` |

---

## 9. UI / Widget Rules

- Use **Material Design 3** (`useMaterial3: true` in ThemeData).
- Import colors only from `core/theme/app_colors.dart` — never hardcode hex values in widgets.
- Use `AppTextStyles` from `core/theme/app_text_styles.dart` — never hardcode `TextStyle`.
- All reusable components live in `shared/widgets/`. Never duplicate widgets across features.
- Minimum touch target: 48×48 logical pixels.
- All `Image` widgets must have a semantic label.
- Use `AutoSizeText` for dynamic text that might overflow.
- Prefer `const` constructors everywhere possible.

### Color Palette Reference

```dart
// core/theme/app_colors.dart
class AppColors {
  static const primary = Color(0xFF6C63FF);       // Electric Violet — trust, authority
  static const secondary = Color(0xFF00D4AA);     // Teal Emerald — safety, success
  static const accent = Color(0xFFFF6B6B);        // Coral Red — urgency, alert
  static const backgroundDark = Color(0xFF0F0E17);// Deep Navy
  static const backgroundLight = Color(0xFFF8F8FF);// Ghost White
  static const surfaceDark = Color(0xFF1A1A2E);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textDark = Color(0xFFFAFAFA);
  static const textLight = Color(0xFF1A1A2E);
  static const success = Color(0xFF2EC97A);
  static const warning = Color(0xFFFFB347);
  static const error = Color(0xFFFF6B6B);
}
```
The app will have both light and dark theme, so configure the app accordingly
---

## 10. Testing Requirements

- **Unit tests**: All `domain/` use cases and `data/` repositories must have unit tests.
- **Widget tests**: All screens in `presentation/` must have widget tests.
- **Integration tests**: Auth flow, vault CRUD, autofill trigger.
- Coverage target: 80% minimum.
- Test files mirror source structure in `test/`.
- Use `mocktail` for mocking (not `mockito`).
- Security-critical functions (encryption, key derivation) require property-based tests with `test` package.

---

## 11. Key Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  drift: ^2.x
  drift_sqflite: ^2.x          # or sqflite_sqlcipher
  supabase_flutter: ^2.x
  local_auth: ^2.x
  flutter_secure_storage: ^9.x
  cryptography: ^2.x            # AES-GCM, Argon2id
  otp: ^3.x                     # TOTP generation
  go_router: ^13.x              # Navigation
  auto_size_text: ^3.x
  flutter_windowmanager: ^0.x   # FLAG_SECURE

dev_dependencies:
  riverpod_generator: ^2.x
  build_runner: ^2.x
  mocktail: ^1.x
  flutter_test:
    sdk: flutter
```

---

## 12. Agent Workflow

When making changes:

1. **Read** the relevant feature's `README.md` (if present) before editing.
2. **Check** `core/theme/` before using any color or text style.
3. **Add tests** for any new domain or data layer code.
4. **Run** `dart analyze` and `flutter test` before marking a task complete.
5. **Never** commit plaintext secrets, API keys, or Supabase credentials. Use `.env` + `flutter_dotenv`.
6. **Always** run `dart run build_runner build` after adding/modifying Riverpod providers or drift tables.
7. For encryption changes, request human review before merging.

---

## 13. Environment Variables

```
# .env (gitignored)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
HIBP_API_BASE=https://api.pwnedpasswords.com
```

Load with `flutter_dotenv`. Never hardcode these values anywhere in the codebase.

---

*Last updated: March 2026 | VaultKey v1.0*