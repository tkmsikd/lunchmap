import 'package:intl/intl.dart';

/// Utility functions for date and time operations
class DateUtils {
  /// Format a DateTime to a string with the format 'yyyy/MM/dd'
  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  /// Format a DateTime to a string with the format 'yyyy/MM/dd HH:mm'
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }

  /// Format a DateTime to a relative time string (e.g. "3 minutes ago", "2 days ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}週間前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  /// Format a DateTime to a string representing the day of week
  static String formatDayOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    return days[dayOfWeek - 1]; // weekday is 1-based (1 = Monday, 7 = Sunday)
  }

  /// Format a DateTime to a string with the format 'MM/dd (day of week)'
  static String formatDateWithDayOfWeek(DateTime date) {
    final dayOfWeek = formatDayOfWeek(date);
    return '${DateFormat('MM/dd').format(date)} ($dayOfWeek)';
  }

  /// Format a time range from two DateTime objects
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
  }

  /// Check if a DateTime is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a DateTime is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if a DateTime is within the last week
  static bool isWithinLastWeek(DateTime date) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    return date.isAfter(oneWeekAgo) && date.isBefore(now);
  }

  /// Format a DateTime to a string with the format 'HH:mm'
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Parse a string with the format 'yyyy/MM/dd' to a DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy/MM/dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse a string with the format 'yyyy/MM/dd HH:mm' to a DateTime
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return DateFormat('yyyy/MM/dd HH:mm').parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
}
