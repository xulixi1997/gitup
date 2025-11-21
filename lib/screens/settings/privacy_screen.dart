import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated: November 20, 2025',
              style: TextStyle(color: AppTheme.textSub, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information Collection',
              'We collect information that you provide directly to us, such as when you create an account, update your profile, or communicate with us. This includes contact information and task details.',
            ),
            _buildSection(
              '2. Use of Information',
              'We use the information we collect to provide, maintain, and improve our services, such as to track your tasks and contacts history.',
            ),
            _buildSection(
              '3. Data Storage',
              'Your data is stored locally on your device. We do not upload your personal data to any external servers without your explicit consent.',
            ),
            _buildSection(
              '4. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at privacy@quickcontacttask.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(color: AppTheme.textSub, height: 1.5),
          ),
        ],
      ),
    );
  }
}
