import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/password_entry.dart';
import '../data/password_repository.dart';
import '../utils/formatters.dart';
import '../utils/clipboard_helper.dart';
import 'widgets/secure_text.dart';

class EntryDetailSheet extends StatelessWidget {
  final PasswordEntry entry;

  const EntryDetailSheet({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final PasswordRepository repository = Get.find<PasswordRepository>();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D44),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF6C63FF),
                      child: Text(
                        Formatters.getInitials(entry.siteName),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.siteName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Updated ${Formatters.formatDateTime(entry.updatedAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Username/Email
                _buildDetailField(
                  label: 'Username/Email',
                  value: entry.usernameOrEmail,
                  icon: Icons.person,
                  onCopy: () async {
                    await ClipboardHelper.copyToClipboard(entry.usernameOrEmail);
                    Get.snackbar(
                      'Copied',
                      'Username copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF6C63FF),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // Password
                _buildPasswordField(
                  label: 'Password',
                  password: entry.password,
                  icon: Icons.lock,
                  onCopy: () async {
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
                ),
                
                // Notes (if available)
                if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildDetailField(
                    label: 'Notes',
                    value: entry.notes!,
                    icon: Icons.notes,
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          Get.toNamed('/edit', arguments: entry);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          _showDeleteConfirmation(context, repository, entry);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF6C63FF), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  color: const Color(0xFF6C63FF),
                  onPressed: onCopy,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String password,
    required IconData icon,
    VoidCallback? onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF6C63FF), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: SecureText(
                  text: password,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  autoHideSeconds: 10,
                ),
              ),
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  color: const Color(0xFF6C63FF),
                  onPressed: onCopy,
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    PasswordRepository repository,
    PasswordEntry entry,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Password?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete the password for ${entry.siteName}? This action cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await repository.delete(entry.id);
              Get.snackbar(
                'Deleted',
                'Password deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
