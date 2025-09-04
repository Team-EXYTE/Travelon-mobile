import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showChangePasswordDialog(BuildContext context) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small box for existing password
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade100),
                      ),
                      child: TextField(
                        controller: oldController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Existing Password',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    // Small box for new password
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade100),
                      ),
                      child: TextField(
                        controller: newController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    // Small box for confirm password
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade100),
                      ),
                      child: TextField(
                        controller: confirmController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm New Password',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Add your password change logic here
                  Navigator.pop(context);
                },
                child: const Text('Change'),
              ),
            ],
          ),
    );
  }

  Widget sectionTitle(String title) => Container(
    width: double.infinity,
    color: Colors.grey.shade200,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 16,
        letterSpacing: 1,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade50,
      body: ListView(
        children: [
          sectionTitle('Legal'),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.black),
            title: const Text('Terms & Conditions'),
            subtitle: const Text(
              'Read our terms and conditions for using Travelon.',
            ),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Terms & Conditions – Travelon'),
                      content: const SingleChildScrollView(
                        child: Text(
                          'Last Updated: 1st July 2025\n\n'
                          'Welcome to Travelon! By accessing or using our mobile application, you agree to comply with and be bound by the following Terms and Conditions:\n\n'
                          '1. Use of the App\n'
                          'You must be at least 18 years old to use Travelon.\n'
                          'You agree to use the app only for lawful purposes and in accordance with these terms.\n\n'
                          '2. Bookings and Cancellations\n'
                          'Bookings are confirmed once payment is successfully processed.\n'
                          'Cancellation and refund policies vary depending on the tour provider.\n\n'
                          '3. Payments\n'
                          'We accept major debit/credit cards and digital payment options.\n'
                          'Travelon is not responsible for delays or failures caused by third-party payment gateways.\n\n'
                          '4. Account Responsibility\n'
                          'You are responsible for maintaining the confidentiality of your account credentials.\n'
                          'Travelon may suspend or terminate accounts for suspicious or harmful activity.\n\n'
                          '5. Intellectual Property\n'
                          'All content in the app is the property of Travelon or its partners and may not be reused without permission.\n\n'
                          '6. Limitation of Liability\n'
                          'Travelon is not liable for direct or indirect damages arising from the use of the app or services.\n\n'
                          '7. Changes to Terms\n'
                          'These terms may be updated without prior notice. Continued use of the app implies acceptance of the new terms.\n\n'
                          '8. Governing Law\n'
                          'These terms are governed by the laws of Sri Lanka.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.black),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Learn how we protect your data.'),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Privacy Policy – Travelon'),
                      content: const SingleChildScrollView(
                        child: Text(
                          'Effective Date: July 2025\n\n'
                          'This Privacy Policy outlines how we collect, use, and protect your personal information.\n\n'
                          '1. Data We Collect\n'
                          'Personal Information: Name, email and phone number.\n'
                          'Booking Information: Travel details, preferences, destinations.\n'
                          'Payment Info: Card details (securely processed).\n'
                          'Device Info: OS version, app usage, IP address.\n\n'
                          '2. How We Use Your Data\n'
                          'To process bookings and send confirmations.\n'
                          'To personalize recommendations and offers.\n'
                          'To improve app features and performance.\n'
                          'To send marketing messages (opt-out available).\n\n'
                          '3. Data Sharing\n'
                          'With airlines, hotels, and travel partners only when necessary.\n'
                          'We never sell your personal data.\n\n'
                          '4. Data Security\n'
                          'Data is encrypted during transmission and stored securely.\n'
                          'Access is restricted to authorized personnel only.\n\n'
                          '5. Your Rights\n'
                          'You can update or delete your personal info from your profile settings.\n'
                          'You can request a copy of your stored data by contacting support.\n\n'
                          '6. Changes to This Policy\n'
                          'Major changes will be notified via the app or email.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          const SizedBox(height: 8),
          sectionTitle('Support'),
          ListTile(
            title: const Text('Help Center'),
            subtitle: const Text('Frequently Asked Questions'),
            leading: const Icon(Icons.help_outline, color: Colors.black),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Help Center - FAQs'),
                      content: const SingleChildScrollView(
                        child: Text(
                          'Q: What happens when I cancel a trip?\n'
                          'A: If you cancel before the cancellation deadline, you will receive a full refund. After the deadline, cancellation fees may apply.\n\n'
                          'Q: How do I change my booking?\n'
                          'A: Go to My Bookings and select the booking you want to change.\n\n'
                          'Q: Why was my payment declined?\n'
                          'A: Check your card details, balance, and bank authorization. Try a different method if needed.\n\n'
                          'Q: Can I book for someone else?\n'
                          'A: Yes, you can enter the traveler’s details during the booking process.\n\n'
                          'Q: How do I contact customer support?\n'
                          'A: Use the Contact Support option in this menu .\n\n'
                          'Q: How do I reset my password?\n'
                          'A: Use the Change Password option in the Account section.\n\n'
                          'Q: How do I delete my Travelon account?\n'
                          'A: You can delete your account by contacting support.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          ListTile(
            title: const Text('Contact Support'),
            leading: const Icon(Icons.support_agent, color: Colors.black),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Contact Support – Travelon'),
                      content: const SingleChildScrollView(
                        child: Text(
                          'Need help? We’re here for you.\n\n'
                          '📧 Email: support@travelon.com\n'
                          '☎️ Hotline: +94 11 123 4567\n'
                          '🕐 Hours: Monday – Friday, 9:00 AM to 6:00 PM (GMT+5:30)\n\n'
                          "We'll respond to all support requests within 24 hours on business days.",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          const SizedBox(height: 8),
          sectionTitle('Account'),
          ListTile(
            title: const Text('Change Password'),
            leading: const Icon(Icons.lock, color: Colors.black),
            onTap: () => _showChangePasswordDialog(context),
          ),
        ],
      ),
    );
  }
}
