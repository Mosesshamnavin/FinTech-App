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
- [x] **Site Dashboard Polish**: Replaced duplicate table views with a grid of cards in `site_dashboard_summary_page.dart`.
- [x] **Clean-up**: Removed obsolete report use cases and consolidated imports.

### 🎨 UI & Navigation
- [x] **Hide Bottom Navigation**: Conditionally render the bottom navigation shell in `home_shell_page.dart` (hides automatically on sub-pages).

---

## 📋 Pending Tasks (Todo)

### 💬 SMS & WhatsApp Templates
- [ ] **Templates Persistence**: Save English and Tamil templates to storage in `sms_template_page.dart`.
- [ ] **Dynamic Message Composer**: Format WhatsApp and SMS text with dynamic placeholders in `sms_service.dart`.
- [ ] **Send Trigger**: Automatically open WhatsApp/SMS with template text when saving payments in `add_collection_modal.dart`.

### 📥 Export & Import Line Data
- [ ] **Line Export (CSV)**: Export customer balances and loan records to CSV sheets in `export_line_page.dart`.
- [ ] **Line Import (CSV)**: Scan Documents folder and batch import CSV lists in `import_line_page.dart`.
- [ ] **Download Sample CSV**: Generate sample CSV file structure for user guide in `import_line_page.dart`.

### 🔒 Security & Auth Settings
- [ ] **Change Password**: Connect old/new password update mutation in `change_password_page.dart`.
- [ ] **Fingerprint Toggles**: Save settings state to preferences in `enable_fingerprint_page.dart`.
- [ ] **Security Alert**: Save OTP trigger flag locally in `enable_security_alert_page.dart`.

### ⚙️ Preference Persistence (My Settings)
- [ ] **Save Preferences**: Wire My Settings switches to read/write state in local storage `my_settings_page.dart`.
