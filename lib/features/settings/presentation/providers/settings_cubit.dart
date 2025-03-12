import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/features/settings/presentation/states/settings.dart';

class SettingsCubit extends Cubit<Settings> {
  SettingsCubit() : super(Settings());

  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  Future<void> saveLoginInformation(LoginInformation loginInformation) async {
    final instance = await prefs;
    await instance.setString(Settings.emailType.key, loginInformation.email);
    await instance.setString(Settings.passwordType.key, loginInformation.password);
  }

  Future<Settings> loadSettings() async {
    final instance = await prefs;
    return Settings(
      email: instance.getString(Settings.emailType.key),
      password: instance.getString(Settings.passwordType.key),
    );
  }
}
