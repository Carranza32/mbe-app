import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../features/auth/data/repositories/auth_repository.dart';
import '../../../../features/auth/providers/auth_provider.dart';

class EditInfoSheet extends ConsumerStatefulWidget {
  final String currentName;
  final String? currentPhone;

  const EditInfoSheet({
    super.key,
    required this.currentName,
    this.currentPhone,
  });

  @override
  ConsumerState<EditInfoSheet> createState() => _EditInfoSheetState();
}

class _EditInfoSheetState extends ConsumerState<EditInfoSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _isLoading = false;
  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _phoneCtrl = TextEditingController(text: widget.currentPhone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _nameCtrl.text.trim().isNotEmpty;
  }

  Future<void> _handleSave() async {
    // Validar
    setState(() {
      _nameError = null;
      _phoneError = null;
    });

    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = 'El nombre es requerido');
      return;
    }

    // Validar teléfono si está lleno
    if (_phoneCtrl.text.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^(\d{4}-\d{4}|\d{8}|\+\d{1,3}\d{4,14})$');
      if (!phoneRegex.hasMatch(_phoneCtrl.text.trim())) {
        setState(() => _phoneError = 'Formato de teléfono inválido');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );

      // Actualizar el estado del usuario
      ref.invalidate(authProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil actualizado exitosamente"),
            backgroundColor: MBETheme.brandBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar perfil: ${e.toString()}"),
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
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                const Text(
                  "Editar Información",
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

          // Formulario
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
                  children: [
                    DSInput.text(
                      label: "Nombre Completo",
                      controller: _nameCtrl,
                      prefixIcon: Iconsax.user,
                      required: true,
                      errorText: _nameError,
                      onChanged: (String p1) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DSInput.phone(
                      label: "Teléfono (Opcional)",
                      controller: _phoneCtrl,
                      hint: '2222-2222 o 7777-7777',
                      errorText: _phoneError,
                      onChanged: (String p1) {
                        if (_phoneError != null) {
                          setState(() => _phoneError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Nota informativa
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.info_circle,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "El correo electrónico no se puede cambiar desde la app.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
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

          // Botón
          Container(
            padding: EdgeInsets.only(
              left: 24,
              top: 16,
              right: 24,
              bottom: 16 + bottomInset,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: DSButton.primary(
              label: "Guardar Cambios",
              isLoading: _isLoading,
              fullWidth: true,
              onPressed: (_isLoading || !_isFormValid()) ? null : _handleSave,
            ),
          ),
        ],
      ),
    );
  }
}
