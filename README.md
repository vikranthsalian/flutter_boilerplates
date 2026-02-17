# Flutter Boilerplate

A production-ready Flutter Clean Architecture boilerplate generator.

This project provides shell-based generators to quickly scaffold scalable,
enterprise-grade Flutter projects.

---

# 📁 Environment Setup (.env)

Before running any generator scripts, you must create a `.env` file
in the **root of your Flutter project**.

---

## 📍 Where to Create It

Create the file here:

your_flutter_project/
├── lib/
├── pubspec.yaml
├── .env ← HERE

⚠️ `.env` must be at the root level (same level as `pubspec.yaml`).

---

## 📝 Example .env File

Create a file named `.env`:

```env
# Application Configuration
APP_NAME=my_app #app_name
BASE_DIR=lib

🔐 Add to .gitignore
Never commit sensitive environment variables: .env

# 🏗 Creating a Feature (Interactive Mode)

To generate a new feature, run:

📌 FEATURE BASED ARCHITECTURE: 
```bash
/bin/bash /Users/vikranthsalian/StudioProjects/flutter_boilerplates/scripts/feature_arch_script/sub_scripts/create_feature.sh

You will be prompted:

Feature Generator (Feature Based Architecture)
---------------------------------------------
👉 Enter feature path (relative to lib/features/, e.g. auth/signup):
👉 Enter feature name (e.g. login, signup, forgot_password):
📌 Example Run
👉 Enter feature path: home
👉 Enter feature name: dashboard

Output:

📦 Creating dashboard Feature
   • Feature Name : dashboard
   • Class Prefix : Dashboard
   • Directory : lib/features/home/dashboard

🎉 Feature 'dashboard' created successfully!
📁 Location: lib/features/home/dashboard

📁 Generated Structure
lib/features/home/dashboard/
 ├── data/
 │   ├── datasources/
 │   ├── models/
 │   └── repositories/
 ├── domain/
 │   ├── entities/
 │   ├── repositories/
 │   └── usecases/
 └── presentation/
     └── pages/