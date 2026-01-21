# Daily Expense + Monthly Expense + Income/Expense Tracker (Flutter)

নিচে প্রোডাকশন-রেডি স্টার্টার প্ল্যান + পূর্ণ কোড স্ট্রাকচার দেওয়া হলো। সব ব্যাখ্যা বাংলায়, আর কোড কমেন্ট ইংরেজিতে।

## 1) App Features

### MVP Features
- Daily expense entry (দৈনিক খরচ এন্ট্রি)
- Income entry (আয় এন্ট্রি)
- Category management (ডিফল্ট + কাস্টম ক্যাটাগরি)
- Monthly budget সেট করা (overall)
- Summary dashboard: Today / This Month
- Category-wise breakdown (basic report list)
- Dark mode (Material 3)
- Local data storage (offline first)
- Basic validation + empty state UI

### Premium/Optional Features
- Weekly/Custom date range summary
- Category-wise budget
- Reports: charts (monthly trend, income vs expense)
- CSV/PDF Export
- Backup/Restore (Local + Firebase)
- Multi-currency formatting
- Cloud sync (Firebase)

## 2) Tech Stack (দুইটি অপশন)

### Option A: Local-first
**Flutter + Riverpod + Hive (Local DB)**
- কেন ভালো: Offline-first, দ্রুত, কম খরচ, ছোট অ্যাপের জন্য সহজ।
- Practical: ডেটা লোকালেই সেভ হবে, ডিভাইস-লেভেল পারফরম্যান্স ভালো।

### Option B: Cloud Sync
**Flutter + Riverpod + Firebase Auth + Firestore**
- কেন ভালো: Multi-device sync, backup, remote analytics, easy auth।
- Practical: লগইন দরকার, ইন্টারনেট নির্ভর, খরচ বাড়তে পারে।

**Recommendation:** MVP/Starter এর জন্য Option A সবচেয়ে দ্রুত এবং কম জটিল। পরে চাইলে Option B তে আপগ্রেড করা যাবে।

## 3) Data Model / Schema (উদাহরণ JSON/Map)

### Category
```
{
  "id": "cat_1",
  "name": "Groceries",
  "type": "expense", 
  "icon": 58248,
  "color": 4283215696,
  "isDefault": true,
  "createdAt": "2024-07-01T10:00:00.000Z"
}
```

### Transaction
```
{
  "id": "txn_1",
  "type": "expense",
  "amount": 250.0,
  "categoryId": "cat_1",
  "note": "Lunch",
  "date": "2024-07-10T12:30:00.000Z",
  "paymentMethod": "Cash",
  "createdAt": "2024-07-10T12:30:00.000Z"
}
```

### Budget
```
{
  "id": "budget_2024_07",
  "month": 7,
  "year": 2024,
  "totalBudget": 20000.0,
  "categoryBudgets": {
    "cat_1": 5000.0
  }
}
```

### Settings
```
{
  "currency": "BDT",
  "theme": "system",
  "startOfWeek": "sat"
}
```

## 4) UI/UX Screen List + Wireframe-style Layout

### Onboarding (optional)
- AppBar (skip)
- 2–3 cards: “Track expense”, “Set budget”, “See reports”
- CTA: Get Started

### Home Dashboard
- AppBar (title + settings + reports icon)
- Summary cards: Today expense, This month income/expense
- Recent transactions list
- FAB: Add Transaction
- Quick actions: Categories, Budget

### Add Transaction (Bottom Sheet)
- Segmented button: Expense/Income
- Amount input
- Category dropdown
- Note input
- Save button

### Categories (Manage)
- Form: name + type + save
- List of categories (default locked)

### Monthly Budget
- Current budget text
- Input: total budget
- Save budget button

### Reports/Analytics
- Top categories list (placeholder for chart)
- Monthly trend placeholder

### Settings
- Currency, Theme, Start-of-week dropdowns
- Save button

## 5) Navigation + App Architecture

**Folder structure (clean-ish):**
```
lib/
  core/
    routing/
    theme/
  data/
    local/
    repositories/
  domain/
    models/
    utils/
  presentation/
    providers/
    screens/
  main.dart
  app.dart
```

**Layers:**
- presentation: UI + state
- domain: models + business logic
- data: DB/repositories

**State management:** Riverpod (StateNotifier + providers)
**Routing:** go_router

## 6) Full Working Code Starter

> এই রিপোজিটরিতেই সম্পূর্ণ runnable starter code আছে।

### Dependencies (pubspec.yaml)
- flutter_riverpod
- go_router
- hive + hive_flutter
- intl
- uuid

### Main Flow
- `HiveService.init()` → লোকাল DB প্রস্তুত
- default categories seed
- sample transactions seed
- `ExpenseApp` boot

### CRUD Support
- Transaction: add/update/delete
- Category: add/update/delete
- Budget: upsert

### Summary Functions
- daily total expense
- monthly income/expense
- category totals
- budget remaining
- date range filter

## 7) Business Logic (উদাহরণ ফাংশন)

- Daily expense total
- Monthly total (income/expense)
- Category-wise totals
- Remaining budget
- Date range filter

সব ফাংশন `transaction_calculations.dart` এ দেওয়া আছে।

## 8) Extras
- Sample data seed (first run)
- Validation rules (amount/name required)
- Empty state cards
- Error handling (basic)
- Performance tips: pagination, lazy list, caching providers

## Run Instructions

```bash
flutter pub get
flutter run
```

APK build:
```bash
flutter build apk --release
```

---

**Note:** এই স্টার্টার কোড production-ready structure অনুসরণ করে। পরবর্তীতে Firebase sync/analytics/export যুক্ত করা সহজ হবে।
