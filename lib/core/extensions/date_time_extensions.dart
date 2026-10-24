import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toHumanReadable() {
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm');
    final timeString = timeFormat.format(this);

    if (year == now.year && month == now.month && day == now.day) {
      return 'Hoy, $timeString';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day) {
      return 'Ayer, $timeString';
    }

    final dateFormat = DateFormat('d MMM', 'es');
    return '${dateFormat.format(this)}, $timeString';
  }
}
