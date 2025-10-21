import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  final bool isEmail; // New flag for email validation

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = false,
    this.onChanged,
    this.isEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label is required';
        }
        if (isEmail && value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) {
            return 'Enter a valid email address';
          }
        }
        return null;
      },
    );
  }
}