import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../data/password_repository.dart';
import '../app_lock/app_lock_controller.dart';
import 'widgets/password_card.dart';
import 'widgets/empty_state.dart';
import 'entry_detail_sheet.dart';
import 'edit_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PasswordRepository _repository = Get.find<PasswordRepository>();
  final AppLockController _lockController = Get.find<AppLockController>();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start new timer (300ms debounce)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _repository.searchQuery.value = query;
    });
  }

  void _showEntryDetail(entry) {
    // Reset auto-lock timer on interaction
    _lockController.resetAutoLockTimer();
    
    Get.bottomSheet(
      EntryDetailSheet(entry: entry),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _addNewEntry() {
    _lockController.resetAutoLockTimer();
    Get.to(() => const EditEntryScreen());
  }

  void _editEntry(entry) {
    _lockController.resetAutoLockTimer();
    Get.to(() => EditEntryScreen(entry: entry));
  }

  Future<void> _deleteEntry(entry) async {
    _lockController.resetAutoLockTimer();
    
    final confirmed = await Get.dialog<bool>(
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
          'Are you sure you want to delete the password for ${entry.siteName}?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.delete(entry.id);
      Get.snackbar(
        'Deleted',
        'Password deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Reset auto-lock timer on any interaction
        _lockController.resetAutoLockTimer();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A2E),
          elevation: 0,
          title: const Text(
            'Password Guardian',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                _lockController.resetAutoLockTimer();
                Get.toNamed('/settings');
              },
            ),

          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onTap: () => _lockController.resetAutoLockTimer(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search passwords...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            _searchController.clear();
                            _repository.searchQuery.value = '';
                            _lockController.resetAutoLockTimer();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            
            // Password List
            Expanded(
              child: Obx(() {
                final filteredPasswords = _repository.filteredPasswords;
                
                if (_repository.isEmpty) {
                  return EmptyState(
                    title: 'No Passwords Yet',
                    message: 'Add your first password to get started',
                    icon: Icons.lock_open,
                    actionLabel: 'Add Password',
                    onActionPressed: _addNewEntry,
                  );
                }
                
                if (filteredPasswords.isEmpty) {
                  return EmptyState(
                    title: 'No Results',
                    message: 'No passwords match your search',
                    icon: Icons.search_off,
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    _repository.loadAll();
                    _lockController.resetAutoLockTimer();
                  },
                  backgroundColor: const Color(0xFF2D2D44),
                  color: const Color(0xFF6C63FF),
                  child: ListView.builder(
                    itemCount: filteredPasswords.length,
                    itemBuilder: (context, index) {
                      final entry = filteredPasswords[index];
                      return PasswordCard(
                        entry: entry,
                        onTap: () => _showEntryDetail(entry),
                        onEdit: () => _editEntry(entry),
                        onDelete: () => _deleteEntry(entry),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewEntry,
          backgroundColor: const Color(0xFF6C63FF),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
