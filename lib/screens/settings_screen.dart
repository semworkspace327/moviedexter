import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF2D1B4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  // App Title
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 60),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD233).withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFD233),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.movie_outlined,
                            size: 60,
                            color: Color(0xFFFFD233),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Movie Dexter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Movie & TV Companion',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSettingsButton(
                          context: context,
                          icon: Icons.star_rounded,
                          title: 'Rate Us',
                          subtitle: 'Share your feedback',
                          onTap: () async {
                            const appId = '6755246790';
                            final url =
                                'https://apps.apple.com/app/id$appId?action=write-review';
                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not open App Store'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildSettingsButton(
                          context: context,
                          icon: Icons.email_rounded,
                          title: 'Contact Us',
                          subtitle: 'Get in touch with us',
                          onTap: () async {
                            final uri = Uri(
                              scheme: 'mailto',
                              path: 'semworkspace327@gmail.com',
                              query: 'subject=Movie Dexter Support',
                            );
                            if (await canLaunchUrlString(uri.toString())) {
                              await launchUrlString(uri.toString());
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not open email app'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildSettingsButton(
                          context: context,
                          icon: Icons.privacy_tip_rounded,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy policy',
                          onTap: () async {
                            const url =
                                'https://moviediary112.blogspot.com/2025/11/movie-diary-this-privacy-policy.html';
                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open privacy policy',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Version Info
                  const SizedBox(height: 40),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD233).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFFD233), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
