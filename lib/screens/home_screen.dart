// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:contact_book_app/constants/colors.dart';
import 'package:contact_book_app/models/contact.dart';
import 'package:contact_book_app/services/contact_manager.dart';
import 'package:contact_book_app/services/file_service.dart';
import 'package:contact_book_app/widgets/contact_card.dart';
import 'add_contact_screen.dart';
import 'edit_contact_screen.dart';
import 'search_screen.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ContactManager _manager = ContactManager();
  List<Contact> _contacts = [];
  bool _showFavorites = false;
  String _sortType = 'Name'; // Options: Name, Phone, Recently Added, Favorites

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    await _manager.loadContacts();
    _refreshContacts();
  }

  void _refreshContacts() {
    setState(() {
      _contacts = _showFavorites ? _manager.getFavorites() : _manager.getAllContacts();
      _applySort();
    });
  }

  void _applySort() {
    if (_sortType == 'Name') {
      _manager.sortByName();
    } else if (_sortType == 'Phone') {
      _manager.sortByPhone();
    } else if (_sortType == 'Recently Added') {
      _manager.sortByRecentlyAdded();
    } else if (_sortType == 'Favorites') {
      _manager.sortByFavorites();
    }
    _contacts = _showFavorites ? _manager.getFavorites() : _manager.getAllContacts();
  }

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null) {
      String? path = result.files.single.path;
      if (path != null) {
        try {
          List<Contact> imported = await FileService().importFromCSV(path);
          int addedCount = 0;
          for (var contact in imported) {
            if (_manager.addContact(contact)) {
              addedCount++;
            }
          }
          _refreshContacts();
         
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$addedCount contacts imported successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Book'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchScreen(manager: _manager)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await FileService().exportToCSV(_contacts);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contacts exported to CSV')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importCSV,
          ),
          DropdownButton<String>(
            value: _sortType,
            items: ['Name', 'Phone', 'Recently Added', 'Favorites'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Sort by $value'),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _sortType = newValue!;
                _applySort();
              });
            },
          ),
          IconButton(
            icon: Icon(_showFavorites ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
                _refreshContacts();
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          return ContactCard(
            contact: _contacts[index],
            onEdit: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditContactScreen(
                  manager: _manager,
                  contact: _contacts[index],
                  onUpdate: _refreshContacts,
                ),
              ),
            ),
            onDelete: () {
              _manager.deleteContact(_contacts[index].phone);
              _refreshContacts();
            },
            onToggleFavorite: () {
              _manager.toggleFavorite(_contacts[index].phone);
              _refreshContacts();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddContactScreen(
              manager: _manager,
              onAdd: _refreshContacts,
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}