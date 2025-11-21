import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  final List<Task> tasks;

  const StatsScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    // Sort by completedAt descending (newest first)
    completedTasks.sort((a, b) {
      final dateA = a.completedAt ?? a.dueDate;
      final dateB = b.completedAt ?? b.dueDate;
      return dateB.compareTo(dateA);
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Completed This Week
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final completedThisWeek = completedTasks.where((t) {
      final date = t.completedAt ?? t.dueDate;
      return date.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
    }).length;

    // 2. Streak Calculation
    int streak = 0;
    final completedDates = <DateTime>{};
    for (var t in completedTasks) {
      final date = t.completedAt ?? t.dueDate;
      completedDates.add(DateTime(date.year, date.month, date.day));
    }

    var checkDate = today;
    if (!completedDates.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (completedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stats & History',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Completed This Week',
                      '$completedThisWeek',
                      icon: Icons.arrow_upward,
                      iconColor: Colors.green,
                      footer: '20%',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Streak',
                      '$streak',
                      unit: 'Days',
                      textColor: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity Trend',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar('M', 0.4),
                        _buildBar('T', 0.6),
                        _buildBar('W', 0.85, isActive: true),
                        _buildBar('T', 0.3),
                        _buildBar('F', 0.5),
                        _buildBar('S', 0.2),
                        _buildBar('S', 0.4),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // History
              Text(
                'HISTORY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textSub,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedTasks.length > 5
                    ? 5
                    : completedTasks.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final task = completedTasks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            task.contactName.isNotEmpty
                                ? task.contactName[0]
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMM d, HH:mm',
                                ).format(task.completedAt ?? task.dueDate),
                                style: const TextStyle(
                                  color: AppTheme.textSub,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value, {
    String? unit,
    Color? textColor,
    IconData? icon,
    Color? iconColor,
    String? footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppTheme.textSub, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(color: AppTheme.textSub, fontSize: 14),
                ),
              ],
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (icon != null) Icon(icon, size: 12, color: iconColor),
                const SizedBox(width: 4),
                Text(footer, style: TextStyle(color: iconColor, fontSize: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightPct, {bool isActive = false}) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 100,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 30,
            height: 100 * heightPct,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.accent
                  : AppTheme.textSub.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.accent.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textSub,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
