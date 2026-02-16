import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../l10n/app_localizations.dart';
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

  void _handleAddNew() {
    showModalBottomSheet(
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileErrorSavingAddress(e.toString())),
            backgroundColor: MBETheme.brandRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(AddressModel address) async {
    if (_addresses.length == 1) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.profileDeleteAddressTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(AppLocalizations.of(context)!.profileDeleteAddressConfirm(address.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.authCancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.profileDelete,
              style: TextStyle(color: Color(0xFFED1C24)),
            ),
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis Direcciones',
          style: TextStyle(
            color: Color(0xFF1A1C24),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? _EmptyState(onAdd: _handleAddNew)
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ModernAddressCard(
                    address: address,
                    onEdit: () => _handleEdit(address),
                    onDelete: () => _handleDelete(address),
                    onSetDefault: () => _handleSetDefault(address),
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFFED1C24), Color(0xFFB91419)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFED1C24).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _handleAddNew,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Iconsax.add, color: Colors.white),
          label: Text(
            AppLocalizations.of(context)!.profileNewAddress,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
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
        borderRadius: BorderRadius.circular(24),
        border: address.isDefault
            ? Border.all(color: const Color(0xFFED1C24), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: address.isDefault
                            ? const LinearGradient(
                                colors: [Color(0xFFED1C24), Color(0xFFB91419)],
                              )
                            : null,
                        color: address.isDefault
                            ? null
                            : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        address.isDefault ? Iconsax.home_15 : Iconsax.location,
                        color: address.isDefault
                            ? Colors.white
                            : const Color(0xFF6B7280),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1C24),
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFED1C24).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.profilePrimary,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFED1C24),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton(
                        icon: const Icon(
                          Iconsax.more,
                          color: Color(0xFF6B7280),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                          if (value == 'default') onSetDefault();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Iconsax.edit, size: 18),
                                const SizedBox(width: 12),
                                Text(AppLocalizations.of(context)!.profileEdit),
                              ],
                            ),
                          ),
                          if (!address.isDefault)
                            PopupMenuItem(
                              value: 'default',
                              child: Row(
                                children: [
                                  const Icon(Iconsax.tick_circle, size: 18),
                                  const SizedBox(width: 12),
                                  Text(AppLocalizations.of(context)!.profileMakeDefault),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.trash,
                                  size: 18,
                                  color: Color(0xFFED1C24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.profileDelete,
                                  style: const TextStyle(color: Color(0xFFED1C24)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(Iconsax.map_1, address.address),
                      const SizedBox(height: 12),
                      _InfoRow(Iconsax.global, address.fullLocation),
                      const SizedBox(height: 12),
                      _InfoRow(Iconsax.call, address.phone),
                      if (address.references != null &&
                          address.references!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _InfoRow(Iconsax.note_text, address.references!),
                      ],
                    ],
                  ),
                ),
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
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1C24),
              height: 1.4,
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFED1C24).withOpacity(0.1),
                    const Color(0xFFED1C24).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.location,
                size: 64,
                color: Color(0xFFED1C24),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.profileNoAddressesRegistered,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1C24),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.profileAddAddressHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFED1C24), Color(0xFFB91419)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFED1C24).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Iconsax.add, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context)!.profileAddFirstAddress,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
