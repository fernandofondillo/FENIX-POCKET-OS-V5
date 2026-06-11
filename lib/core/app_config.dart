// lib/core/app_config.dart
// Configuración central de Fénix Pocket OS V5.
// URL base del backend A.G.O.S. en el VPS (FastAPI + Arq + Redis + Qwen 7B).

class AppConfig {
  /// URL pública del backend V5 desplegado en el VPS.
  /// El túnel ngrok expone el FastAPI local :8000 al exterior.
  static const String apiBaseUrl = 'https://roguish-degradedly-anjelica.ngrok-free.dev';

  /// Headers requeridos por el túnel ngrok (free tier).
  /// Se envían en cada request para evitar el interstitial HTML de validación.
  static const Map<String, String> ngrokHeaders = {
    'ngrok-skip-browser-warning': 'true',
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Versión de la aplicación (semver).
  static const String appVersion = '5.0.0';

  /// Identificador de build.
  static const int buildNumber = 50;
}
