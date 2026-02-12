# 💰 Kept Aom (เก็บออม)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.27.1-blue.svg?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-green?logo=supabase)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-blue?logo=dart)](https://riverpod.dev)
[![GoRouter](https://img.shields.io/badge/Navigation-GoRouter-orange?logo=dart)](https://pub.dev/packages/go_router)

**Kept Aom** is a study project developed to practice building modern Flutter applications. It serves as a personal finance tracker designed to help manage expenses and income with ease, focusing on clean architecture and efficient state management.

> [!NOTE]
> This is a **Practice Project** created for learning purposes, focusing on Flutter 3.27.1 and Supabase integration.

---

## ✨ Features

- **Intuitive Dashboard**: At-a-glance view of your financial status.
- **Transaction Management**: Easily add, edit, and track your daily spending and earnings.
- **Custom Categories**: Organize your transactions with expressive emojis and meaningful titles.
- **Quick Titles**: Streamlined entry for common transactions.
- **Goal Tracking**: Set and monitor your saving goals.
- **Calendar View**: Visualize your spending habits over time.
- **Dark & Light Mode**: Seamless theme switching for a comfortable experience.

---

## 🚀 Tech Stack

- **Framework**: [Flutter 3.27.1](https://flutter.dev)
- **Backend-as-a-Service**: [Supabase](https://supabase.com) (Authentication, Database)
- **State Management**: [Riverpod](https://riverpod.dev) (using Generators)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Storage**: `shared_preferences`
- **UI Components**:
  - `table_calendar` for transaction scheduling.
  - `emoji_picker_flutter` for category customization.
  - `animated_toggle_switch` & `flutter_slidable` for interactive elements.
  - Custom animations using `animations` and `page_transition`.

---

## 📂 Project Structure

```text
lib/
├── assets/          # Images, fonts (GoogleSans), and icons
├── models/          # Data models (Transaction, Category, etc.)
├── router/          # App routing configuration (GoRouter)
├── services/        # Backend integration (Supabase Service)
├── utils/           # Helper classes and theme definitions
├── viewmodels/      # Business logic and state management (Riverpod)
└── views/           # UI implementation (Pages and Widgets)
```

---

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK (v3.27.1 recommended)
- Dart SDK
- A Supabase account and project

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/watsharapat/kept_aom.git
    cd kept_aom
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Code Generation:**
    This project uses `riverpod_generator`. Run the following to generate necessary files:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the application:**
    ```bash
    flutter run
    ```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
