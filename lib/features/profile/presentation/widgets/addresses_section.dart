// lib/features/profile/presentation/widgets/addresses_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';
import 'address_form_modal.dart';

class AddressesSection extends ConsumerStatefulWidget {
  const AddressesSection({Key? key}) : super(key: key);

  @override
  ConsumerState<AddressesSection> createState() => _AddressesSectionState();
}

class _AddressesSectionState extends ConsumerState<AddressesSection> {
  List<AddressModel> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final addresses = await ref
          .read(addressRepositoryProvider)
          .getAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DE NEGOCIO (Sin cambios, solo UI nueva) ---
  void _handleAddNew() {
    showModalBottomSheet(
      // Usamos BottomSheet moderno en vez de Dialog
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressFormModal(onSave: _handleSaveAddress),
    );
  }

  void _handleEdit(AddressModel address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddressFormModal(address: address, onSave: _handleSaveAddress),
    );
  }

  Future<void> _handleSaveAddress(AddressModel address) async {
    try {
      final repo = ref.read(addressRepositoryProvider);
      if (address.id == 0) {
        await repo.createAddress(address);
      } else {
        await repo.updateAddress(address.id.toString(), address);
      }
      await _loadAddresses();

      // Cerrar el modal solo después de guardar exitosamente
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dirección "${address.name}" guardada exitosamente'),
            backgroundColor: MBETheme.brandBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // No cerrar el modal si hay error, solo mostrar mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar dirección: ${e.toString()}'),
            backgroundColor: MBETheme.brandRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(AddressModel address) async {
    // Validaciones rápidas
    if (_addresses.length == 1) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar dirección?"),
        content: Text("Se eliminará '${address.name}' permanentemente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(addressRepositoryProvider)
          .deleteAddress(address.id.toString());
      _loadAddresses();
    }
  }

  Future<void> _handleSetDefault(AddressModel address) async {
    await ref
        .read(addressRepositoryProvider)
        .setDefaultAddress(address.id.toString());
    _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Mis Direcciones',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: MBETheme.brandBlack,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddNew,
        backgroundColor: MBETheme.brandBlack,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text(
          "Nueva Dirección",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? _EmptyState(onAdd: _handleAddNew)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                100,
              ), // Espacio para FAB
              itemCount: _addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return _ModernAddressCard(
                  address: address,
                  onEdit: () => _handleEdit(address),
                  onDelete: () => _handleDelete(address),
                  onSetDefault: () => _handleSetDefault(address),
                );
              },
            ),
    );
  }
}

class _ModernAddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _ModernAddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: address.isDefault
            ? Border.all(
                color: MBETheme.brandBlack,
                width: 2,
              ) // Borde negro si es default
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header de la Tarjeta
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: address.isDefault
                        ? MBETheme.brandBlack
                        : const Color(0xFFF5F5F7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    address.isDefault
                        ? Iconsax.home_25
                        : Iconsax.location, // Icono relleno si es default
                    color: address.isDefault ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MBETheme.brandBlack,
                        ),
                      ),
                      if (address.isDefault)
                        const Text(
                          "Dirección Principal",
                          style: TextStyle(
                            fontSize: 12,
                            color: MBETheme.brandBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Botón de menú (3 puntos) para acciones secundarias
                PopupMenuButton(
                  icon: const Icon(Iconsax.more, color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                    if (value == 'default') onSetDefault();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Iconsax.edit, size: 18),
                          SizedBox(width: 8),
                          Text("Editar"),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Iconsax.tick_circle, size: 18),
                            SizedBox(width: 8),
                            Text("Hacer Principal"),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Iconsax.trash, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Eliminar", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Divider(height: 1),
          ),

          // Contenido de la Dirección
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(Iconsax.map_1, address.address),
                const SizedBox(height: 8),
                _InfoRow(Iconsax.global, address.fullLocation), // Ciudad, Depto
                const SizedBox(height: 8),
                _InfoRow(Iconsax.call, address.phone),
                if (address.references != null &&
                    address.references!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(Iconsax.note_text, address.references!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.map, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text(
            "No tienes direcciones",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Agrega una para tus envíos a domicilio"),
          const SizedBox(height: 24),
          DSButton.primary(
            label: "Agregar Dirección",
            onPressed: onAdd,
            icon: Iconsax.add,
          ),
        ],
      ),
    );
  }
}
