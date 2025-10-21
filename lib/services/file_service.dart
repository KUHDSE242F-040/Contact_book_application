import 'dart:convert';
import 'dart:io';
import 'package:contact_book_app/services/contact_manager.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:contact_book_app/models/contact.dart';

class FileService {
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/contacts.json';
  }

  Future<void> saveContacts(List<Contact> contacts) async {
    final file = File(await _getFilePath());
    List<Map<String, dynamic>> jsonList = contacts
        .map((c) => c.toJson())
        .toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<Contact>> loadContacts() async {
    try {
      final file = File(await _getFilePath());
      if (!await file.exists()) return [];
      String contents = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => Contact.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // ... (existing code)

  // Update exportToCSV to include category and rating
  Future<void> exportToCSV(List<Contact> contacts) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/contacts.csv');
    List<List<String>> rows = [
      [
        'First Name',
        'Last Name',
        'Phone',
        'Email',
        'Address',
        'Location',
        'Country',
        'Category',
        'Rating',
      ],
    ];
    for (var contact in contacts) {
      rows.add([
        contact.firstName,
        contact.lastName,
        contact.phone,
        contact.email,
        contact.address,
        contact.location,
        contact.country,
        contact.category,
        contact.rating.toString(),
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
  }

  // Update importFromCSV to handle category and rating
  Future<List<Contact>> importFromCSV(String csvPath) async {
    try {
      final file = File(csvPath);
      String contents = await file.readAsString();
      List<List<dynamic>> rows = const CsvToListConverter().convert(contents);
      if (rows.isEmpty || rows[0][0] != 'First Name') {
        throw Exception(
          'Invalid CSV format. Expected headers: First Name, Last Name, Phone, Email, Address, Location, Country, Category, Rating',
        );
      }
      List<Contact> contacts = [];
      for (int i = 1; i < rows.length; i++) {
        try {
          if (rows[i].length < 4 ||
              rows[i][0].isEmpty ||
              rows[i][1].isEmpty ||
              rows[i][2].isEmpty ||
              rows[i][3].isEmpty) {
            continue;
          }
          Contact contact = Contact(
            firstName: rows[i][0],
            lastName: rows[i][1],
            phone: rows[i][2],
            email: rows[i][3],
            address: rows[i].length > 4 ? rows[i][4] : '',
            location: rows[i].length > 5 ? rows[i][5] : '',
            country: rows[i].length > 6
                ? rows[i][6]
                : ContactManager.detectCountry(rows[i][2]),
            category: rows[i].length > 7 ? rows[i][7] : 'Friends',
            rating: rows[i].length > 8 ? int.tryParse(rows[i][8]) ?? 3 : 3,
          );
          contacts.add(contact);
        } catch (e) {
          continue;
        }
      }
      return contacts;
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }
}
