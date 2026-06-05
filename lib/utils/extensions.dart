extension DateFormatting on DateTime {
  String get formatDate =>
      '${day.toString().padLeft(2, '0')}.'
      '${month.toString().padLeft(2, '0')}.'
      '$year';
}
