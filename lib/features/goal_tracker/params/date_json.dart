/// Formats a [DateTime] as the API's calendar-date form (`YYYY-MM-DD`).
extension ApiDate on DateTime {
  String toApiDate() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
