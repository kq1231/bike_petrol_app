import 'package:intl/intl.dart';

/// Utility class for formatting dates in a user-friendly way
class DateFormatter {
  /// Format a date as a friendly string
  /// - Today → "Today"
  /// - Yesterday → "Yesterday"
  /// - Within 7 days → "2 days ago", "5 days ago"
  /// - Within current year → "Jan 15", "Dec 3"
  /// - Previous years → "Jan 15, 2023"
  static String formatFriendlyDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateDay);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (date.year == now.year) {
      return DateFormat('MMM d').format(date); // "Jan 15"
    } else {
      return DateFormat('MMM d, yyyy').format(date); // "Jan 15, 2023"
    }
  }

  /// Format time in 12-hour format with AM/PM
  /// Returns null if dateTime is null
  static String? formatTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return DateFormat('h:mm a').format(dateTime); // "9:30 AM"
  }

  /// Format date with time if available
  /// Examples:
  /// - "Today at 9:30 AM"
  /// - "Yesterday at 2:00 PM"
  /// - "Jan 15"
  static String formatDateWithOptionalTime(DateTime date, DateTime? time) {
    final dateStr = formatFriendlyDate(date);
    if (time != null) {
      final timeStr = formatTime(time);
      return '$dateStr at $timeStr';
    }
    return dateStr;
  }

  /// Calculate and format duration between two times
  /// Returns null if either time is null
  /// Examples: "45 min", "2h 30min"
  static String? formatDuration(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) return null;

    final duration = endTime.difference(startTime);
    if (duration.isNegative) return null;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  /// Format a full journey time display
  /// Examples:
  /// - "Today at 9:30 AM - 10:15 AM (45 min)"
  /// - "Yesterday at 2:00 PM"
  /// - "Jan 15"
  static String formatJourneyTime(
    DateTime date,
    DateTime? startTime,
    DateTime? endTime,
  ) {
    final dateStr = formatFriendlyDate(date);

    if (startTime != null && endTime != null) {
      final startStr = formatTime(startTime);
      final endStr = formatTime(endTime);
      final durationStr = formatDuration(startTime, endTime);
      return '$dateStr at $startStr - $endStr ($durationStr)';
    } else if (startTime != null) {
      final timeStr = formatTime(startTime);
      return '$dateStr at $timeStr';
    } else {
      return dateStr;
    }
  }

  /// Format date for date picker initial value
  /// Returns ISO format date string: "2024-01-15"
  static String formatForDatePicker(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// Parse date from date picker string
  /// Input: "2024-01-15"
  /// Output: DateTime(2024, 1, 15)
  static DateTime parseDatePickerString(String dateStr) {
    return DateTime.parse(dateStr);
  }
}
