import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';
import '../models/task.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    if (_prefs?.getString('contacts') == null) {
      final defaultContacts = [
        Contact(
          id: '1',
          name: 'Alice Smith',
          taskTitle: 'Weekly Report',
          frequency: 'Weekly',
          colorIndex: 0,
        ),
        Contact(
          id: '2',
          name: 'Bob Johnson',
          taskTitle: 'Daily Standup',
          frequency: 'Daily',
          colorIndex: 1,
        ),
        Contact(
          id: '3',
          name: 'Charlie Brown',
          taskTitle: 'Monthly Review',
          frequency: 'Monthly',
          colorIndex: 2,
        ),
      ];
      await saveContacts(defaultContacts);
    }
  }

  // Contacts
  List<Contact> getContacts() {
    final String? contactsJson = _prefs?.getString('contacts');
    if (contactsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(contactsJson);
    return decoded.map((e) => Contact.fromJson(e)).toList();
  }

  Future<void> saveContacts(List<Contact> contacts) async {
    final String encoded = jsonEncode(contacts.map((e) => e.toJson()).toList());
    await _prefs?.setString('contacts', encoded);
  }

  // Tasks
  List<Task> getTasks() {
    final String? tasksJson = _prefs?.getString('tasks');
    if (tasksJson == null) return [];
    final List<dynamic> decoded = jsonDecode(tasksJson);
    return decoded.map((e) => Task.fromJson(e)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final String encoded = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await _prefs?.setString('tasks', encoded);
  }

  // Clear all (for debugging or reset)
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
