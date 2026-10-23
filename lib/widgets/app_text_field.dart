import 'package:flutter/material.dart';

/// Lab 2 *Text field*: default, focused, filled, error, disabled.
/// Focused and filled come from the controller and focus node; error shows an
/// icon plus the message under the field (never colour alone).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.semanticId,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? errorText;
  final bool enabled;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? semanticId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticId,
      textField: true,
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: errorText == null ? helper : null,
          errorText: errorText,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          suffixIcon: errorText == null ? null : const Icon(Icons.error_outline),
        ),
      ),
    );
  }
}

/// Search variant used on Browse: leading search icon, clear action.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
    this.hint = 'Team name, topic or skill',
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'browse_search_field',
      textField: true,
      label: 'Search teams',
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(tooltip: 'Clear search', icon: const Icon(Icons.close), onPressed: onClear),
          ),
        ),
      ),
    );
  }
}
