import 'package:cloud_firestore/cloud_firestore.dart';

import '../errors/app_exception.dart';

/// Defensive readers for Firestore / JSON maps. Required fields throw
/// [DataParsingException]; optional ones fall back.
class Parse {
  Parse._();

  static String requireString(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is String && v.isNotEmpty) return v;
    throw DataParsingException(cause: 'Missing string "$key"');
  }

  static String string(Map<String, dynamic> map, String key, [String fallback = '']) {
    final v = map[key];
    return v is String ? v : fallback;
  }

  static String? optString(Map<String, dynamic> map, String key) {
    final v = map[key];
    return v is String && v.isNotEmpty ? v : null;
  }

  static int integer(Map<String, dynamic> map, String key, [int fallback = 0]) {
    final v = map[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static double number(Map<String, dynamic> map, String key, [double fallback = 0]) {
    final v = map[key];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static bool boolean(Map<String, dynamic> map, String key, [bool fallback = false]) {
    final v = map[key];
    return v is bool ? v : fallback;
  }

  static List<String> stringList(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is List) return v.whereType<String>().toList(growable: false);
    return const [];
  }

  static DateTime? date(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static List<Map<String, dynamic>> mapList(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is List) {
      return v
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => e.map((k, value) => MapEntry(k.toString(), value)))
          .toList(growable: false);
    }
    return const [];
  }
}
