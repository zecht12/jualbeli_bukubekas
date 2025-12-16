import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  static String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 7) {
      return formatDate(date);
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} hari yang lalu';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}