import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

typedef SettingsType<T> = ({String key, T defaultValue});

@freezed
class Settings with _$Settings {
  static const SettingsType emailType = (key: 'name', defaultValue: '');
  static const SettingsType passwordType = (key: 'password', defaultValue: '');

  final String email;
  final String password;

  bool get isLoginInformationEmpty => email.isEmpty || password.isEmpty;

  Settings({String? email, String? password})
    : email = email ?? emailType.defaultValue,
      password = password ?? passwordType.defaultValue;
}

@freezed
class LoginInformation with _$LoginInformation {
  final String email;
  final String password;

  LoginInformation({required this.email, required this.password});
}
