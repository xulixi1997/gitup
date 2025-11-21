import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';

class AddContactModal extends StatefulWidget {
  final Function(Contact) onSave;

  const AddContactModal({super.key, required this.onSave});

  @override
  State<AddContactModal> createState() => _AddContactModalState();
}

class _AddContactModalState extends State<AddContactModal> {
  final _nameController = TextEditingController();
  final _taskController = TextEditingController();
  String _selectedFrequency = 'Weekly';
  final List<String> _frequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
    'None',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Connection Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Name
          _buildLabel('Name / Title'),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Mom, Landlord',
              hintStyle: TextStyle(color: AppTheme.textSub.withValues(alpha: 0.5)),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.person, color: AppTheme.textSub),
            ),
          ),
          const SizedBox(height: 16),

          // Task Type
          _buildLabel('Task Type'),
          TextField(
            controller: _taskController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Call, Pay Rent',
              hintStyle: TextStyle(color: AppTheme.textSub.withValues(alpha: 0.5)),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.checklist, color: AppTheme.textSub),
            ),
          ),
          const SizedBox(height: 16),

          // Frequency
          _buildLabel('Frequency'),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _frequencies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final freq = _frequencies[index];
                final isSelected = freq == _selectedFrequency;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFrequency = freq),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accent : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.white10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      freq,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save & Create',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textSub,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty || _taskController.text.isEmpty) return;

    final newContact = Contact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      taskTitle: _taskController.text,
      frequency: _selectedFrequency,
      colorIndex: 0, // Default for now
    );

    widget.onSave(newContact);
    Navigator.pop(context);
  }
}
