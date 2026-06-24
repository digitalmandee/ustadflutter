import 'package:flutter/material.dart';
import 'package:flutterustad/Custom%20widgets/app_bar.dart';
import 'package:flutterustad/Helpers/app_theme.dart';

class PoliciesScreen extends StatelessWidget {
  final bool isPrivacy;
  const PoliciesScreen({super.key, required this.isPrivacy});

  @override
  Widget build(BuildContext context) {
    // Data based on screen type
    final Map<String, List<String>> content = isPrivacy
        ? {
            "Information We Collect": [
              "Personal details such as name, email, phone number, and payment information; plus anonymized usage data to improve services.",
            ],
            "Use of Information": [
              "To connect students with tutors, process payments, send important notifications, and improve the platform experience.",
            ],
            "Data Sharing": [
              "Ustaad does not sell or share personal data with third parties except as necessary for service delivery (e.g., payment processors).",
            ],
            "Security": [
              "We employ industry-standard encryption and data protection measures to safeguard user information.",
            ],
            "User Rights": [
              "Users may request to access, correct, or delete their personal data at any time by contacting our support team.",
            ],
          }
        : {
            "Use of Platform": [
              "Ustaad connects students and parents with verified tutors for academic learning and mentorship. All users agree to use the platform responsibly and ethically.",
            ],
            "Accounts": [
              "Tutors can register without any cost during the first year. Users must maintain confidentiality of their login credentials and provide accurate personal information.",
            ],
            "Payments": [
              "All payments are processed securely through our approved payment gateway. Parents/students are eligible for a 100% refund if not satisfied after the first session (see Refund Policy).",
            ],
            "Tutor Rates & Packages": [
              "Rates are determined individually by each tutor and may vary based on years of experience, subject expertise, and student popularity. Packages may also differ depending on the number of sessions booked.",
            ],
            "Content": [
              "Only educational material may be uploaded or shared. Offensive, misleading, or copyrighted content is prohibited.",
            ],
            "Limitation of Liability": [
              "Ustaad facilitates connections between tutors and students but does not guarantee individual tutor performance. Please review a tutor’s profile and communicate directly before starting lessons. A full refund is available if you are not satisfied after the first session during the first year. After the first year, billing applies only for lessons completed.",
            ],
            "Updates": [
              "Ustaad reserves the right to modify these Terms. Users will be notified of major updates in advance.",
            ],
          };

    return Scaffold(
      appBar: CustomAppBar1(
        title: isPrivacy ? "Privacy Policies" : "Terms and Conditions",
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: content.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCOlor,
                  ),
                ),
                const SizedBox(height: 8),
                ...entry.value.map(
                  (paragraph) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      paragraph,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
