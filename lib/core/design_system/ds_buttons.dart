import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme/mbe_theme.dart';

/// Sistema de botones reutilizables para toda la app
/// Uso: DSButton.primary(label: 'Continuar', onPressed: () {})

class DSButton {
  DSButton._();

  /// Botón primario (negro)
  static Widget primary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    EdgeInsets? padding,
  }) {
    return _BaseButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      padding: padding,
      type: _ButtonType.primary,
    );
  }

  /// Botón secundario (outlined)
  static Widget secondary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    EdgeInsets? padding,
  }) {
    return _BaseButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      padding: padding,
      type: _ButtonType.secondary,
    );
  }

  /// Botón de texto simple
  static Widget text({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    EdgeInsets? padding,
  }) {
    return _BaseButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      padding: padding,
      type: _ButtonType.text,
    );
  }

  /// Botón solo con ícono
  static Widget icon({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? iconColor,
    double size = 48,
    bool withShadow = true,
  }) {
    return _IconButton(
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: size,
      withShadow: withShadow,
    );
  }

  /// Botón flotante (FAB)
  static Widget fab({
    required IconData icon,
    required VoidCallback onPressed,
    String? label,
    bool mini = false,
  }) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: label != null ? Text(label) : const SizedBox.shrink(),
      elevation: 6,
    );
  }
}

enum _ButtonType { primary, secondary, text }

class _BaseButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final EdgeInsets? padding;
  final _ButtonType type;

  const _BaseButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = onPressed != null && !isLoading;

    // Determinar el color del texto e icono según el tipo de botón
    final textColor = type == _ButtonType.primary
        ? (isEnabled ? Colors.white : MBETheme.neutralGray)
        : (isEnabled ? colorScheme.onSurface : MBETheme.neutralGray);
    
    final iconColor = type == _ButtonType.primary
        ? (isEnabled ? Colors.white : MBETheme.neutralGray)
        : (isEnabled ? colorScheme.onSurface : MBETheme.neutralGray);

    Widget child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == _ButtonType.primary
                    ? Colors.white
                    : colorScheme.primary,
              ),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: iconColor),
        if ((icon != null || isLoading) && label.isNotEmpty)
          const SizedBox(width: MBESpacing.sm),
        if (label.isNotEmpty)
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );

    final effectivePadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: MBESpacing.xl,
          vertical: MBESpacing.lg,
        );

    switch (type) {
      case _ButtonType.primary:
        return AnimatedContainer(
          duration: MBEDuration.normal,
          curve: MBECurve.standard,
          width: fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: isEnabled ? MBETheme.brandBlack : MBETheme.neutralGray.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(MBERadius.large),
            boxShadow: isEnabled ? MBETheme.shadowMd : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onPressed : null,
              borderRadius: BorderRadius.circular(MBERadius.large),
              child: Padding(
                padding: effectivePadding,
                child: child,
              ),
            ),
          ),
        );

      case _ButtonType.secondary:
        return AnimatedContainer(
          duration: MBEDuration.normal,
          curve: MBECurve.standard,
          width: fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: isEnabled
                  ? MBETheme.neutralGray.withValues(alpha: 0.3)
                  : MBETheme.neutralGray.withValues(alpha: 0.15),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(MBERadius.large),
            boxShadow: isEnabled ? MBETheme.shadowSm : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onPressed : null,
              borderRadius: BorderRadius.circular(MBERadius.large),
              child: Padding(
                padding: effectivePadding,
                child: DefaultTextStyle(
                  style: theme.textTheme.labelLarge!.copyWith(
                    color: isEnabled ? colorScheme.onSurface : MBETheme.neutralGray,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );

      case _ButtonType.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            padding: effectivePadding,
            foregroundColor: colorScheme.primary,
          ),
          child: child,
        );
    }
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool withShadow;

  const _IconButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return AnimatedContainer(
      duration: MBEDuration.normal,
      curve: MBECurve.standard,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isEnabled ? MBETheme.brandBlack : MBETheme.neutralGray.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(MBERadius.medium),
        boxShadow: isEnabled && withShadow ? MBETheme.shadowMd : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(MBERadius.medium),
          child: Icon(
            icon,
            size: size * 0.5,
            color: iconColor ??
                (isEnabled ? Colors.white : MBETheme.neutralGray),
          ),
        ),
      ),
    );
  }
}

/// Botones de navegación (Atrás/Continuar)
class DSNavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String? continueLabel;
  final bool canContinue;
  final bool isLoading;

  const DSNavigationButtons({
    Key? key,
    this.onBack,
    this.onContinue,
    this.continueLabel,
    this.canContinue = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MBESpacing.lg),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (onBack != null) ...[
              Expanded(
                child: DSButton.secondary(
                  label: 'Atrás',
                  icon: Iconsax.arrow_left_2,
                  onPressed: onBack,
                ),
              ),
              const SizedBox(width: MBESpacing.lg),
            ],
            Expanded(
              flex: onBack != null ? 1 : 2,
              child: DSButton.primary(
                label: continueLabel ?? 'Continuar',
                icon: Iconsax.arrow_right_3,
                onPressed: canContinue && !isLoading ? onContinue : null,
                isLoading: isLoading,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}