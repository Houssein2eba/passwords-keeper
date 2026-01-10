import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'password_entry.g.dart';

@HiveType(typeId: 0)
class PasswordEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String siteName;

  @HiveField(2)
  late String usernameOrEmail;

  @HiveField(3)
  late String password;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late DateTime updatedAt;

  PasswordEntry({
    String? id,
    required this.siteName,
    required this.usernameOrEmail,
    required this.password,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // Copy with method for updates
  PasswordEntry copyWith({
    String? siteName,
    String? usernameOrEmail,
    String? password,
    String? notes,
  }) {
    return PasswordEntry(
      id: id,
      siteName: siteName ?? this.siteName,
      usernameOrEmail: usernameOrEmail ?? this.usernameOrEmail,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // For search functionality
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return siteName.toLowerCase().contains(lowerQuery) ||
        usernameOrEmail.toLowerCase().contains(lowerQuery);
  }

  @override
  String toString() {
    return 'PasswordEntry(id: $id, siteName: $siteName, username: $usernameOrEmail)';
  }
}
