// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:contact_book_app/models/contact.dart';
import 'package:contact_book_app/services/contact_manager.dart';
import 'package:contact_book_app/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Ensure this is added to pubspec.yaml

class AddContactScreen extends StatefulWidget {
  final ContactManager manager;
  final VoidCallback onAdd;

  const AddContactScreen({
    super.key,
    required this.manager,
    required this.onAdd,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  String _imagePath = '';
  String _country = '';
  String _category = 'Friends'; // Default category
  double _rating = 3.0; // Default rating

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(
                context,
                await picker.pickImage(source: ImageSource.gallery),
              );
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(
                context,
                await picker.pickImage(source: ImageSource.camera),
              );
            },
            child: const Text('Camera'),
          ),
        ],
      ),
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

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      Contact contact = Contact(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        location: _locationController.text,
        imagePath: _imagePath,
        country: _country,
        category: _category,
        rating: _rating.toInt(),
      );
      if (!widget.manager.addContact(contact)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number already exists!')),
        );
      } else {
        widget.onAdd();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              if (_imagePath.isNotEmpty)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: FileImage(File(_imagePath)),
                ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image (PNG/JPG)'),
              ),
              const SizedBox(height: 10),
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
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Work', 'Family', 'Friends'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 10),
              const Text('Rating:'),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: const Text('Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
