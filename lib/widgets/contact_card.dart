import 'package:flutter/material.dart';
import 'package:contact_book_app/models/contact.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Image at the top as a circle
          CircleAvatar(
            radius: 40, // Larger circle at the top
            backgroundImage: contact.imagePath.isNotEmpty && !kIsWeb
                ? FileImage(File(contact.imagePath))
                : null,
            child: contact.imagePath.isEmpty || kIsWeb
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          ListTile(
            title: Text(contact.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${contact.phone} (${contact.country}) - ${contact.email}'),
                Text('Category: ${contact.category}'),
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < contact.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  )),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(contact.isFavorite ? Icons.favorite : Icons.favorite_border),
                  onPressed: onToggleFavorite,
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Share.share('Contact: ${contact.fullName}, Phone: ${contact.phone}, Email: ${contact.email}');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}