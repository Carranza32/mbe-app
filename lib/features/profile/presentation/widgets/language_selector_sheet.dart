// lib/features/profile/presentation/widgets/language_selector_sheet.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';

/// Bottom sheet para seleccionar el idioma de la app.
class LanguageSelectorSheet extends ConsumerWidget {
  const LanguageSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentCode = currentLocale?.languageCode ?? 'es';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsLanguage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: MBETheme.brandBlack,
              ),
            ),
            const SizedBox(height: 24),
            _LanguageOption(
              code: 'es',
              label: l10n.settingsLanguageSubtitle,
              isSelected: currentCode == 'es',
              onTap: () => _selectLanguage(context, ref, 'es'),
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              code: 'en',
              label: l10n.settingsLanguageSubtitleEn,
              isSelected: currentCode == 'en',
              onTap: () => _selectLanguage(context, ref, 'en'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectLanguage(BuildContext context, WidgetRef ref, String code) async {
    await ref.read(localeProvider.notifier).setLocaleByCode(code);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                Iconsax.global,
                size: 24,
                color: isSelected ? MBETheme.brandRed : MBETheme.neutralGray,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? MBETheme.brandBlack
                        : MBETheme.neutralGray,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Iconsax.tick_circle, size: 24, color: MBETheme.brandRed),
            ],
          ),
        ),
      ),
    );
  }
}
