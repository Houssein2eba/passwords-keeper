import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'password_entry.dart';

class HiveManager {
  static const String _encryptionKeyName = 'hive_encryption_key';
  static const String _passwordBoxName = 'passwords';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Box<PasswordEntry>? _passwordBox;

  /// Initialize Hive and open encrypted box
  Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PasswordEntryAdapter());
    }

    // Get or generate encryption key
    final encryptionKey = await _getOrCreateEncryptionKey();

    // Open encrypted box
    _passwordBox = await Hive.openBox<PasswordEntry>(
      _passwordBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  /// Get the password box
  Box<PasswordEntry> get passwordBox {
    if (_passwordBox == null || !_passwordBox!.isOpen) {
      throw Exception('Hive not initialized. Call init() first.');
    }
    return _passwordBox!;
  }

  /// Get or create 256-bit encryption key
  Future<List<int>> _getOrCreateEncryptionKey() async {
    try {
      // Try to read existing key
      final existingKey = await _secureStorage.read(key: _encryptionKeyName);
      
      if (existingKey != null) {
        // Decode and return existing key
        return base64Url.decode(existingKey);
      }
    } catch (e) {
      // If reading fails, generate new key
      print('Error reading encryption key: $e');
    }

    // Generate new 256-bit key
    final key = _generateSecureKey();
    
    // Store key in secure storage
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64Url.encode(key),
    );

    return key;
  }

  /// Generate a cryptographically secure 256-bit key
  List<int> _generateSecureKey() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256));
  }

  /// Close all boxes
  Future<void> close() async {
    await _passwordBox?.close();
  }

  /// Delete all data (for testing or reset)
  Future<void> deleteAllData() async {
    await _passwordBox?.clear();
    await _secureStorage.delete(key: _encryptionKeyName);
  }
}
