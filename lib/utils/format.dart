import 'package:intl/intl.dart';

/// One date/number format across the app (UI consistency checklist).
abstract final class Fmt {
  static final _date = DateFormat('EEE, d MMM yyyy');
  static final _dateTime = DateFormat('EEE, d MMM yyyy · HH:mm');

  static String date(DateTime d) => _date.format(d);
  static String dateTime(DateTime d) => _dateTime.format(d);

  /// "2 days 14 hours left" (Lab 2 decision: relative countdown, never a raw date alone).
  static String countdown(Duration left) {
    if (left.isNegative || left == Duration.zero) return 'Closed';
    final days = left.inDays;
    final hours = left.inHours % 24;
    final minutes = left.inMinutes % 60;
    String unit(int n, String one) => '$n $one${n == 1 ? '' : 's'}';
    if (days > 0) return '${unit(days, 'day')} ${unit(hours, 'hour')} left';
    if (hours > 0) return '${unit(hours, 'hour')} ${unit(minutes, 'minute')} left';
    return '${unit(minutes, 'minute')} left';
  }

  /// "Just now", "12 min ago", "3 h ago", "Yesterday", or a date.
  static String ago(DateTime then, DateTime now) {
    final d = now.difference(then);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    if (d.inDays == 1) return 'Yesterday';
    return date(then);
  }

  static String percent(double v) => '${(v * 100).round()}%';

  /// "1 more member", "2 more members": pluralises the last word.
  static String count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';
}
