import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

import '../widgets/add_task_modal.dart';

class HomeScreen extends StatelessWidget {
  final List<Task> tasks;
  final List<Contact> contacts;
  final Function(Task) onTaskUpdate;
  final Function(Task) onAddTask;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.contacts,
    required this.onTaskUpdate,
    required this.onAddTask,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == tomorrow) return 'Tomorrow';
    return DateFormat('MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    // Sort by due date
    pendingTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final upNextTask = pendingTasks.isNotEmpty ? pendingTasks.first : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Overview',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textSub,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Quick Access (Contacts)
              if (contacts.isNotEmpty) ...[
                Text(
                  'QUICK ACCESS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSub,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: contacts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AddTaskModal(
                              onSave: onAddTask,
                              initialContactName: contact.name,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                contact.initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contact.name,
                              style: const TextStyle(
                                color: AppTheme.textSub,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Up Next
              if (upNextTask != null) ...[
                Text(
                  'UP NEXT',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSub,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildUpNextCard(context, upNextTask),
                const SizedBox(height: 32),
              ],

              // This Week / Upcoming
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'UPCOMING',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSub,
                      letterSpacing: 1.2,
                    ),
                  ),
                  // View All button could go here
                ],
              ),
              const SizedBox(height: 16),
              if (pendingTasks.isEmpty && upNextTask == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No upcoming tasks. Relax!',
                      style: TextStyle(color: AppTheme.textSub),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingTasks.length > 5
                      ? 5
                      : pendingTasks.length, // Show top 5
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = pendingTasks[index];
                    if (task == upNextTask) {
                      return const SizedBox.shrink();
                    }
                    return _buildTaskItem(task);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpNextCard(BuildContext context, Task task) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.surface, Color(0xFF4E342E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      task.contactName.isNotEmpty
                          ? task.contactName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.contactName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            task.title,
                            style: const TextStyle(color: AppTheme.textSub),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDate(task.dueDate),
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repeat: ${task.frequency}',
                style: const TextStyle(
                  color: AppTheme.textDisabled,
                  fontSize: 12,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => onTaskUpdate(task),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF4E342E),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              task.contactName.isNotEmpty
                  ? task.contactName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.contactName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.title} • ${task.frequency}',
                  style: const TextStyle(color: AppTheme.textSub, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(task.dueDate),
            style: const TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
