import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/features/settings/domain/models/settings.dart';

class SettingsService {
  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  static Future<void> saveLoginInformation(LoginInformation loginInformation) async {
    final instance = await prefs;
    await instance.setString(Settings.emailType.key, loginInformation.email);
    await instance.setString(Settings.passwordType.key, loginInformation.password);
  }

  static Future<Settings> loadSettings() async {
    final instance = await prefs;
    return Settings(
      email: instance.getString(Settings.emailType.key),
      password: instance.getString(Settings.passwordType.key),
    );
  }
}
