import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MigrationHelper {
  static const String _migrationKey = 'auth_migration_v2_completed';

  static Future<void> migrateAuthStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final migrationCompleted = prefs.getBool(_migrationKey) ?? false;

      if (!migrationCompleted) {
        debugPrint('Starting authentication storage migration...');
        
        await prefs.remove('API_Key');
        
        await prefs.setBool(_migrationKey, true);
        
        debugPrint('Authentication storage migration completed successfully');
      }
    } catch (e) {
      debugPrint('Migration error: $e');
    }
  }

  static Future<void> clearAllLegacyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final legacyKeys = [
        'API_Key',
        'device_token',
        'fcm_token',
      ];

      for (final key in legacyKeys) {
        await prefs.remove(key);
      }

      debugPrint('Legacy data cleared');
    } catch (e) {
      debugPrint('Error clearing legacy data: $e');
    }
  }
}
