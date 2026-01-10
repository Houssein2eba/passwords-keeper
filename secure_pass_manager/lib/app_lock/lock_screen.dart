import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app_lock_controller.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AppLockController _lockController = Get.find<AppLockController>();
  final RxString _pinInput = ''.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isSettingPin = false.obs;
  final RxString _confirmPin = ''.obs;

  @override
  void initState() {
    super.initState();
    _isSettingPin.value = !_lockController.isPinSet.value;
  }

  void _onNumberPressed(String number) {
    if (_pinInput.value.length < 8) {
      _pinInput.value += number;
      _errorMessage.value = '';

      // Auto-submit when PIN is complete (4-8 digits)
      if (_pinInput.value.length >= 4 && !_isSettingPin.value) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pinInput.value.isNotEmpty) {
      _pinInput.value = _pinInput.value.substring(0, _pinInput.value.length - 1);
      _errorMessage.value = '';
    }
  }

  void _onClear() {
    _pinInput.value = '';
    _errorMessage.value = '';
  }

  Future<void> _verifyPin() async {
    if (_pinInput.value.length < 4) {
      _errorMessage.value = 'PIN must be at least 4 digits';
      return;
    }

    final success = await _lockController.unlockWithPIN(_pinInput.value);
    
    if (success) {
      _pinInput.value = '';
      _errorMessage.value = '';
    } else {
      _errorMessage.value = 'Incorrect PIN';
      _pinInput.value = '';
      HapticFeedback.vibrate();
    }
  }

  Future<void> _setNewPin() async {
    if (_confirmPin.value.isEmpty) {
      // First entry - ask for confirmation
      if (_pinInput.value.length < 4 || _pinInput.value.length > 8) {
        _errorMessage.value = 'PIN must be 4-8 digits';
        return;
      }
      _confirmPin.value = _pinInput.value;
      _pinInput.value = '';
      _errorMessage.value = 'Confirm your PIN';
    } else {
      // Confirmation entry
      if (_pinInput.value != _confirmPin.value) {
        _errorMessage.value = 'PINs do not match';
        _pinInput.value = '';
        _confirmPin.value = '';
        return;
      }

      final success = await _lockController.setPIN(_pinInput.value);
      
      if (success) {
        _lockController.unlock();
        _pinInput.value = '';
        _confirmPin.value = '';
        _errorMessage.value = '';
      } else {
        _errorMessage.value = 'Failed to set PIN';
        _pinInput.value = '';
        _confirmPin.value = '';
      }
    }
  }

  Future<void> _useBiometric() async {
    final success = await _lockController.authenticateWithBiometric();
    
    if (!success) {
      _errorMessage.value = 'Biometric authentication failed';
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/app_icon.png',
                height: 120,
              ),

              const SizedBox(height: 24),
              
              // Title
              Obx(() => Text(
                _isSettingPin.value 
                    ? (_confirmPin.value.isEmpty ? 'Set Your PIN' : 'Confirm PIN')
                    : 'Enter PIN',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
              const SizedBox(height: 12),
              
              // Subtitle
              Obx(() => Text(
                _isSettingPin.value
                    ? 'Create a 4-8 digit PIN to secure your passwords'
                    : 'Unlock to access your passwords',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              )),
              const SizedBox(height: 48),
              
              // PIN Dots Display
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  8,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _pinInput.value.length
                          ? const Color(0xFF6C63FF)
                          : Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 24),
              
              // Error Message
              Obx(() => SizedBox(
                height: 24,
                child: _errorMessage.value.isNotEmpty
                    ? Text(
                        _errorMessage.value,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      )
                    : const SizedBox.shrink(),
              )),
              const SizedBox(height: 32),
              
              // Number Keypad
              _buildKeypad(),
              const SizedBox(height: 24),
              
              // Biometric Button
              Obx(() {
                if (!_isSettingPin.value && 
                    _lockController.isBiometricAvailable.value &&
                    _lockController.isBiometricEnabled.value) {
                  return TextButton.icon(
                    onPressed: _useBiometric,
                    icon: const Icon(Icons.fingerprint, size: 28),
                    label: const Text('Use Biometric'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              
              const SizedBox(height: 16),
              
              // Forgot PIN
              if (!_isSettingPin.value)
                TextButton(
                  onPressed: () async {
                    if (_lockController.isBiometricAvailable.value && 
                        _lockController.isBiometricEnabled.value) {
                      final success = await _lockController.resetPIN();
                      if (success) {
                        Get.snackbar(
                          'PIN Reset',
                          'Your PIN has been reset. Please set a new one.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF6C63FF),
                          colorText: Colors.white,
                        );
                        _isSettingPin.value = true;
                      }
                    } else {
                      _errorMessage.value = 'Biometric reset not available.\nUninstall app to reset all data.';
                    }
                  },
                  child: Text(
                    'Forgot PIN?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),

        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildKeypadRow(['', '0', 'back']),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }
        
        if (number == 'back') {
          return _buildKeypadButton(
            onPressed: _onBackspace,
            child: const Icon(
              Icons.backspace_outlined,
              color: Colors.white,
              size: 28,
            ),
          );
        }

        return _buildKeypadButton(
          onPressed: () => _onNumberPressed(number),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
