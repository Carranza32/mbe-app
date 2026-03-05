import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../config/theme/mbe_theme.dart';

enum RecipientType {
  titular,
  encargado,
}

class RecipientData {
  final RecipientType type;
  final String? name;
  final String? email;
  final String? phone;

  RecipientData({
    required this.type,
    this.name,
    this.email,
    this.phone,
  });

  bool get isDifferentReceiver => type == RecipientType.encargado;
}

class RecipientSelector extends StatefulWidget {
  final Function(RecipientType type, String? name) onRecipientChanged;
  final Function(RecipientData data)? onRecipientDataChanged;
  final RecipientType? initialType;
  final String? initialName;

  const RecipientSelector({
    super.key,
    required this.onRecipientChanged,
    this.onRecipientDataChanged,
    this.initialType,
    this.initialName,
  });

  @override
  State<RecipientSelector> createState() => RecipientSelectorState();
}

class RecipientSelectorState extends State<RecipientSelector> {
  RecipientType? _selectedType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? RecipientType.titular;
    _nameController.text = widget.initialName ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notifyChange();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onRecipientChanged(
      _selectedType!,
      _nameController.text.isEmpty ? null : _nameController.text,
    );
    widget.onRecipientDataChanged?.call(recipientData);
  }

  RecipientData get recipientData => RecipientData(
    type: _selectedType ?? RecipientType.titular,
    name: _nameController.text.isEmpty ? null : _nameController.text,
    email: _emailController.text.isEmpty ? null : _emailController.text,
    phone: _phoneController.text.isEmpty ? null : _phoneController.text,
  );

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
        _buildOption(
          type: RecipientType.titular,
          title: 'Titular',
          subtitle: 'El cliente titular recoge el paquete',
          icon: Iconsax.user_tick,
        ),
        const SizedBox(height: 8),
        // Opción Encargado
        _buildOption(
          type: RecipientType.encargado,
          title: 'Encargado',
          subtitle: 'Otra persona recoge el paquete',
          icon: Iconsax.people,
        ),
        // Campos adicionales si es encargado
        if (_selectedType == RecipientType.encargado) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MBETheme.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos del encargado',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: MBETheme.brandBlack,
                  ),
                ),
                const SizedBox(height: 12),
                // Nombre (requerido)
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo *',
                    hintText: 'Nombre de quien recoge',
                    prefixIcon: const Icon(Iconsax.user, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (_) => _notifyChange(),
                ),
                const SizedBox(height: 12),
                // Email (opcional)
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email (opcional)',
                    hintText: 'correo@ejemplo.com',
                    prefixIcon: const Icon(Iconsax.sms, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (_) => _notifyChange(),
                ),
                const SizedBox(height: 12),
                // Teléfono (opcional)
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    hintText: '7890-1234',
                    prefixIcon: const Icon(Iconsax.call, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (_) => _notifyChange(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOption({
    required RecipientType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          if (type == RecipientType.titular) {
            _nameController.clear();
            _emailController.clear();
            _phoneController.clear();
          }
        });
        _notifyChange();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? MBETheme.brandBlack.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MBETheme.brandBlack : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? MBETheme.brandBlack 
                    : MBETheme.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : MBETheme.neutralGray,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: MBETheme.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: MBETheme.neutralGray,
                    ),
                  ),
                ],
              ),
            ),
            Radio<RecipientType>(
              value: type,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                  if (value == RecipientType.titular) {
                    _nameController.clear();
                    _emailController.clear();
                    _phoneController.clear();
                  }
                });
                _notifyChange();
              },
              activeColor: MBETheme.brandBlack,
            ),
          ],
        ),
      ),
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
