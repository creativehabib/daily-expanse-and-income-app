# Daily Expense & Income Tracker (Flutter, Offline-First for Bangladesh)

এই প্রোজেক্টটি বাংলাদেশি ইউজারদের জন্য **দৈনন্দিন খরচ ও মাসিক আয়-ব্যয়** ট্র্যাক করার একটি Flutter অ্যাপের **রানযোগ্য (runnable) স্টার্টার কোড + পূর্ণ ব্যাখ্যা**। সব ব্যাখ্যা বাংলায়, কোড কমেন্ট ইংরেজিতে।

---

## 1️⃣ Features (Must-have + Future-ready)

### ✅ Must-have (MVP)
- Daily expense add
- Income add
- Category-wise expense tracking
- Default categories: **Food, Transport, Rent, Shopping, Bills, Salary, Others**
- Custom category add/edit/delete
- Today / This Month summary
- Monthly total income & expense
- Remaining balance calculation
- Bangladeshi currency (৳ BDT)
- Offline-first (no login required)

### 🚀 Advanced / Premium-ready
- Monthly budget set (total + category wise)
- Category wise expense report
- Monthly report screen
- Pie chart (category share)
- Simple bar chart (monthly expense)
- Dark mode
- Data export (CSV) – optional
- Backup/Restore – optional

---

## 2️⃣ Tech Stack (Final Decision)

- **Flutter (latest stable)**
- **State management:** Riverpod
- **Local database:** **Hive (chosen)**
- **Chart library:** fl_chart
- **Routing:** go_router
- **UI:** Material 3

### ✅ কেন Hive বেছে নেওয়া হলো (Isar vs Hive)
- **Offline-first এবং lightweight**: ছোট থেকে মাঝারি ডেটার জন্য দ্রুত এবং সিম্পল।
- **Setup সহজ**: code generation ছাড়াই দ্রুত চালু করা যায়।
- **Flutter web ছাড়া মোবাইল ফোকাসড** অ্যাপের জন্য যথেষ্ট।
- **Future scope**: বড় ডেটা/complex query দরকার হলে Isar এ আপগ্রেড করা যাবে।

> **Note:** Firebase ব্যবহার করা হয়নি (future scope হিসেবে রাখলাম)।

---

## 3️⃣ Data Models (Flutter class + Example Map/JSON)

### ✅ Category Model
**Flutter class (same as `lib/domain/models/category.dart`):**
```dart
class Category {
  final String id;
  final String name;
  final String type; // income / expense / both
  final int icon;
  final int color;
  final bool isDefault;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```
**Example Map/JSON:**
```json
{
  "id": "cat_1",
  "name": "Food",
  "type": "expense",
  "icon": 58248,
  "color": 4283215696,
  "isDefault": true,
  "createdAt": "2024-07-01T10:00:00.000Z"
}
```

---

### ✅ Transaction Model
**Flutter class (same as `lib/domain/models/transaction_entry.dart`):**
```dart
class TransactionEntry {
  final String id;
  final String type; // income / expense
  final double amount;
  final String categoryId;
  final String note;
  final DateTime date;
  final String? paymentMethod;
  final DateTime createdAt;

  const TransactionEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```
**Example Map/JSON:**
```json
{
  "id": "txn_1",
  "type": "expense",
  "amount": 250.0,
  "categoryId": "cat_1",
  "note": "Lunch",
  "date": "2024-07-10T12:30:00.000Z",
  "createdAt": "2024-07-10T12:30:00.000Z"
}
```

---

### ✅ Budget Model
**Flutter class (same as `lib/domain/models/budget.dart`):**
```dart
class Budget {
  final String id;
  final int month;
  final int year;
  final double totalBudget;
  final Map<String, double> categoryBudgets;

  const Budget({
    required this.id,
    required this.month,
    required this.year,
    required this.totalBudget,
    required this.categoryBudgets,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'totalBudget': totalBudget,
      'categoryBudgets': categoryBudgets,
    };
  }
}
```
**Example Map/JSON:**
```json
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

---

### ✅ Settings Model
**Flutter class (same as `lib/domain/models/app_settings.dart`):**
```dart
class AppSettings {
  final String currency; // BDT
  final String theme; // system / light / dark
  final String startOfWeek; // sat

  const AppSettings({
    required this.currency,
    required this.theme,
    required this.startOfWeek,
  });

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'theme': theme,
      'startOfWeek': startOfWeek,
    };
  }
}
```
**Example Map/JSON:**
```json
{
  "currency": "BDT",
  "theme": "system",
  "startOfWeek": "sat"
}
```

---

## 4️⃣ Screens & UI Layout (Widget List)

### 1. Home Dashboard
- AppBar (title + actions)
- Balance summary card
- Today expense card
- This month income/expense cards
- Recent transactions list (ListView)
- FAB → Add transaction

### 2. Add Transaction (Bottom Sheet)
- Segmented control (Income / Expense)
- Amount TextField
- Category selector (Dropdown/Menu)
- Date picker
- Note TextField
- Save button (ElevatedButton)

### 3. Categories Screen
- Category list (ListView)
- Add/Edit/Delete actions
- Default categories locked indicator

### 4. Monthly Budget Screen
- Current month budget card
- Total budget input
- Category budget list (optional)
- Save button

### 5. Reports Screen
- Pie chart (category share)
- Monthly income vs expense bar chart
- Summary list

### 6. Settings Screen
- Theme selector (System/Light/Dark)
- Currency display (BDT)
- Start of week dropdown
- App info

---

## 5️⃣ App Architecture

- **Clean Architecture (simplified)**
- **Folder structure:**
```
lib/
 ├─ core/          // routing, theme
 ├─ data/          // hive storage + repositories
 ├─ domain/        // models + calculations
 ├─ presentation/  // screens + providers
 ├─ app.dart
 ├─ main.dart
```
- **Repository Pattern + Riverpod providers**
- **go_router** for navigation

---

## 6️⃣ Full Working Starter Code (Mandatory)

> এই রিপোজিটরিতে থাকা কোড **Copy-Paste করে run করা যাবে**। নিচে প্রয়োজনীয় অংশগুলো একসাথে দেওয়া হলো।

### ✅ `pubspec.yaml`
```yaml
name: daily_expanse_and_income_app
version: 1.0.0+1

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  intl: ^0.19.0
  fl_chart: ^0.68.0
  uuid: ^4.4.0
```

### ✅ `lib/main.dart`
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  final categoryRepository = CategoryRepository();
  final transactionRepository = TransactionRepository();
  await categoryRepository.seedDefaultCategories();
  await transactionRepository.seedSampleTransactions();

  runApp(const ProviderScope(child: ExpenseApp()));
}
```

### ✅ Theme (Material 3)
```dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      );

  static ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
```

### ✅ Router (go_router)
```dart
class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
      GoRoute(path: '/budget', builder: (context, state) => const BudgetScreen()),
      GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
}
```

### ✅ Hive Setup
```dart
class HiveService {
  static const String categoryBox = 'categories';
  static const String transactionBox = 'transactions';
  static const String budgetBox = 'budgets';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(categoryBox);
    await Hive.openBox<Map>(transactionBox);
    await Hive.openBox<Map>(budgetBox);
    await Hive.openBox<Map>(settingsBox);
  }
}
```

### ✅ Repository CRUD (Transaction উদাহরণ)
```dart
class TransactionRepository {
  final Box<Map> _box = Hive.box<Map>(HiveService.transactionBox);
  final Uuid _uuid = const Uuid();

  List<TransactionEntry> getAll() => _box.values
      .map((value) => TransactionEntry.fromMap(Map<String, dynamic>.from(value)))
      .toList();

  Future<void> add(TransactionEntry entry) async => _box.put(entry.id, entry.toMap());
  Future<void> update(TransactionEntry entry) async => _box.put(entry.id, entry.toMap());
  Future<void> remove(String id) async => _box.delete(id);
}
```

---

## 7️⃣ Business Logic (Code Examples)

```dart
// daily expense calculation
static double dailyTotalExpense(List<TransactionEntry> entries, DateTime day) {
  return entries
      .where((entry) => entry.type == 'expense')
      .where((entry) => _isSameDay(entry.date, day))
      .fold(0, (sum, entry) => sum + entry.amount);
}

// monthly income total
static double monthlyTotal(List<TransactionEntry> entries, int month, int year, String type) {
  return entries
      .where((entry) => entry.type == type)
      .where((entry) => entry.date.month == month && entry.date.year == year)
      .fold(0, (sum, entry) => sum + entry.amount);
}

// remaining balance
static double remainingBudget({required double totalBudget, required double totalExpense}) {
  return totalBudget - totalExpense;
}
```

---

## 8️⃣ UX & Quality Guidelines

- **Empty state UI**: যদি কোনো ডাটা না থাকে, placeholder card দেখানো হবে।
- **Validation**: amount + category required।
- **Loading state**: data fetch হলে loader দেখানো হবে।
- **Error handling**: basic try/catch + user feedback।
- **Performance tips**: lazy list, Hive indexed keys, minimal rebuilds।

---

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

**Note:** এই স্টার্টার কোড future-ready, Firebase sync বা analytics পরে সহজে যোগ করা যাবে।
