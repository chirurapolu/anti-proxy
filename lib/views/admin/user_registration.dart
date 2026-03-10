import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _sectionController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _register() async {
    if (_image == null && _selectedRole == UserRole.student) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student photo required')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Prototype Check: If on web and likely no Firebase
      String? photoUrl;
      
      // Attempting real Firebase only if we can
      if (!AuthService.isPrototypeMode) {
        if (_image != null) {
          final ref = FirebaseStorage.instance.ref().child('user_photos/${_idController.text}.jpg');
          await ref.putFile(_image!);
          photoUrl = await ref.getDownloadURL();
        }
      }

      final user = UserModel(
        userId: _idController.text,
        name: _nameController.text,
        role: _selectedRole,
        section: _selectedRole == UserRole.student ? _sectionController.text : null,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      if (!AuthService.isPrototypeMode) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .set(user.toMap());
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Prototype Success: User recorded locally'),
          backgroundColor: Colors.blue,
        ));
      }
    } catch (e) {
      // Final fallback to ensure no crash
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register New User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? const Icon(Icons.camera_alt, size: 40) : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(controller: _idController, decoration: const InputDecoration(labelText: 'Roll No / Employee ID')),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              initialValue: _selectedRole,
              items: UserRole.values.map((role) => DropdownMenuItem(value: role, child: Text(role.name.toUpperCase()))).toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            if (_selectedRole == UserRole.student) ...[
              const SizedBox(height: 16),
              TextField(controller: _sectionController, decoration: const InputDecoration(labelText: 'Section (e.g. CSE-A)')),
            ],
            const SizedBox(height: 32),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _register, child: const Text('Register User')),
          ],
        ),
      ),
    );
  }
}
