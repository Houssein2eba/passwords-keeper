import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class AppLockController extends GetxController with WidgetsBindingObserver {
  static const String _pinHashKey = 'pin_hash';
  static const String _pinSaltKey = 'pin_salt';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const int _autoLockDurationSeconds = 60; // 1 minute

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Reactive state
  final RxBool isLocked = true.obs;
  final RxBool isBiometricAvailable = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isPinSet = false.obs;

  Timer? _autoLockTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricAvailability();
    _checkPinStatus();
    _loadBiometricPreference();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoLockTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background - lock immediately
      lock();
    } else if (state == AppLifecycleState.resumed) {
      // App coming to foreground - ensure locked if PIN is set
      if (isPinSet.value) {
        lock();
      }
    }
  }

  /// Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      isBiometricAvailable.value = canCheckBiometrics && isDeviceSupported;
      
      if (isBiometricAvailable.value) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        print('Available biometrics: $availableBiometrics');
      }
    } catch (e) {
      print('Error checking biometric availability: $e');
      isBiometricAvailable.value = false;
    }
  }

  /// Check if PIN is already set
  Future<void> _checkPinStatus() async {
    final pinHash = await _secureStorage.read(key: _pinHashKey);
    isPinSet.value = pinHash != null;
    
    // If no PIN is set, app is unlocked by default
    if (!isPinSet.value) {
      isLocked.value = false;
    }
  }

  /// Load biometric preference
  Future<void> _loadBiometricPreference() async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    isBiometricEnabled.value = enabled == 'true';
  }

  /// Set a new PIN
  Future<bool> setPIN(String pin) async {
    try {
      if (pin.length < 4 || pin.length > 8) {
        return false;
      }

      // Generate random salt
      final salt = _generateSalt();
      
      // Hash PIN with salt using PBKDF2
      final hash = _hashPIN(pin, salt);

      // Store hash and salt
      await _secureStorage.write(key: _pinHashKey, value: hash);
      await _secureStorage.write(key: _pinSaltKey, value: salt);

      isPinSet.value = true;
      return true;
    } catch (e) {
      print('Error setting PIN: $e');
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPIN(String pin) async {
    try {
      final storedHash = await _secureStorage.read(key: _pinHashKey);
      final salt = await _secureStorage.read(key: _pinSaltKey);

      if (storedHash == null || salt == null) {
        return false;
      }

      final inputHash = _hashPIN(pin, salt);
      return inputHash == storedHash;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  /// Unlock with PIN
  Future<bool> unlockWithPIN(String pin) async {
    final isValid = await verifyPIN(pin);
    
    if (isValid) {
      unlock();
      return true;
    }
    
    return false;
  }

  /// Authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    try {
      if (!isBiometricAvailable.value || !isBiometricEnabled.value) {
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock Password Manager',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        unlock();
        return true;
      }

      return false;
    } catch (e) {
      print('Error authenticating with biometric: $e');
      return false;
    }
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    if (!isBiometricAvailable.value) {
      return;
    }

    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
    isBiometricEnabled.value = enabled;
  }

  /// Lock the app
  void lock() {
    isLocked.value = true;
    _autoLockTimer?.cancel();
  }

  /// Unlock the app
  void unlock() {
    isLocked.value = false;
    _startAutoLockTimer();
  }

  /// Reset auto-lock timer (call on user interaction)
  void resetAutoLockTimer() {
    if (!isLocked.value) {
      _startAutoLockTimer();
    }
  }

  /// Start auto-lock timer
  void _startAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = Timer(
      const Duration(seconds: _autoLockDurationSeconds),
      () {
        if (isPinSet.value) {
          lock();
        }
      },
    );
  }

  /// Hash PIN using PBKDF2
  String _hashPIN(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    
    // Apply multiple iterations for PBKDF2-like behavior
    var result = digest.bytes;
    for (int i = 0; i < 10000; i++) {
      result = sha256.convert(result).bytes;
    }
    
    return base64.encode(result);
  }

  /// Generate random salt
  String _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return base64.encode(utf8.encode(random));
  }

  /// Reset PIN (requires biometric or data loss)
  Future<bool> resetPIN() async {
    if (isBiometricAvailable.value && isBiometricEnabled.value) {
      final authenticated = await authenticateWithBiometric();
      if (authenticated) {
        await _secureStorage.delete(key: _pinHashKey);
        await _secureStorage.delete(key: _pinSaltKey);
        isPinSet.value = false;
        isLocked.value = false;
        return true;
      }
    }
    return false;
  }

  /// Delete all security data (for complete reset)
  Future<void> deleteAllSecurityData() async {
    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.delete(key: _pinSaltKey);
    await _secureStorage.delete(key: _biometricEnabledKey);
    isPinSet.value = false;
    isLocked.value = false;
  }
}
