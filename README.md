# 💰 Bachat Karo

> **Bachat Karo** (Hindi: *"Save Money"*) — A smart, AI-assisted personal finance tracker built with Flutter and powered by Supabase.

---

## 📱 About

Bachat Karo is a cross-platform mobile expense tracker that helps users take control of their daily finances. It combines a clean, modern UI with a real-time Supabase backend to deliver secure authentication, seamless expense management, insightful spending analytics, and easy data import — all in one app.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Authentication** | Secure sign-up & sign-in via Supabase Auth (email/password) |
| 💸 **Expense Tracking** | Add, edit, and delete expenses with categories and dates |
| 📊 **Insights & Analytics** | Visual breakdown of spending patterns and trends |
| 📂 **File Import** | Import transactions from external files (CSV/JSON) |
| 👤 **User Profile** | Persistent profile management with Supabase |
| 🌙 **Dark & Light Themes** | Custom-designed dark navy + teal and clean light themes |
| 📱 **Portrait Lock** | Optimized for portrait-mode mobile use |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter (Dart) |
| **Backend / Auth** | Supabase (PostgreSQL + Auth + Storage) |
| **State Management** | Provider |
| **Local Storage** | `shared_preferences`, `flutter_secure_storage` |
| **Date/Formatting** | `intl` |
| **File Handling** | `file_picker` |
| **Font** | Inter (400, 500, 600, 700) |

---

## 🏗️ Project Structure

```
lib/
├── main.dart                  # App entry point, theme setup, Supabase init
├── bachat_karo.dart           # Root app widget
├── core/
│   ├── constants/             # App-wide constants
│   ├── state/                 # Global AppState (Provider)
│   ├── supabase/              # Supabase config & client
│   ├── theme/                 # Color tokens & theme helpers
│   └── utils/                 # Utility functions
├── features/
│   ├── auth/                  # Login, sign-up, auth gate
│   ├── expense/               # Expense CRUD (add, edit, delete, list)
│   ├── insights/              # Analytics & spending breakdowns
│   ├── home/                  # Home screen / dashboard
│   ├── account/               # User profile & settings
│   └── import/                # File import (CSV/JSON)
└── shared/                    # Shared widgets and components
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.0.0 <4.0.0`
- A [Supabase](https://supabase.com) project with the required tables set up
- Android Studio / VS Code with Flutter extension

### 1. Clone the Repository

```bash
git clone https://github.com/Chandrabhanu-Prusty/Bachat-Karo.git
cd Bachat-Karo
```

### 2. Configure Supabase

Create your Supabase project at [supabase.com](https://supabase.com) and note your **Project URL** and **Anon Key**.

Then update the config file:

```dart
// lib/core/supabase/supabase_config.dart
class SupabaseConfig {
  static const supabaseUrl  = 'YOUR_SUPABASE_URL';
  static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

---

## 🗄️ Supabase Database Schema

The app uses the following tables (set up in your Supabase dashboard):

- **`profiles`** — User profile data linked to `auth.users`
- **`expenses`** — Individual expense records (amount, category, date, note)

Enable **Row Level Security (RLS)** on all tables and add policies so users can only access their own data.

---

## 🎨 Theme Design

### Light Theme
- Background: `#F5F3EE` (warm off-white)
- Primary: `#0D3D35` (deep forest green)
- Surface: `#FFFFFF`

### Dark Theme
- Background: `#141920` (deep navy-charcoal)
- Primary: `#2DCAAA` (vibrant teal)
- Surface: `#1D2535` (lifted card bg)
- Accent: `#39A7D6` (sky blue)

---

## 📦 Dependencies

```yaml
dependencies:
  supabase_flutter: ^2.5.6
  provider: ^6.1.2
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.2
  file_picker: ^8.0.3
  intl: ^0.19.0
  cupertino_icons: ^1.0.8
```

---

## 🤝 Contributing

1. Fork the project
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is for educational/academic purposes as part of an AI Mini Project.

---

<p align="center">Made with ❤️ using Flutter & Supabase</p>
