import 'package:intl/intl.dart';

String formatDate(String isoDate) {
  DateTime dateTime = DateTime.parse(isoDate);
  return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
}