import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../features/auth/data/repositories/auth_repository.dart';

class ChangePasswordSheet extends ConsumerStatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  ConsumerState<ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<ChangePasswordSheet> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;
  String? _currentPassError;
  String? _newPassError;
  String? _confirmPassError;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _currentPassCtrl.text.isNotEmpty &&
        _newPassCtrl.text.isNotEmpty &&
        _confirmPassCtrl.text.isNotEmpty;
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  Future<void> _handleChange() async {
    // Limpiar errores
    setState(() {
      _currentPassError = null;
      _newPassError = null;
      _confirmPassError = null;
    });

    // Validaciones
    final l10n = AppLocalizations.of(context)!;
    if (_currentPassCtrl.text.isEmpty) {
      setState(() => _currentPassError = l10n.profileCurrentPasswordRequired);
      return;
    }

    if (_newPassCtrl.text.isEmpty) {
      setState(() => _newPassError = l10n.profileNewPasswordRequired);
      return;
    }

    if (!_isPasswordValid(_newPassCtrl.text)) {
      setState(
        () => _newPassError = l10n.profilePasswordRequirements,
      );
      return;
    }

    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      setState(() => _confirmPassError = l10n.passwordsDoNotMatch);
      return;
    }

    if (_currentPassCtrl.text == _newPassCtrl.text) {
      setState(
        () => _newPassError = l10n.profilePasswordDifferent,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.changePassword(
        currentPassword: _currentPassCtrl.text,
        newPassword: _newPassCtrl.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profilePasswordUpdatedSuccess),
            backgroundColor: MBETheme.brandBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        String errorMessage = l10n.profilePasswordChangeError;
        if (e.toString().contains('current_password') ||
            e.toString().contains('actual')) {
          errorMessage = l10n.profileCurrentPasswordIncorrect;
          setState(() => _currentPassError = errorMessage);
        } else {
          errorMessage = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: MBETheme.brandRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: const EdgeInsets.only(top: 12),
      height:
          MediaQuery.of(context).size.height *
          0.75, // Un poco más alto para 3 campos
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.profileSecurity,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MBETheme.brandBlack,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: const Icon(
                      Iconsax.close_circle,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.profileProtectAccount,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Contraseña Actual
                    DSInput.password(
                      label: AppLocalizations.of(context)!.profileCurrentPassword,
                      controller: _currentPassCtrl,
                      required: true,
                      errorText: _currentPassError,
                      onChanged: (String p1) {
                        if (_currentPassError != null) {
                          setState(() => _currentPassError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Nueva Contraseña
                    DSInput.password(
                      label: "Nueva Contraseña",
                      controller: _newPassCtrl,
                      required: true,
                      errorText: _newPassError,
                      onChanged: (String p1) {
                        if (_newPassError != null) {
                          setState(() => _newPassError = null);
                        }
                      },
                    ),
                    if (_newPassCtrl.text.isNotEmpty &&
                        !_isPasswordValid(_newPassCtrl.text))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.info_circle,
                              size: 14,
                              color: MBETheme.neutralGray,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.profilePasswordRequirements,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: MBETheme.neutralGray),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Confirmar Nueva Contraseña
                    DSInput.password(
                      label: AppLocalizations.of(context)!.confirmNewPassword,
                      controller: _confirmPassCtrl,
                      required: true,
                      errorText: _confirmPassError,
                      onChanged: (String p1) {
                        if (_confirmPassError != null) {
                          setState(() => _confirmPassError = null);
                        }
                      },
                    ),
                    if (_confirmPassCtrl.text.isNotEmpty &&
                        _newPassCtrl.text.isNotEmpty &&
                        _confirmPassCtrl.text == _newPassCtrl.text)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.tick_circle,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context)!.passwordsMatch,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: DSButton.primary(
              label: AppLocalizations.of(context)!.profileUpdatePassword,
              isLoading: _isLoading,
              fullWidth: true,
              icon: Iconsax.lock,
              onPressed: (_isLoading || !_isFormValid()) ? null : _handleChange,
            ),
          ),
        ],
      ),
    );
  }
}
