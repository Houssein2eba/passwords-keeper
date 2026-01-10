import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/password_entry.dart';
import '../data/password_repository.dart';
import '../utils/validators.dart';
import 'dart:math';

class EditEntryScreen extends StatefulWidget {
  final PasswordEntry? entry; // null for new entry

  const EditEntryScreen({super.key, this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final PasswordRepository _repository = Get.find<PasswordRepository>();
  
  late TextEditingController _siteNameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _notesController;
  
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isSaving = false.obs;

  @override
  void initState() {
    super.initState();
    _siteNameController = TextEditingController(text: widget.entry?.siteName ?? '');
    _usernameController = TextEditingController(text: widget.entry?.usernameOrEmail ?? '');
    _passwordController = TextEditingController(text: widget.entry?.password ?? '');
    _notesController = TextEditingController(text: widget.entry?.notes ?? '');
  }

  @override
  void dispose() {
    _siteNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isSaving.value = true;

    try {
      if (widget.entry == null) {
        // Create new entry
        final newEntry = PasswordEntry(
          siteName: _siteNameController.text.trim(),
          usernameOrEmail: _usernameController.text.trim(),
          password: _passwordController.text,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        await _repository.add(newEntry);
      } else {
        // Update existing entry
        final updatedEntry = widget.entry!.copyWith(
          siteName: _siteNameController.text.trim(),
          usernameOrEmail: _usernameController.text.trim(),
          password: _passwordController.text,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        await _repository.updateEntry(updatedEntry);
      }

      Get.back();
      Get.snackbar(
        'Success',
        widget.entry == null ? 'Password added' : 'Password updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF6C63FF),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      _isSaving.value = false;
    }
  }

  void _generatePassword() {
    const length = 16;
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';
    final random = Random.secure();
    final password = List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
    
    _passwordController.text = password;
    _isPasswordVisible.value = true;
    
    Get.snackbar(
      'Generated',
      'Strong password generated',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6C63FF),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.entry == null ? 'Add Password' : 'Edit Password',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: _isSaving.value ? null : _saveEntry,
            child: _isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          )),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Site Name
            _buildTextField(
              controller: _siteNameController,
              label: 'Site Name',
              hint: 'e.g., Google, Facebook',
              icon: Icons.language,
              validator: Validators.validateSiteName,
            ),
            const SizedBox(height: 20),
            
            // Username/Email
            _buildTextField(
              controller: _usernameController,
              label: 'Username/Email',
              hint: 'your@email.com',
              icon: Icons.person,
              validator: Validators.validateUsername,
            ),
            const SizedBox(height: 20),
            
            // Password
            Obx(() => _buildTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter password',
              icon: Icons.lock,
              obscureText: !_isPasswordVisible.value,
              validator: Validators.validatePassword,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: () => _isPasswordVisible.value = !_isPasswordVisible.value,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: _generatePassword,
                    tooltip: 'Generate Password',
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),
            
            // Notes (Optional)
            _buildTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              hint: 'Additional information',
              icon: Icons.notes,
              maxLines: 3,
              validator: Validators.validateNotes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF2D2D44),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
