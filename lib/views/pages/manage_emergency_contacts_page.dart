// lib/views/pages/manage_emergency_contacts_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/models/user_model.dart';
import 'package:safewalk/data/services/firestore_service.dart';

class ManageEmergencyContactsPage extends StatefulWidget {
  const ManageEmergencyContactsPage({super.key});

  @override
  State<ManageEmergencyContactsPage> createState() =>
      _ManageEmergencyContactsPageState();
}

class _ManageEmergencyContactsPageState
    extends State<ManageEmergencyContactsPage> {
  final _searchController = TextEditingController();
  List<UserModel> _contacts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final contacts = await firestoreService.getEmergencyContacts(
        currentUserId,
      );
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar contactos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addContact(String searchValue) async {
    setState(() => _errorMessage = null);

    if (searchValue.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa un email o teléfono');
      return;
    }

    try {
      // Buscar por email o teléfono
      UserModel? contact;
      if (searchValue.contains('@')) {
        contact = await firestoreService.findUserByEmail(searchValue.trim());
      } else {
        contact = await firestoreService.findUserByPhone(searchValue.trim());
      }

      if (contact == null) {
        setState(() => _errorMessage = 'Usuario no encontrado');
        return;
      }

      // Verificar que sea contacto de emergencia
      if (contact.userType != UserType.emergencyContact) {
        setState(
          () => _errorMessage = 'Este usuario no es un contacto de emergencia',
        );
        return;
      }

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Verificar que no se esté agregando a sí mismo
      if (contact.uid == currentUserId) {
        setState(() => _errorMessage = 'No puedes agregarte a ti mismo');
        return;
      }

      // Verificar si ya está agregado
      if (_contacts.any((c) => c.uid == contact!.uid)) {
        setState(() => _errorMessage = 'Este contacto ya está agregado');
        return;
      }

      // Agregar contacto
      final success = await firestoreService.addEmergencyContact(
        visuallyImpairedUid: currentUserId,
        emergencyContactUid: contact.uid,
      );

      if (success) {
        _searchController.clear();
        _loadContacts();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacto agregado exitosamente')),
        );
      } else {
        setState(() => _errorMessage = 'Error al agregar contacto');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    }
  }

  Future<void> _removeContact(UserModel contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: Text(
          '¿Eliminar a ${contact.name} de tus contactos de emergencia?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final success = await firestoreService.removeEmergencyContact(
      visuallyImpairedUid: currentUserId,
      emergencyContactUid: contact.uid,
    );

    if (success) {
      _loadContacts();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contacto eliminado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FC),
        elevation: 0,
        title: const Text(
          'Contactos de Emergencia',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agregar nuevo contacto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Email o teléfono',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _addContact(_searchController.text),
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: KColors.tealChillon,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Lista de contactos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contacts_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes contactos de emergencia',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega uno para recibir ayuda en caso de emergencia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: KColors.tealChillon,
                            child: Text(
                              contact.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(contact.email),
                              if (contact.phone != null)
                                Text('Tel: ${contact.phone}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () => _removeContact(contact),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
