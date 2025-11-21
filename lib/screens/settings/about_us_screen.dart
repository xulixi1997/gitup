import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.done_all,
                  color: AppTheme.accent,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'QuickContactTask',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Version 1.1.0',
                style: TextStyle(color: AppTheme.textSub),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Our Mission',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'QuickContactTask is designed to help you stay connected with the people who matter most. We believe that maintaining relationships should be simple, intentional, and stress-free.',
              style: TextStyle(color: AppTheme.textSub, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'The Team',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We are a small team of passionate developers and designers dedicated to creating beautiful and functional software. Thank you for using our app!',
              style: TextStyle(color: AppTheme.textSub, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
