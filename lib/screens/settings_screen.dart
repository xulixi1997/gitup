import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'settings/about_us_screen.dart';
import 'settings/feedback_screen.dart';
import 'settings/help_screen.dart';
import 'settings/privacy_screen.dart';
import 'settings/terms_screen.dart';
import '../services/storage_service.dart';
import '../widgets/toast_overlay.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(context, 'About App'),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  children: [
                    _buildListTile(context, 'About Us', const AboutUsScreen()),
                    _buildListTile(
                      context,
                      'Help & Support',
                      const HelpScreen(),
                    ),
                    _buildListTile(
                      context,
                      'Feedback',
                      const FeedbackScreen(),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(context, 'Legal'),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      context,
                      'Terms of Service',
                      const TermsScreen(),
                    ),
                    _buildListTile(
                      context,
                      'Privacy Policy',
                      const PrivacyScreen(),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildSectionHeader(context, 'Danger Zone'),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      context,
                      'Clear All Data',
                      null,
                      isLast: true,
                      isDestructive: true,
                      onTap: () => _showClearDataConfirmation(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.done_all, color: AppTheme.accent),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'QuickContactTask v1.1.0',
                      style: TextStyle(color: AppTheme.textSub, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.textSub,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    Widget? page, {
    bool isLast = false,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : Colors.white,
            fontSize: 14,
            fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSub,
          size: 18,
        ),
        onTap:
            onTap ??
            () {
              if (page != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              }
            },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Clear All Data?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This action cannot be undone. All your contacts and tasks will be permanently deleted.',
          style: TextStyle(color: AppTheme.textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSub),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService().clearAll();
              if (context.mounted) {
                showToast(
                  context,
                  'Data Cleared',
                  'All app data has been reset.',
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
