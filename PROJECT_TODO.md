# 📋 Vasool Drive: Project Todo & Progress Report

This document tracks completed achievements and pending todo tasks for the project.

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
- [x] **Delete Payment (Voiding)**: Wire the UI button in `customer_detail_page.dart` to dispatch the delete event to Hasura, including passing correct `loanId` and `amount` for triggers.
- [x] **Profile Data Sync**: Fetch and locally cache user `mobile` and `email` on login, ensuring the "My Settings" page displays real data rather than hardcoded dummies.
- [x] **Loan Partial Updates**: Modified `hasura_loan_remote_datasource.dart` to support partial updates (outstanding balances) without requiring unrelated fields (customerId, interest, etc.).

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
- [x] **Pending Balance Display**: Updated the dropdown to clearly display the remaining pending balance of a loan to prevent over-collection.
- [x] **Precise Collection Allocation**: Updated Hasura SQL triggers to respect explicitly selected `loan_id` assignments when customers have multiple active loans.
- [x] **Chronological Timeline**: Fixed GraphQL query sorting in the timeline to accurately order multiple same-day payments by exact timestamp.

### 🔔 Notifications & Dynamic Data (Recent Work)
- [x] **Local Notifications (Reminders)**: Integrated `flutter_local_notifications` and `timezone` to automatically schedule background push notifications at 8:00 AM on the dates chosen in the Add Reminder modal.
- [x] **Dynamic Line Types**: Replaced hardcoded line types with a dynamic Hasura `line_types` table. Built full CRUD UI in `line_type_page.dart` and wired it into the Add Line dropdown.
- [x] **Settings Page Streamlining**: Replaced redundant sub-pages for `Enable Fingerprint` and `Enable Security Alert` with clean, direct toggle switches directly on the main Settings page.

---

## ⏳ Pending Tasks
- [ ] **Email OTP Integration**: (On Hold) Connect Resend/SendGrid for Forgot Password and Security Alerts (waiting on team discussion).
- [ ] **Transparent Notification Icon**: (Visual Polish) User to provide a transparent white PNG logo (`ic_notification.png`) to fix the default grey Android box.
- [ ] **Firebase Push Notifications**: (Optional) Integrate FCM if remote server-triggered announcements are needed.
- [ ] **Final QA & Bug Fixes**: Test all edge cases before release.
