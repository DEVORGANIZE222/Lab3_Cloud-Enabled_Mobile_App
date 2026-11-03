import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

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
    // Identifier only: a `textField: true` wrapper adds a second, non-editable
    // EditText node that swallows text typed by TalkBack or ARTEMIS.
    return Semantics(
      identifier: semanticId,
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
    this.onChanged,
    this.hint = 'Team name, topic or skill',
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final ValueChanged<String>? onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    // Only the identifier is added here. Declaring `textField`/`label` on this
    // wrapper created a second, non-editable EditText node above the real one,
    // so TalkBack and ARTEMIS typed into a node that dropped the text.
    return Semantics(
      identifier: 'browse_search_field',
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          // Figma: grey filled search bar without an outline; focus keeps the
          // 2 dp primary ring from the theme so the field is still findable.
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            enabledBorder: const OutlineInputBorder(borderRadius: AppRadius.cardAll, borderSide: BorderSide.none),
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
