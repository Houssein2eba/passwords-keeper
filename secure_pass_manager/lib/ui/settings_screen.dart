import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_lock/app_lock_controller.dart';
import '../data/hive_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLockController lockController = Get.find<AppLockController>();
    final HiveManager hiveManager = Get.find<HiveManager>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Security'),
          const SizedBox(height: 8),
          
          // Biometric Toggle
          Obx(() => _buildSettingTile(
            title: 'Use Biometrics',
            subtitle: 'Unlock app using Fingerprint or Face ID',
            icon: Icons.fingerprint,
            trailing: Switch(
              value: lockController.isBiometricEnabled.value,
              onChanged: lockController.isBiometricAvailable.value
                  ? (value) => lockController.setBiometricEnabled(value)
                  : null,
              activeColor: const Color(0xFF6C63FF),
            ),
            enabled: lockController.isBiometricAvailable.value,
          )),
          
          const SizedBox(height: 16),
          _buildSettingTile(
            title: 'Change PIN',
            subtitle: 'Update your security PIN',
            icon: Icons.lock_reset,
            onTap: () async {
              // Reset PIN and navigate to lock screen to set new one
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  backgroundColor: const Color(0xFF2D2D44),
                  title: const Text('Change PIN?', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'This will clear your current PIN. You will need to set a new one immediately.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Confirm', style: TextStyle(color: Color(0xFF6C63FF))),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await lockController.deleteAllSecurityData();
                Get.offAllNamed('/home');
              }
            },
          ),

          const SizedBox(height: 32),
          _buildSectionHeader('About'),
          const SizedBox(height: 8),
          _buildSettingTile(
            title: 'Version',
            subtitle: '1.0.0',
            icon: Icons.info_outline,
          ),
          
          const SizedBox(height: 32),
          // Danger Zone
          _buildSectionHeader('Danger Zone', color: Colors.redAccent),
          const SizedBox(height: 8),
          _buildSettingTile(
            title: 'Clear All Data',
            subtitle: 'Delete all passwords and reset the app',
            icon: Icons.delete_forever,
            color: Colors.redAccent,
            onTap: () async {
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  backgroundColor: const Color(0xFF2D2D44),
                  title: const Text('Factory Reset?', style: TextStyle(color: Colors.redAccent)),
                  content: const Text(
                    'This will PERMANENTLY delete all your saved passwords and security settings. This action cannot be undone.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('RESET ALL', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                // Clear everything
                await lockController.deleteAllSecurityData();
                await hiveManager.deleteAllData();
                Get.offAllNamed('/home');
              }

            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color ?? const Color(0xFF6C63FF),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: enabled ? onTap : null,
        enabled: enabled,
        leading: Icon(icon, color: color ?? (enabled ? Colors.white : Colors.white24)),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? (enabled ? Colors.white : Colors.white24),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: enabled ? Colors.white60 : Colors.white12),
        ),
        trailing: trailing,
      ),
    );
  }
}
