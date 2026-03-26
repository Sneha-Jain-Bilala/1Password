import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const AppTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: UnderlineInputBorder(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
