import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsUtil {
  static late bool isNotifOn;
  static List<int> buffers = const [0, 5, 15, 30, 60];
  static late int bufferIndex;

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isNotifOn = prefs.getBool('isNotifOn') ?? true;
    bufferIndex = prefs.getInt('bufferIndex') ?? 0;

    Logger().d(isNotifOn.toString());
  }

  static Future<void> saveNotifSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotifOn', value);
    isNotifOn = value;
  }

  static Future<void> saveBufferIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bufferIndex', index);
    bufferIndex = index;
  }
}
