import 'package:intl/intl.dart';

abstract class AppFormatters {
  static final _currencyFormatter = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  static final _currencyFormatterDecimal = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  static final _dayMonthFormatter = DateFormat('d MMM');
  static final _fullDateFormatter = DateFormat('EEEE, MMM d');
  static final _monthYearFormatter = DateFormat('MMMM yyyy');
  static final _shortDayFormatter = DateFormat('EEE');

  /// Formats ₹1430 → "₹1,430"
  static String currency(double amount) =>
      _currencyFormatter.format(amount);

  /// Formats ₹1430.50 → "₹1,430.50"
  static String currencyDecimal(double amount) =>
      _currencyFormatterDecimal.format(amount);

  /// "4 Oct"
  static String dayMonth(DateTime date) => _dayMonthFormatter.format(date);

  /// "Wednesday, Oct 4"
  static String fullDate(DateTime date) => _fullDateFormatter.format(date);

  /// "October 2023"
  static String monthYear(DateTime date) => _monthYearFormatter.format(date);

  /// "Mon", "Tue" etc.
  static String shortDay(DateTime date) => _shortDayFormatter.format(date);

  /// "09:15 AM"
  static String time(DateTime date) => DateFormat('hh:mm a').format(date);
}
