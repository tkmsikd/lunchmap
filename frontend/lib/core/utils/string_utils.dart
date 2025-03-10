/// Utility functions for string operations
class StringUtils {
  /// Truncate a string to a maximum length and add an ellipsis if truncated
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Convert a string to title case (capitalize the first letter of each word)
  static String toTitleCase(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Check if a string is null, empty, or contains only whitespace
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Get the first n characters of a string
  static String firstChars(String text, int n) {
    if (text.length <= n) {
      return text;
    }
    return text.substring(0, n);
  }

  /// Get the last n characters of a string
  static String lastChars(String text, int n) {
    if (text.length <= n) {
      return text;
    }
    return text.substring(text.length - n);
  }

  /// Remove all whitespace from a string
  static String removeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }

  /// Format a phone number to a readable format
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Format based on length
    if (digitsOnly.length == 10) {
      // Format as 090-1234-5678
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
    } else if (digitsOnly.length == 11) {
      // Format as 090-1234-5678
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
    } else {
      // Return as is if it doesn't match expected formats
      return phoneNumber;
    }
  }

  /// Format a price with the Japanese yen symbol and thousands separator
  static String formatPrice(int price) {
    return '¥${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// Mask a string (e.g. for privacy)
  static String mask(
    String text, {
    int visibleChars = 4,
    String maskChar = '*',
  }) {
    if (text.length <= visibleChars) {
      return text;
    }

    final visible = text.substring(0, visibleChars);
    final masked = maskChar * (text.length - visibleChars);

    return visible + masked;
  }

  /// Check if a string is a valid email address
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  /// Check if a string is a valid Japanese phone number
  static bool isValidJapanesePhoneNumber(String phoneNumber) {
    final phoneRegExp = RegExp(r'^(0[5-9]0|0[1-9][1-9]0)[0-9]{8}$');
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return phoneRegExp.hasMatch(digitsOnly);
  }

  /// Convert a string to a slug (lowercase, hyphens instead of spaces)
  static String toSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }
}
