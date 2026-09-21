/// Build-time configuration: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api`.
class Env {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/api');
  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
}
