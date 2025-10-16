import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toFormattedString() {
    return DateFormat('dd MMM yyyy, hh:mm a').format(this);
  }

  String toDateOnly() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String toTimeOnly() {
    return DateFormat('hh:mm a').format(this);
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }

  String truncate(int length) {
    return this.length > length ? '${substring(0, length)}...' : this;
  }
}

extension IntExtension on int {
  String formatCoins() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}