import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../config/theme/mbe_theme.dart';

enum RecipientType {
  titular,
  encargado,
}

class RecipientSelector extends StatefulWidget {
  final Function(RecipientType type, String? name) onRecipientChanged;
  final RecipientType? initialType;
  final String? initialName;

  const RecipientSelector({
    super.key,
    required this.onRecipientChanged,
    this.initialType,
    this.initialName,
  });

  @override
  State<RecipientSelector> createState() => _RecipientSelectorState();
}

class _RecipientSelectorState extends State<RecipientSelector> {
  RecipientType? _selectedType;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? RecipientType.titular;
    _nameController.text = widget.initialName ?? '';
    // Diferir la llamada al callback hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onRecipientChanged(
          _selectedType!,
          _nameController.text.isEmpty ? null : _nameController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quién recibe *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        // Opción Titular
        RadioListTile<RecipientType>(
          value: RecipientType.titular,
          groupValue: _selectedType,
          onChanged: (value) {
            setState(() {
              _selectedType = value;
              _nameController.clear();
            });
            widget.onRecipientChanged(value!, null);
          },
          title: const Text('Titular'),
          subtitle: const Text('El cliente titular recoge el paquete'),
          contentPadding: EdgeInsets.zero,
          activeColor: MBETheme.brandBlack,
        ),
        // Opción Encargado
        RadioListTile<RecipientType>(
          value: RecipientType.encargado,
          groupValue: _selectedType,
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
            widget.onRecipientChanged(value!, _nameController.text.isEmpty ? null : _nameController.text);
          },
          title: const Text('Encargado'),
          subtitle: const Text('Otra persona recoge el paquete'),
          contentPadding: EdgeInsets.zero,
          activeColor: MBETheme.brandBlack,
        ),
        // Campo de nombre si es encargado
        if (_selectedType == RecipientType.encargado) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre del encargado *',
              hintText: 'Ingresa el nombre completo',
              prefixIcon: const Icon(Iconsax.user),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              widget.onRecipientChanged(_selectedType!, value.isEmpty ? null : value);
            },
          ),
        ],
      ],
    );
  }

  String? get recipientName {
    if (_selectedType == RecipientType.titular) {
      return 'titular';
    }
    return _nameController.text.isEmpty ? null : _nameController.text;
  }

  RecipientType? get recipientType => _selectedType;
}

