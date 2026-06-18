# PayTrack 🚀

PayTrack is a comprehensive Flutter application designed to streamline daily collections, expense management, and customer tracking. Built with modern clean architecture principles, it provides a robust and scalable solution for field agents and collection businesses.

## ✨ Features

- **🔒 Authentication**: Secure user login and session management.
- **🏠 Dashboard/Home**: Overview of daily metrics and quick actions.
- **👥 Customer Management**: Add, view, and manage customer details.
- **💰 Collections (Vasool)**: Record and track daily payments efficiently.
- **💸 Expense Tracking**: Log daily expenses to maintain accurate ledgers.
- **📊 Reports**: Generate and view detailed collection and expense reports.
- **⚙️ Settings & Support**: Manage app preferences, user profile, and access support.

## 🏗️ Architecture

This project follows **Clean Architecture** principles to ensure separation of concerns, testability, and scalability. The codebase is organized into `core` and feature-based modules:

- `lib/core/`: Contains shared utilities, network configurations, and common widgets.
- `lib/features/`: Contains independent, fully-encapsulated feature modules (`auth`, `collections`, `customers`, `expenses`, `home`, `reports`, `settings`).

## 🚀 Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version recommended)
- Dart SDK (comes with Flutter)
- Android Studio / VS Code with Flutter plugins

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd paytrack
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Architecture**: Clean Architecture (Feature-based)

## 📚 Flutter Resources

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.
