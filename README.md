# Vasool Drive (PayTrack) 🚀

Vasool Drive is a premium, comprehensive microfinance and daily collection management system built with Flutter. It streamlines daily collections (vasool), loan histories, customer tracking, expense logging, and line accounting for field agents and lenders.

---

## ✨ Features

- **🔒 Auth & Security**:
  - Secure login/registration flows with complete profile data synchronization (email, mobile, roles).
  - In-app **Change Password** directly linked to Hasura.
  - Unified Settings UI with direct toggles for **Biometric Auth** and **Security Alerts**.
- **🔔 Notifications & Reminders**:
  - **Local Push Notifications**: Automated background scheduling for daily vasool reminders at 8:00 AM using `flutter_local_notifications` and `timezone`.
- **💰 Collections & Loan Management (Vasool)**:
  - Record daily payments, assign new loans, and view active/completed loan progress.
  - **Dynamic Line Types**: Manage line categories natively via Hasura dynamic tables instead of hardcoded enumerations.
  - Interactive calculator modal to compute loan schedules on the fly.
  - Timeline-style daily summaries and card metrics on the main dashboard.
  - **Multiple Active Loans**: Automatically calculates and allocates daily payments to explicitly assigned loans, supporting customers with multiple overlapping loans.
  - **Soft Delete Architecture**: Powered by Hasura SQL triggers, deleted payments instantly revert loan balances while preserving ledger integrity and hiding records from the UI.
- **💬 SMS & WhatsApp Template Integration**:
  - Persists English and Tamil templates locally using SharedPreferences.
  - Standalone `SmsService` formats customized collection templates replacing tags like `{CustomerName}` and `{AmountPaidToday}` dynamically.
  - Automatically triggers intent prompts (WhatsApp/SMS link launchers) when collections are saved as paid.
  - Features an inline mobile number editor inside the confirmation prompt to correct numbers before sending.
- **📥 CSV Export & Import**:
  - **Line Export**: Query active lines from Hasura and export customer balances, transactions, and installments to standard CSV sheets.
  - **Line Import**: Parse selected CSV templates placed in the device's Documents/Downloads directory to batch insert customer details, active loans, and collections.
  - **Sample Template**: Generates sample import templates to guide bulk data entry.
- **📊 19 Dynamic Reports**:
  - Comprehensive reporting engines mapped to the live GraphQL backend, including Ledger Reports, Daily Summaries, Online Collections, Bad Loans, and Non-Performing Loans.
- **🎨 Theme, Localization & UI Integration**:
  - Multi-language localization (English, Tamil, Hindi) dynamically updates entire app interface instantly.
  - Theming engine dynamically adjusts colors (Blue, Green, Orange, etc.) matching user preferences.
  - Complete dark mode support with tailored contrast variables.

---

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **Architecture**: Clean Architecture (Feature-based: Auth, Collections, Customers, Expenses, Home, Reports, Settings)
- **Backend API**: Hasura GraphQL Engine (PostgreSQL)
- **State Management**: flutter_bloc (BLoC Pattern)
- **Dependency Injection**: GetIt (Service Locator)
- **Local Storage**: SharedPreferences & SQLite (Local cache services)
- **File Processing**: path_provider & local CSV serialization helpers

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Hasura GraphQL Server (with the schema tables tracked)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd vasooldrive
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   Update your API configurations and JWT Secret strings in `injection_container.dart` and `auth_remote_datasource.dart` to match your Hasura endpoint.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔒 Database Real-time Triggers
To ensure automated real-time loan progress and status changes (e.g. updating outstanding balance when a collection is added/updated/deleted), make sure the PostgreSQL trigger function in `database_triggers.md` is registered in your Hasura Console's SQL tab.
