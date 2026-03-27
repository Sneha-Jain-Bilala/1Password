import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  bool _isPinned = false;

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
    final item = VaultItem(
      id: '',
      type: VaultItemType.secureNote,
      serviceName: _titleCtrl.text.trim(),
      notes: _contentCtrl.text.trim(),
      folderName: _folderCtrl.text.trim().isEmpty ? null : _folderCtrl.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ref.read(vaultNotifierProvider.notifier).addItem(item);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.serviceName}" saved to Secure Notes'),
          backgroundColor: _kTealDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
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
            icon: Icon(Icons.arrow_back,
                color: isDark ? const Color(0xFFC4C0FF) : const Color(0xFF1A1A2E)),
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ListenableBuilder(
                listenable: _titleCtrl,
                builder: (context, _) => Opacity(
                  opacity: _canSave ? 1.0 : 0.4,
                  child: ElevatedButton(
                    onPressed: _canSave ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? _kTeal : _kTealDark,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132922) : const Color(0xFFE0FAF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: iconColor.withValues(alpha: isDark ? 0.3 : 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.sticky_note_2_outlined, color: iconColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Note',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Encrypted end-to-end',
                          style: TextStyle(
                            fontSize: 12,
                            color: iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pin toggle
                  GestureDetector(
                    onTap: () => setState(() => _isPinned = !_isPinned),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isPinned
                            ? iconColor.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: _isPinned ? iconColor : iconColor.withValues(alpha: 0.4),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                  color: isDark ? const Color(0xFFE5E0EE) : const Color(0xFF1A1A2E),
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

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canSave ? _save : null,
                icon: Icon(Icons.check_circle_outline, size: 18,
                    color: isDark ? Colors.black : Colors.white),
                label: Text(
                  'Save Note',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? _kTeal : _kTealDark,
                  disabledBackgroundColor: (isDark ? _kTeal : _kTealDark).withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
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
          prefixIcon: Icon(icon, color: iconColor.withValues(alpha: 0.6), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }
}
