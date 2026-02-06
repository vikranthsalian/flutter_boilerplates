#!/bin/bash
set -e

echo "🧭 Creating go_router setup..."

# Ensure Flutter project
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ pubspec.yaml not found. Run from project root."
  exit 1
fi

# Create routes directory
mkdir -p $BASE_DIR/core/routes

###############################################################################
# route_paths.dart
###############################################################################
cat << 'EOF' > $BASE_DIR/core/routes/route_paths.dart
abstract class RoutePaths {
  static const login = '/login';
}
EOF

###############################################################################
# route_names.dart
###############################################################################
cat << 'EOF' > $BASE_DIR/core/routes/route_names.dart
abstract class RouteNames {
  static const login = 'login';
}
EOF

###############################################################################
# app_router.dart
###############################################################################
cat << 'EOF' > $BASE_DIR/core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_route_observer.dart';

import '../../features/auth/login/presentation/pages/login_page.dart';

import 'route_names.dart';
import 'route_paths.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RoutePaths.login,
      redirect: (context, state) {
        return null;
      },
      observers: [
          AppRouteObserver(),
        ],
      routes: [
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (context, state) => const LoginPage(),
        )
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(state.error.toString()),
        ),
      ),
    );
  }
}
EOF

###############################################################################
# Add dependency
###############################################################################
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding go_router dependency..."
  flutter pub add go_router
else
  echo "⚠️ Flutter not found. Add manually:"
  echo "go_router: ^14.0.0"
fi

echo "✅ go_router setup completed."

###############################################################################
# app_route_observer.dart
###############################################################################
cat << 'EOF' > $BASE_DIR/core/routes/app_route_observer.dart
import '../utils/firebase/analytics_service.dart';
import '../utils/logging/logger.dart';
import 'package:flutter/material.dart';
/// Global route observer for the app.
/// Used for analytics, logging, and crash breadcrumbs.
class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute(route, 'PUSH');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute(previousRoute, 'POP');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _logRoute(newRoute, 'REPLACE');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _logRoute(Route<dynamic>? route, String action) {
    if (route == null) return;

    final routeName = route.settings.name ?? route.runtimeType.toString();

    AppLogger.i('Navigation $action → $routeName');
    AnalyticsService.logScreen(routeName);
  }
}
EOF

echo "✅ AppRouteObserver created."
echo ""
echo "👉 Wire it in app_router.dart:"
echo "GoRouter(observers: [AppRouteObserver()], ...)"



echo "👉 Next: wire AppRouter into MaterialApp.router"


cat << 'EOF' > $BASE_DIR/core/routes/USAGE_README_GOROUTER.md
# GoRouter – Usage Guide (main.dart)

This document explains **how to wire and use `go_router`**
in this Flutter project.

The routing system is **centralized**, **feature-based**, and
scales well for large applications.

---

## 📦 Dependency

```yaml
dependencies:
  go_router: ^17.1.0

$BASE_DIR/routes/
 ├── app_router.dart
 ├── route_paths.dart
 └── route_names.dart

#Import the AppRouter
import 'routes/app_router.dart';

#Use MaterialApp.router
#Replace MaterialApp with MaterialApp.router:
MaterialApp.router(
 routerConfig: AppRouter.createRouter(),
);

#Example
import 'package:flutter/material.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.createRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

#Navigation Examples
Navigate using route name
context.goNamed(RouteNames.login);
context.goNamed(RouteNames.signup);

#Navigate using route path
context.go(RoutePaths.login);
context.go(RoutePaths.signup);

#Push (keep previous screen)
context.push(RoutePaths.signup);

#Replace current route
context.go(RoutePaths.home);

#Pop route
context.pop();

# (Optional) Auth Redirect Example

Auth guards are usually added later in AppRouter.
redirect: (context, state) {
  final isLoggedIn = false; // check token
  if (!isLoggedIn && state.location != RoutePaths.login) {
    return RoutePaths.login;
  }
  return null;
},
