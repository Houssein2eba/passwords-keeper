import 'package:intl/intl.dart';

class Formatters {
  /// Format DateTime to human-readable string
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // If today, show time
    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('HH:mm').format(dateTime)}';
    }
    
    // If yesterday
    if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('HH:mm').format(dateTime)}';
    }
    
    // If within a week
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    
    // Otherwise show full date
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  /// Get initials from site name
  static String getInitials(String siteName) {
    if (siteName.isEmpty) return '?';
    
    final words = siteName.trim().split(RegExp(r'\s+'));
    
    if (words.length == 1) {
      return siteName.substring(0, 1).toUpperCase();
    }
    
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  /// Mask password (show dots)
  static String maskPassword(String password) {
    return '•' * password.length;
  }

  /// Format password strength
  static String getPasswordStrength(String password) {
    if (password.length < 6) return 'Weak';
    if (password.length < 10) return 'Medium';
    
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    final criteriaCount = [hasUpperCase, hasLowerCase, hasDigits, hasSpecialChars]
        .where((criteria) => criteria)
        .length;
    
    if (criteriaCount >= 3) return 'Strong';
    if (criteriaCount >= 2) return 'Medium';
    return 'Weak';
  }
}
