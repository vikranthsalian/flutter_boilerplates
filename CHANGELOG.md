# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-02-17

### 🎉 Initial Release

This is the first public release of `flutter_boilerplates`.

A CLI-driven Flutter Clean Architecture boilerplate generator designed to help developers quickly scaffold scalable, production-ready Flutter applications.

---

### ✨ Added

#### 🏗 Clean Architecture Structure
- Feature-based folder generation
- `data / domain / presentation` layers
- Core folder with shared utilities
- Scalable modular structure

---

#### 🔐 Authentication Module
- Login feature (Clean Architecture compliant)
- Signup feature
- Social Authentication (Google / Apple / Facebook ready)
- Forgot Password
- Reset Password
- AuthService Singleton (manual composition, no DI required)
- TokenManager with secure storage support
- Support for access + refresh tokens

---

#### 🌐 Networking
- DioClient (scalable, high-performance configuration)
- RequestManager support
- AuthInterceptor
- RetryInterceptor
- Centralized error handling
- Access token auto-attachment

---

#### 🔥 Firebase Integration
- Firebase Crashlytics setup
- Firebase Analytics integration
- Analytics event helpers

---

#### 🎨 UI Utilities
- Theme setup (Light & Dark mode)
- Reusable gradient utilities
- Common extensions
- Validators (email, password, required, etc.)
- Logger utility

---

#### 🧩 Navigation
- GoRouter setup
- Navigation helper
- NavigatorObserver support
- Auth guard ready structure

---

#### 🛠 CLI / Script Generators
- create_feature.sh
- create_auth_service.sh
- create_login_feature.sh
- create_signup_feature.sh
- create_social_auth_feature.sh
- create_reset_password_feature.sh
- create_forgot_password_feature.sh
- create_theme.sh
- create_validators.sh
- create_extensions.sh
- create_router.sh
- create_navigation_helper.sh

---

#### 📦 Package Support
- dio
- flutter_secure_storage
- firebase_core
- firebase_crashlytics
- firebase_analytics
- firebase_messaging
- share_plus
- image_picker
- file_picker
- package_info_plus
- network_info_plus

---

### 🧠 Architecture Principles

- No dependency injection required
- Manual composition supported
- Singleton-based AuthService
- Layer separation enforced
- Clean dependency flow
- Production-ready token handling

---

### 🚀 Designed For

- Scalable applications
- Enterprise-grade Flutter projects
- Feature based Architecture
- Rapid feature generation
- Boilerplate reduction

---

## Future Roadmap

- Dart CLI package version (replace shell scripts)
- Mason integration
- Multiple state management options (Bloc / Riverpod / Cubit)
- Environment switching support
- Modular plugin support
- Template customization
- Versioned boilerplate upgrades

---