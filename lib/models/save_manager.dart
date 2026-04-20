import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/player_state.dart';

class SaveManager {
  static const String _saveKey = 'artisan_save_data_002';

  static Future<void> saveGame(PlayerState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> data = {
        'themeMode': state.currentTheme.index,
        'hunger': state.hunger,
        'townMorale': state.townMorale,
        'wallets': state.wallets.map((k, v) => MapEntry(k.toString(), v)),
        'constructedBuildings': state.constructedBuildings,
        'hiredWorkers': state.hiredWorkers,
      };

      String jsonString = jsonEncode(data);
      await prefs.setString(_saveKey, jsonString);
      print("Game saved successfully!");
    } catch (e) {
      print("Failed to save game: $e");
    }
  }

  static Future<void> loadGame(PlayerState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_saveKey);

      if (jsonString != null) {
        Map<String, dynamic> data = jsonDecode(jsonString);
        state.overwriteState(data);
        print("Game loaded successfully!");
      } else {
        print("No save game found. Using seeded database.");
      }
    } catch (e) {
      print("Failed to load game: $e");
    }
  }
}
