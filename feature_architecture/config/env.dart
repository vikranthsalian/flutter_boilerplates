
enum AppEnv { dev, stage, prod }

class Env {
  static AppEnv current = AppEnv.dev;

  static String get baseUrl {
    switch (current) {
      case AppEnv.dev:
        return "https://dev.api.example.com";
      case AppEnv.stage:
        return "https://stage.api.example.com";
      case AppEnv.prod:
        return "https://api.example.com";
    }
  }
}
