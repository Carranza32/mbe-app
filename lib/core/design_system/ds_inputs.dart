import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme/mbe_theme.dart';

/// Sistema de inputs reutilizables para toda la app
/// Uso: DSInput.text(label: 'Nombre', onChanged: (value) {})

class DSInput {
  DSInput._();

  /// TextField estándar
  static Widget text({
    required String label,
    String? hint,
    String? value,
    required Function(String) onChanged,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    bool required = false,
    String? errorText,
    int? maxLength,
    TextEditingController? controller,
  }) {
    return _DSTextField(
      label: label,
      hint: hint,
      value: value,
      onChanged: onChanged,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixTap: onSuffixTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      required: required,
      errorText: errorText,
      maxLength: maxLength,
      controller: controller,
      maxLines: 1,
    );
  }

  /// TextArea multilinea
  static Widget textArea({
    required String label,
    String? hint,
    String? value,
    required Function(String) onChanged,
    int maxLines = 3,
    int? maxLength,
    bool enabled = true,
    bool required = false,
    String? errorText,
    TextEditingController? controller,
  }) {
    return _DSTextField(
      label: label,
      hint: hint,
      value: value,
      onChanged: onChanged,
      enabled: enabled,
      required: required,
      errorText: errorText,
      maxLength: maxLength,
      controller: controller,
      maxLines: maxLines,
    );
  }

  /// TextField para teléfono
  static Widget phone({
    required String label,
    String? value,
    required Function(String) onChanged,
    bool enabled = true,
    bool required = false,
    String? errorText,
    String? hint,
    TextEditingController? controller,
  }) {
    return _DSTextField(
      label: label,
      hint: hint ?? '2222-2222 o 7777-7777',
      value: value,
      onChanged: onChanged,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      enabled: enabled,
      required: required,
      errorText: errorText,
      controller: controller,
      maxLines: 1,
    );
  }

  /// TextField para email
  static Widget email({
    required String label,
    String? value,
    required Function(String) onChanged,
    bool enabled = true,
    bool required = false,
    String? errorText,
    TextEditingController? controller,
  }) {
    return _DSTextField(
      label: label,
      hint: 'tu@email.com',
      value: value,
      onChanged: onChanged,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      required: required,
      errorText: errorText,
      controller: controller,
      maxLines: 1,
    );
  }
}

class _DSTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? value;
  final Function(String) onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool required;
  final String? errorText;
  final int? maxLength;
  final int maxLines;
  final TextEditingController? controller;

  const _DSTextField({
    required this.label,
    this.hint,
    this.value,
    required this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.maxLength,
    this.maxLines = 1,
    this.controller,
  });

  @override
  State<_DSTextField> createState() => _DSTextFieldState();
}

class _DSTextFieldState extends State<_DSTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: MBESpacing.sm),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: hasError
                        ? colorScheme.error
                        : colorScheme.onSurface,
                  ),
                ),
                if (widget.required)
                  Text(
                    ' *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),

        // Input Container - Estilo Grab
        AnimatedContainer(
          duration: MBEDuration.normal,
          curve: MBECurve.standard,
          decoration: BoxDecoration(
            color: widget.enabled
                ? colorScheme.surface
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(MBERadius.large),
            border: Border.all(
              color: hasError
                  ? colorScheme.error
                  : _isFocused
                      ? colorScheme.primary
                      : MBETheme.neutralGray.withValues(alpha: 0.2),
              width: _isFocused ? 2 : 1.5,
            ),
            boxShadow: _isFocused && !hasError
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : MBETheme.shadowSm,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      size: 22,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        widget.suffixIcon,
                        color: colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      onPressed: widget.onSuffixTap,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? MBESpacing.sm : MBESpacing.lg,
                vertical: MBESpacing.lg,
              ),
              counterText: '', // Hide counter
            ),
          ),
        ),

        // Error Text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: MBESpacing.sm, left: MBESpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: colorScheme.error,
                ),
                const SizedBox(width: MBESpacing.xs),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Dropdown personalizado - Estilo Grab
class DSDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DSDropdownItem<T>> items;
  final Function(T?) onChanged;
  final bool required;
  final bool enabled;
  final String? hint;

  const DSDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = false,
    this.enabled = true,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: MBESpacing.sm),
          child: Row(
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall,
              ),
              if (required)
                Text(
                  ' *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
            ],
          ),
        ),

        // Dropdown Container - Estilo Grab
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? colorScheme.surface
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(MBERadius.large),
            border: Border.all(
              color: MBETheme.neutralGray.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: MBETheme.shadowSm,
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item.value,
                      child: Text(
                        item.label,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ))
                .toList(),
            onChanged: enabled ? onChanged : null,
            hint: hint != null
                ? Text(
                    hint!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: MBESpacing.lg,
                vertical: MBESpacing.lg,
              ),
            ),
            dropdownColor: colorScheme.surface,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class DSDropdownItem<T> {
  final T value;
  final String label;

  const DSDropdownItem({
    required this.value,
    required this.label,
  });
}


class DSCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final String label;
  final String? description;

  const DSCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: MBEDuration.normal,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? MBETheme.brandBlack : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? MBETheme.brandBlack : MBETheme.neutralGray,
                width: 2,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: MBESpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}