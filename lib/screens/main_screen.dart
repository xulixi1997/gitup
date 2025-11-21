import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/toast_overlay.dart';
import 'home_screen.dart';
import 'contacts_screen.dart';
import 'tasks_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Contact> _contacts = [];
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _contacts = StorageService().getContacts();
      _tasks = StorageService().getTasks();
    });
  }

  Future<void> _addContact(Contact contact) async {
    final contacts = StorageService().getContacts();
    contacts.add(contact);
    await StorageService().saveContacts(contacts);
    _loadData();
  }

  Future<void> _deleteContact(Contact contact) async {
    final contacts = StorageService().getContacts();
    contacts.removeWhere((c) => c.id == contact.id);
    await StorageService().saveContacts(contacts);
    _loadData();
  }

  Future<void> _addTask(Task task) async {
    final tasks = StorageService().getTasks();
    tasks.add(task);
    await StorageService().saveTasks(tasks);
    _loadData();

    if (mounted) {
      showToast(context, 'Task Created', 'Added ${task.title}');
    }
  }

  Future<void> _updateTask(Task task) async {
    final allTasks = StorageService().getTasks();
    final index = allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final isCompleting = !task.isCompleted;
      final updatedTask = task.copyWith(
        isCompleted: isCompleting,
        completedAt: isCompleting ? DateTime.now() : null,
      );
      allTasks[index] = updatedTask;

      // If completing a recurring task, create next instance
      if (!task.isCompleted &&
          updatedTask.isCompleted &&
          task.frequency != 'None') {
        DateTime nextDate = task.dueDate;
        switch (task.frequency) {
          case 'Daily':
            nextDate = nextDate.add(const Duration(days: 1));
            break;
          case 'Weekly':
            nextDate = nextDate.add(const Duration(days: 7));
            break;
          case 'Monthly':
            nextDate = DateTime(
              nextDate.year,
              nextDate.month + 1,
              nextDate.day,
            );
            break;
          case 'Yearly':
            nextDate = DateTime(
              nextDate.year + 1,
              nextDate.month,
              nextDate.day,
            );
            break;
        }

        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          contactId: task.contactId,
          contactName: task.contactName,
          title: task.title,
          dueDate: nextDate,
          frequency: task.frequency,
          createdAt: DateTime.now(),
        );
        allTasks.add(newTask);
      }

      await StorageService().saveTasks(allTasks);
      _loadData();

      if (mounted && isCompleting) {
        showToast(context, 'Great Job!', 'Completed ${task.title}!');
      }
    }
  }

  Future<void> _deleteTask(String id) async {
    final allTasks = StorageService().getTasks();
    allTasks.removeWhere((t) => t.id == id);
    await StorageService().saveTasks(allTasks);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        tasks: _tasks,
        contacts: _contacts,
        onTaskUpdate: _updateTask,
        onAddTask: _addTask,
      ),
      ContactsScreen(
        contacts: _contacts,
        onAddContact: _addContact,
        onDeleteContact: _deleteContact,
        onAddTask: _addTask,
      ),
      TasksScreen(
        tasks: _tasks,
        contacts: _contacts,
        onAddTask: _addTask,
        onUpdateTask: _updateTask,
        onDeleteTask: _deleteTask,
      ),
      StatsScreen(tasks: _tasks),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Contacts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_outlined),
              activeIcon: Icon(Icons.checklist),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
