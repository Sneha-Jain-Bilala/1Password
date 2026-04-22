import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../backend/vault_item.dart';
import '../backend/vault_notifier.dart';

const _kTeal = Color(0xFF41EEC2);
const _kTealDark = Color(0xFF006B55);

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _folderCtrl = TextEditingController();
  bool _isFavourite = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _folderCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _titleCtrl.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_canSave) return;

    try {
      final item = VaultItem(
        id: const Uuid().v4(),
        type: VaultItemType.secureNote,
        serviceName: _titleCtrl.text.trim(),
        notes: _contentCtrl.text.trim(),
        folderName: _folderCtrl.text.trim().isEmpty
            ? null
            : _folderCtrl.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavourite: _isFavourite,
      );

      await ref.read(vaultNotifierProvider.notifier).addItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item.serviceName}" saved to Secure Notes'),
            backgroundColor: _kTealDark,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? _kTeal : _kTealDark;

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
            'New Secure Note',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            const SizedBox(height: 24),

            // Title field
            _SectionLabel(isDark: isDark, label: 'TITLE'),
            const SizedBox(height: 8),
            _NoteField(
              controller: _titleCtrl,
              isDark: isDark,
              iconColor: iconColor,
              hintText: 'e.g. WiFi Password, API Keys…',
              icon: Icons.title,
            ),
            const SizedBox(height: 20),

            // Content field
            _SectionLabel(isDark: isDark, label: 'NOTE'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1A24) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : const Color(0xFFC7C4D8).withValues(alpha: 0.4),
                ),
              ),
              child: TextField(
                controller: _contentCtrl,
                maxLines: 10,
                minLines: 6,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFE5E0EE)
                      : const Color(0xFF1A1A2E),
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your note here…',
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFF464555).withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Folder field
            _SectionLabel(isDark: isDark, label: 'FOLDER (OPTIONAL)'),
            const SizedBox(height: 8),
            _NoteField(
              controller: _folderCtrl,
              isDark: isDark,
              iconColor: iconColor,
              hintText: 'e.g. Work, Personal…',
              icon: Icons.folder_outlined,
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
                            color: isDark ? Colors.black : Colors.white,
                          ),
                          label: Text(
                            'Favourite',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? _kTeal : _kTealDark,
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
                            color: isDark ? _kTeal : _kTealDark,
                          ),
                          label: Text(
                            'Favourite',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isDark ? _kTeal : _kTealDark,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? _kTeal : _kTealDark,
                            ),
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
                    icon: Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                    label: Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? _kTeal : _kTealDark,
                      disabledBackgroundColor: (isDark ? _kTeal : _kTealDark)
                          .withValues(alpha: 0.3),
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
}

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

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color iconColor;
  final String hintText;
  final IconData icon;
  const _NoteField({
    required this.controller,
    required this.isDark,
    required this.iconColor,
    required this.hintText,
    required this.icon,
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
          prefixIcon: Icon(
            icon,
            color: iconColor.withValues(alpha: 0.6),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }
}
