import 'package:flutter/material.dart';
import 'package:contact_book_app/models/contact.dart';
import 'package:contact_book_app/services/contact_manager.dart';
import 'package:contact_book_app/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class EditContactScreen extends StatefulWidget {
  final ContactManager manager;
  final Contact contact;
  final VoidCallback onUpdate;

  const EditContactScreen({
    super.key,
    required this.manager,
    required this.contact,
    required this.onUpdate,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _locationController;
  String _imagePath = '';
  String _country = '';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.contact.firstName,
    );
    _lastNameController = TextEditingController(text: widget.contact.lastName);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _emailController = TextEditingController(text: widget.contact.email);
    _addressController = TextEditingController(text: widget.contact.address);
    _locationController = TextEditingController(text: widget.contact.location);
    _imagePath = widget.contact.imagePath;
    _country = widget.contact.country;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      final extension = path.extension(pickedFile.path).toLowerCase();
      if (extension == '.png' || extension == '.jpg' || extension == '.jpeg') {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
        final savedImage = await File(
          pickedFile.path,
        ).copy('${directory.path}/$fileName');
        setState(() {
          _imagePath = savedImage.path;
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a PNG or JPG image')),
        );
      }
    }
  }

  void _onPhoneChanged(String phone) {
    setState(() {
      _country = ContactManager.detectCountry(phone);
    });
  }

  void _updateContact() {
    if (_formKey.currentState!.validate()) {
      Contact updatedContact = Contact(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        location: _locationController.text,
        imagePath: _imagePath,
        country: _country,
        isFavorite: widget.contact.isFavorite,
        timestamp: widget.contact.timestamp,
      );
      if (widget.manager.updateContact(widget.contact.phone, updatedContact)) {
        widget.onUpdate();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Update failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _firstNameController,
                label: 'First Name',
                isRequired: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _lastNameController,
                label: 'Last Name',
                isRequired: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone',
                isRequired: true,
                onChanged: _onPhoneChanged,
              ),
              Text('Country: $_country'),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                isRequired: true,
                isEmail: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(controller: _addressController, label: 'Address'),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _locationController,
                label: 'Location',
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image (PNG/JPG)'),
              ),
              if (_imagePath.isNotEmpty)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(File(_imagePath)),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateContact,
                child: const Text('Update Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
