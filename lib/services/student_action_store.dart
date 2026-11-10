import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StudentActionStore {
  StudentActionStore._();

  static const _waitKey = 'student_wait_requests';
  static const _itemsKey = 'student_lost_found_items';

  static Future<List<Map<String, dynamic>>> waitRequests() async {
    final preferences = await SharedPreferences.getInstance();
    return _readList(preferences.getString(_waitKey));
  }

  static Future<List<Map<String, dynamic>>> lostFoundItems() async {
    final preferences = await SharedPreferences.getInstance();
    return _readList(preferences.getString(_itemsKey));
  }

  static Future<void> addWaitRequest({
    required String reason,
    required DateTime requestedAt,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final items = _readList(preferences.getString(_waitKey));
    items.insert(0, {
      'reason': reason,
      'requestedAt': requestedAt.toIso8601String(),
      'status': 'Aguardando sincronização com o motorista',
    });
    await preferences.setString(_waitKey, jsonEncode(items));
  }

  static Future<void> addLostFoundItem({
    required String type,
    required String description,
    required String bus,
    required String imageBase64,
    required DateTime createdAt,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final items = _readList(preferences.getString(_itemsKey));
    items.insert(0, {
      'type': type,
      'description': description,
      'bus': bus,
      'image': imageBase64,
      'createdAt': createdAt.toIso8601String(),
    });
    await preferences.setString(_itemsKey, jsonEncode(items));
  }

  static List<Map<String, dynamic>> _readList(String? json) {
    if (json == null || json.isEmpty) return [];
    final decoded = jsonDecode(json);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
}
