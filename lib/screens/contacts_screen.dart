import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/add_contact_modal.dart';

class ContactsScreen extends StatelessWidget {
  final List<Contact> contacts;
  final Function(Contact) onAddContact;
  final Function(Contact) onDeleteContact;
  final Function(Task) onAddTask;

  const ContactsScreen({
    super.key,
    required this.contacts,
    required this.onAddContact,
    required this.onDeleteContact,
    required this.onAddTask,
  });

  void _showAddContactModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddContactModal(onSave: onAddContact),
    );
  }

  Future<void> _deleteContact(BuildContext context, Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Delete Connection?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${contact.name}?',
          style: const TextStyle(color: AppTheme.textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSub),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDeleteContact(contact);
    }
  }

  void _createTaskFromContact(BuildContext context, Contact contact) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contactId: contact.id,
      contactName: contact.name,
      title: contact.taskTitle,
      dueDate: tomorrow,
      frequency: contact.frequency,
      createdAt: now,
    );

    onAddTask(newTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Connections',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddContactModal(context),
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap a card to create a task instantly.',
                style: TextStyle(color: AppTheme.textSub),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: contacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No contacts yet. Tap + to add one.',
                              style: TextStyle(color: AppTheme.textSub),
                            ),
                            const SizedBox(height: 24),
                            _buildAddCard(context),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: contacts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == contacts.length) {
                            return _buildAddCard(context);
                          }
                          return _buildContactCard(context, contacts[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Contact contact) {
    return GestureDetector(
      onTap: () => _createTaskFromContact(context, contact),
      onLongPress: () => _deleteContact(context, contact),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.transparent, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                contact.initial,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              contact.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, size: 12, color: AppTheme.accent),
                const SizedBox(width: 4),
                Text(
                  contact.taskTitle,
                  style: const TextStyle(
                    color: AppTheme.textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddContactModal(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: AppTheme.textSub),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add',
              style: TextStyle(
                color: AppTheme.textSub,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
