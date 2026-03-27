import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../backend/vault_item.dart';
import '../backend/vault_notifier.dart';

// Each category uses colors drawn from the app's design system:
// Primary family: #C4C0FF (lavender), #8781FF (purple), #4D41DF (indigo)
// Secondary: #41EEC2 (teal), #28DFB5 (mint)
// Accent warm: #F16161 (coral), #FFB3B0 (rose)
// Neutral: surface containers
class _Category {
  final IconData icon;
  final String title;
  final VaultItemType?
  itemType; // null = no matching type yet (Trash, Folders, Shared)
  final Color darkIconColor;
  final Color darkCardColor;
  final Color lightIconColor;
  final Color lightCardColor;

  const _Category({
    required this.icon,
    required this.title,
    this.itemType,
    required this.darkIconColor,
    required this.darkCardColor,
    required this.lightIconColor,
    required this.lightCardColor,
  });
}

const _categories = [
  _Category(
    icon: Icons.password,
    title: 'Passwords',
    itemType: VaultItemType.login,
    darkIconColor: Color(0xFFC4C0FF),
    darkCardColor: Color(0xFF1F1D2E),
    lightIconColor: Color(0xFF4D41DF),
    lightCardColor: Color(0xFFEEEDFF),
  ),
  _Category(
    icon: Icons.sticky_note_2,
    title: 'Secure Notes',
    itemType: VaultItemType.secureNote,
    darkIconColor: Color(0xFF41EEC2),
    darkCardColor: Color(0xFF132922),
    lightIconColor: Color(0xFF006B55),
    lightCardColor: Color(0xFFE0FAF5),
  ),
  _Category(
    icon: Icons.credit_card,
    title: 'Cards',
    itemType: VaultItemType.card,
    darkIconColor: Color(0xFFFFB3B0),
    darkCardColor: Color(0xFF2A1B1B),
    lightIconColor: Color(0xFFC1282A),
    lightCardColor: Color(0xFFFFF0F0),
  ),
];

class _RecentCollection {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color darkIconColor;
  final Color lightIconColor;

  const _RecentCollection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.darkIconColor,
    required this.lightIconColor,
  });
}

const _recent = [
  _RecentCollection(
    icon: Icons.work_outline,
    title: 'Work Passwords',
    subtitle: 'Modified 2 hours ago',
    darkIconColor: Color(0xFFC4C0FF),
    lightIconColor: Color(0xFF4D41DF),
  ),
  _RecentCollection(
    icon: Icons.family_restroom,
    title: 'Family Shared',
    subtitle: 'Modified yesterday',
    darkIconColor: Color(0xFF41EEC2),
    lightIconColor: Color(0xFF006B55),
  ),
];

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFFC4C0FF), const Color(0xFF8781FF)]
                      : [const Color(0xFF675DF9), const Color(0xFF4D41DF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.security, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'VaultKey',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark
                    ? const Color(0xFFC4C0FF)
                    : const Color(0xFF1A1A2E),
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? const Color(0xFFC4C0FF) : const Color(0xFF4D41DF),
            ),
            onPressed: () {},
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF8781FF), const Color(0xFF4D41DF)]
                    : [const Color(0xFF675DF9), const Color(0xFF4D41DF)],
              ),
            ),
            child: const Center(
              child: Text(
                'JD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        children: [
          Text(
            'Browse Vault',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1A24) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFC7C4D8).withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFFC4C0FF).withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFE5E0EE)
                    : const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                hintText: 'Search your vault...',
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFFC7C4D8).withValues(alpha: 0.4)
                      : const Color(0xFF464555).withValues(alpha: 0.45),
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? const Color(0xFFC4C0FF).withValues(alpha: 0.5)
                      : const Color(0xFF4D41DF).withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Grid
          GridView.builder(
            itemCount: _categories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final count = cat.itemType != null
                  ? ref
                        .watch(vaultNotifierProvider.notifier)
                        .countByType(cat.itemType!)
                  : 0;
              return _buildCategoryCard(context, cat, isDark, count);
            },
          ),
          const SizedBox(height: 32),

          // Recent Collections header
          Text(
            'RECENT COLLECTIONS',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: isDark
                  ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
                  : const Color(0xFF464555).withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),

          ..._recent.map((r) => _buildRecentItem(context, r, isDark)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    _Category cat,
    bool isDark,
    int count,
  ) {
    final cardColor = isDark ? cat.darkCardColor : cat.lightCardColor;
    final iconColor = isDark ? cat.darkIconColor : cat.lightIconColor;
    // Icon bg sits on a slightly lighter/darker shade within the card
    final iconBg = isDark
        ? iconColor.withValues(alpha: 0.15)
        : iconColor.withValues(alpha: 0.12);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(22),
        splashColor: iconColor.withValues(alpha: 0.08),
        highlightColor: iconColor.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(cat.icon, color: iconColor, size: 24),
              ),
              // Title + Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDark
                          ? const Color(0xFFE5E0EE)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isDark ? 0.2 : 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentItem(
    BuildContext context,
    _RecentCollection r,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final iconColor = isDark ? r.darkIconColor : r.lightIconColor;
    final cardColor = isDark ? const Color(0xFF1C1A24) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFC7C4D8).withValues(alpha: 0.3),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(r.icon, color: iconColor, size: 22),
        ),
        title: Text(
          r.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Text(
          r.subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? const Color(0xFFC7C4D8).withValues(alpha: 0.5)
                : const Color(0xFF464555).withValues(alpha: 0.55),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark
              ? const Color(0xFFC7C4D8).withValues(alpha: 0.3)
              : const Color(0xFF464555).withValues(alpha: 0.3),
        ),
        onTap: () {},
      ),
    );
  }
}
