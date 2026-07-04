# 📋 Vasool Drive: Project Todo & Progress Report

This document tracks completed achievements and pending todo tasks for the project.

---

## ✅ Completed Tasks

### 📊 Reports & Database Alignments
- [x] **Hasura GraphQL Wiring**: Integrated queries for all 19 reports in `hasura_report_remote_datasource.dart`.
- [x] **Schema Error Fixes**: Resolved critical validation errors:
  - Removed `is_active` check from customer queries (not supported by DB).
  - Changed completed loan query filters from `updated_at` to `end_date` (matches DB columns).
  - Switched `note` parameters to `comments` for expenses and investments.
  - Resolved `expense_type` and `investment_type` schema errors in Expense & Investment Summary reports by using client-side name resolution.
  - Fixed `collections` nested field filter error in Missing Customer Summary report by using local set difference computation.
- [x] **Site Dashboard Polish**: Replaced duplicate table views with a grid of cards in `site_dashboard_summary_page.dart`.
- [x] **Clean-up**: Removed obsolete report use cases and consolidated imports.

### 🎨 UI & Navigation
- [x] **Hide Bottom Navigation**: Conditionally render the bottom navigation shell in `home_shell_page.dart` (hides automatically on sub-pages).
- [x] **Theme & Color Theory Integration**: Connected app colors globally to `ThemeData` to automatically match chosen themes (Blue, Green, Orange, etc.).
- [x] **Dark Mode Text Visibility**: Fixed visibility of dropdowns, forms, templates, and report tables in dark mode themes.

### ⚙️ Preference Persistence (My Settings)
- [x] **Save Preferences**: Wired My Settings switches, dropdowns, and form fields to read/write state in local storage via `StorageService`. Theme is also persisted on hot refresh.

---

### 💳 Customer Profile & Payment History
- [x] **Payment Timeline**: Render a timeline listing all collections for a customer in `customer_detail_page.dart`.
- [x] **Share Receipt**: Format and send payment receipts directly to customers via WhatsApp in `customer_detail_page.dart`.
- [x] **Delete Payment**: Implement delete mutation in Hasura to remove invalid payment records (Soft delete) and automatically recalculate loan balances.

### 💬 SMS & WhatsApp Templates
- [x] **Templates Persistence**: Save English and Tamil templates to storage in `sms_template_page.dart`.
- [x] **Dynamic Message Composer**: Format WhatsApp and SMS text with dynamic placeholders in `sms_service.dart`.
- [x] **Send Trigger**: Automatically open WhatsApp/SMS with template text when saving payments in `add_collection_modal.dart`.

### 📥 Export & Import Line Data
- [x] **Line Export (CSV)**: Export customer balances and loan records to CSV sheets in `export_line_page.dart`.
- [x] **Line Import (CSV)**: Scan Documents folder and batch import CSV lists in `import_line_page.dart`.
- [x] **Download Sample CSV**: Generate sample CSV file structure for user guide in `import_line_page.dart`.

### 🔒 Security & Auth Settings
- [x] **Change Password**: Connect old/new password update mutation in `change_password_page.dart`.
- [x] **Fingerprint Toggles**: Save settings state to preferences in `enable_fingerprint_page.dart`.
- [x] **Security Alert**: Save OTP trigger flag locally in `enable_security_alert_page.dart`.

### ⚙️ Language & License Settings
- [x] **Wire Language & Custom SMS Labels**: Persist app language selection and customized SMS label fields in `language_settings_page.dart`.
- [x] **Functional License Intents & Trial Expiration**: Wire CALL/PAY buttons and compute 30-day dynamic trial expiry in `license_page.dart`.

### 💳 Collection & Loan Payments Selector
- [x] **Loan Selection Dropdown**: Render a selector for target active loans during collection payments in `add_collection_modal.dart`.

