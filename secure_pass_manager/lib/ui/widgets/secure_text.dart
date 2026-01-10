import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class SecureText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int autoHideSeconds;
  final bool initiallyVisible;

  const SecureText({
    super.key,
    required this.text,
    this.style,
    this.autoHideSeconds = 10,
    this.initiallyVisible = false,
  });

  @override
  State<SecureText> createState() => _SecureTextState();
}

class _SecureTextState extends State<SecureText> {
  final RxBool _isVisible = false.obs;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _isVisible.value = widget.initiallyVisible;
    if (widget.initiallyVisible) {
      _startAutoHideTimer();
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    super.dispose();
  }

  void _toggleVisibility() {
    _isVisible.value = !_isVisible.value;
    
    if (_isVisible.value) {
      _startAutoHideTimer();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(
      Duration(seconds: widget.autoHideSeconds),
      () {
        if (mounted) {
          _isVisible.value = false;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => Text(
            _isVisible.value ? widget.text : '•' * widget.text.length,
            style: widget.style,
            overflow: TextOverflow.ellipsis,
          )),
        ),
        const SizedBox(width: 8),
        Obx(() => IconButton(
          icon: Icon(
            _isVisible.value ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onPressed: _toggleVisibility,
          color: Colors.white.withOpacity(0.7),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        )),
      ],
    );
  }
}
