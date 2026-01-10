import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/password_entry.dart';
import '../../utils/formatters.dart';
import '../../utils/clipboard_helper.dart';

class PasswordCard extends StatelessWidget {
  final PasswordEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PasswordCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF2D2D44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Site Icon (Initials)
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF6C63FF),
                child: Text(
                  Formatters.getInitials(entry.siteName),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Entry Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.siteName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.usernameOrEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.maskPassword(entry.password),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quick Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    color: const Color(0xFF6C63FF),
                    onPressed: () async {
                      await ClipboardHelper.copyToClipboard(entry.password);
                      Get.snackbar(
                        'Copied',
                        'Password copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF6C63FF),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    tooltip: 'Copy Password',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.white.withOpacity(0.7),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
