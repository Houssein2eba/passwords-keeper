import 'package:get/get.dart';
import 'password_entry.dart';
import 'hive_manager.dart';

class PasswordRepository extends GetxController {
  final HiveManager _hiveManager = Get.find<HiveManager>();
  
  // Reactive list of all passwords
  final RxList<PasswordEntry> passwords = <PasswordEntry>[].obs;
  
  // Search query
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  /// Load all password entries
  void loadAll() {
    final allEntries = _hiveManager.passwordBox.values.toList();
    
    // Sort by updatedAt descending (most recent first)
    allEntries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    passwords.value = allEntries;
  }

  /// Get all entries (for compatibility)
  Future<List<PasswordEntry>> getAll() async {
    return passwords;
  }

  /// Search entries by site name or username
  List<PasswordEntry> search(String query) {
    if (query.isEmpty) {
      return passwords;
    }

    return passwords.where((entry) => entry.matchesQuery(query)).toList();
  }

  /// Get filtered entries based on current search query
  List<PasswordEntry> get filteredPasswords {
    if (searchQuery.value.isEmpty) {
      return passwords;
    }
    return search(searchQuery.value);
  }

  /// Add a new password entry
  Future<void> add(PasswordEntry entry) async {
    await _hiveManager.passwordBox.put(entry.id, entry);
    loadAll();
  }

  /// Update an existing password entry
  Future<void> updateEntry(PasswordEntry entry) async {
    entry.updatedAt = DateTime.now();
    await _hiveManager.passwordBox.put(entry.id, entry);
    loadAll();
  }

  /// Delete a password entry by ID
  Future<void> delete(String id) async {
    await _hiveManager.passwordBox.delete(id);
    loadAll();
  }

  /// Get entry by ID
  PasswordEntry? getById(String id) {
    return _hiveManager.passwordBox.get(id);
  }

  /// Get total count
  int get count => passwords.length;

  /// Check if repository is empty
  bool get isEmpty => passwords.isEmpty;

  /// Check if repository has entries
  bool get isNotEmpty => passwords.isNotEmpty;
}
