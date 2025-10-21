import 'package:contact_book_app/models/contact.dart';
import 'package:contact_book_app/models/contact_node.dart';
import 'file_service.dart';

class ContactManager {
  ContactNode? _head;
  final FileService _fileService = FileService();

  Future<void> loadContacts() async {
    List<Contact> contacts = await _fileService.loadContacts();
    for (var contact in contacts) {
      _addToEnd(contact);
    }
  }

  Future<void> saveContacts() async {
    List<Contact> contacts = getAllContacts();
    await _fileService.saveContacts(contacts);
  }

  bool addContact(Contact contact) {
    if (_isPhoneDuplicate(contact.phone)) {
      return false;
    }
    _addToEnd(contact);
    saveContacts(); 
    return true;
  }

  void _addToEnd(Contact contact) {
    ContactNode newNode = ContactNode(contact: contact);
    if (_head == null) {
      _head = newNode;
    } else {
      ContactNode? current = _head;
      while (current!.next != null) {
        current = current.next;
      }
      current.next = newNode;
    }
  }

  List<Contact> searchContacts(String query) {
    List<Contact> results = [];
    ContactNode? current = _head;
    while (current != null) {
      if (current.contact.fullName.toLowerCase().contains(query.toLowerCase()) ||
          current.contact.phone.contains(query)) {
        results.add(current.contact);
      }
      current = current.next;
    }
    return results;
  }

  bool updateContact(String phone, Contact updatedContact) {
    ContactNode? current = _head;
    while (current != null) {
      if (current.contact.phone == phone) {
        current.contact = updatedContact;
        saveContacts();
        return true;
      }
      current = current.next;
    }
    return false;
  }

  bool deleteContact(String phone) {
    if (_head == null) return false;
    if (_head!.contact.phone == phone) {
      _head = _head!.next;
      saveContacts();
      return true;
    }
    ContactNode? current = _head;
    while (current!.next != null) {
      if (current.next!.contact.phone == phone) {
        current.next = current.next!.next;
        saveContacts();
        return true;
      }
      current = current.next;
    }
    return false;
  }

  List<Contact> getAllContacts() {
    List<Contact> contacts = [];
    ContactNode? current = _head;
    while (current != null) {
      contacts.add(current.contact);
      current = current.next;
    }
    return contacts;
  }

  // Sort by name (bubble sort)
  void sortByName() {
    _sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  // Sort by phone
  void sortByPhone() {
    _sort((a, b) => a.phone.compareTo(b.phone));
  }
// Sort by favorites (favorites first, then non-favorites, with alphabetical order within groups)
void sortByFavorites() {
  _sort((a, b) {
    // Favorites come first
    int favCompare = (a.isFavorite ? 0 : 1).compareTo(b.isFavorite ? 0 : 1);
    if (favCompare != 0) return favCompare;
    // Within favorites/non-favorites, sort by name
    return a.fullName.compareTo(b.fullName);
  });
}

  // Sort by recently added (newest first)
  void sortByRecentlyAdded() {
    _sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _sort(int Function(Contact, Contact) compare) {
    if (_head == null || _head!.next == null) return;
    bool swapped;
    do {
      swapped = false;
      ContactNode? current = _head;
      while (current!.next != null) {
        if (compare(current.contact, current.next!.contact) > 0) {
          Contact temp = current.contact;
          current.contact = current.next!.contact;
          current.next!.contact = temp;
          swapped = true;
        }
        current = current.next;
      }
    } while (swapped);
    saveContacts();
  }

  // Toggle favorite
  void toggleFavorite(String phone) {
    ContactNode? current = _head;
    while (current != null) {
      if (current.contact.phone == phone) {
        current.contact.isFavorite = !current.contact.isFavorite;
        saveContacts();
        return;
      }
      current = current.next;
    }
  }

  // Get favorites
  List<Contact> getFavorites() {
    List<Contact> favorites = [];
    ContactNode? current = _head;
    while (current != null) {
      if (current.contact.isFavorite) {
        favorites.add(current.contact);
      }
      current = current.next;
    }
    return favorites;
  }

  bool _isPhoneDuplicate(String phone) {
    ContactNode? current = _head;
    while (current != null) {
      if (current.contact.phone == phone) {
        return true;
      }
      current = current.next;
    }
    return false;
  }

  static String detectCountry(String phone) {
    Map<String, String> prefixes = {
      '+1': 'USA',
      '+94': 'Sri Lanka',
      '+44': 'UK',
      '+91': 'India',
    };
    for (var prefix in prefixes.keys) {
      if (phone.startsWith(prefix)) {
        return prefixes[prefix]!;
      }
    }
    return 'Unknown';
  }
}