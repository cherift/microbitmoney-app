// Extension pour formater la date comme ISO string
extension DateTimeExtension on DateTime {
  String toISOString() {
    return toUtc().toIso8601String();
  }
}