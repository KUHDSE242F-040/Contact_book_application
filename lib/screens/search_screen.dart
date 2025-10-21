import 'package:flutter/material.dart';
import 'package:contact_book_app/models/contact.dart';
import 'package:contact_book_app/services/contact_manager.dart';
import 'package:contact_book_app/widgets/contact_card.dart';

class SearchScreen extends StatefulWidget {
  final ContactManager manager;

  const SearchScreen({super.key, required this.manager});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _results = [];

  void _search() {
    setState(() {
      _results = widget.manager.searchContacts(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Contacts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name or phone',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _search(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  return ContactCard(
                    contact: _results[index],
                    onEdit: () {}, // Implement if needed
                    onDelete: () {},
                    onToggleFavorite: () {}, // Implement if needed
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
