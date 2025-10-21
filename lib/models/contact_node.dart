import 'contact.dart';

class ContactNode {
  Contact contact;
  ContactNode? next;

  ContactNode({required this.contact, this.next});
}