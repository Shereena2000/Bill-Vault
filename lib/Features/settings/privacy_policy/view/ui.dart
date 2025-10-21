import 'package:flutter/material.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_text_styles.dart';


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: PTextStyles.displaySmall,
        ),
        iconTheme:  IconThemeData(color: PColors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: October 2, 2025\n',
              style: PTextStyles.bodySmall,
            ),
            Text(
              'Bill Vault (“we”, “our”, or “us”) respects your privacy. This Privacy Policy explains how we handle your information when you use our mobile application Bill Vault.',
              style: PTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              '1. Information We Collect',
              style: PTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Email Address: If you create an account using Firebase Email Authentication, we only collect and store your email for login purposes.\n'
              '• Camera & Photos: To allow you to upload warranty cards, purchase bills, and receipts.\n'
              '• Contacts (Optional): If you save service provider details (like repair or customer care contacts).\n'
              '• Network Access: Required to connect with our cloud services and keep your data backed up and synced.\n'
              'We do not collect your name, profile picture, or any unnecessary personal details.',
              style: PTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              '2. How We Use Information',
              style: PTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We use your information only to:\n'
              '• Allow you to log in securely with your email.\n'
              '• Help you store and manage warranty cards, purchase bills, subscriptions, and service contacts.\n'
              '• Provide safe cloud backup of documents and images using Firebase and Cloudinary.\n'
              'We do not sell, rent, or share your email or data with advertisers or unrelated third parties.',
              style: PTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              '3. Data Storage & Security',
              style: PTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your data is stored securely using Firebase Cloud Firestore (structured data) and Cloudinary (images/documents).\n'
              '• We use industry-standard methods to protect your information, but no method of transmission over the Internet is 100% secure.',
              style: PTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              '4. Sharing of Information',
              style: PTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We will only share your data if:\n'
              '• Required by law or government authorities.\n'
              '• Needed for trusted services like Firebase and Cloudinary that help run the app.',
              style: PTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              '5. Your Rights',
              style: PTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Delete your account and all associated data at any time.\n'
              '• Revoke permissions (Camera, Storage, etc.) through your device settings.',
              style: PTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              '6. Third-Party Services',
              style: PTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This app uses third-party services including:\n'
              '• Firebase Authentication → For secure login with email.\n'
              '• Firebase Cloud Firestore → For storing your data in the cloud.\n'
              '• Cloudinary → For storing images and documents (like bills and warranties).\n'
              'These services may collect limited technical data as described in their own privacy policies.',
              style: PTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              '7. Children’s Privacy',
              style: PTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Bill Vault is not directed to children under 13. We do not knowingly collect personal data from children.',
              style: PTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              '8. Changes to This Policy',
              style: PTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We may update this Privacy Policy occasionally. Updates will be shown in the app or on our website with a new “Last updated” date.',
              style: PTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              '9. Contact Us',
              style: PTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'If you have questions, please contact us:\n📧 shereenajamezz@gmail.com',
              style: PTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
