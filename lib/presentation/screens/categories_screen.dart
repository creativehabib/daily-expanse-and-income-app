import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/category.dart';
import '../providers/providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _type = 'expense';
  late _CategoryIconOption _selectedIcon;

  static const List<_CategoryIconOption> _iconOptions = [
    _CategoryIconOption('Food', FontAwesomeIcons.utensils),
    _CategoryIconOption('Transport', FontAwesomeIcons.bus),
    _CategoryIconOption('Home', FontAwesomeIcons.house),
    _CategoryIconOption('Shopping', FontAwesomeIcons.cartShopping),
    _CategoryIconOption('Bills', FontAwesomeIcons.fileInvoiceDollar),
    _CategoryIconOption('Salary', FontAwesomeIcons.wallet),
    _CategoryIconOption('Health', FontAwesomeIcons.heartPulse),
    _CategoryIconOption('Education', FontAwesomeIcons.graduationCap),
    _CategoryIconOption('Travel', FontAwesomeIcons.plane),
    _CategoryIconOption('Gift', FontAwesomeIcons.gift),
    _CategoryIconOption('Others', FontAwesomeIcons.shapes),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = _iconOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteCategory(Category category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Delete "${category.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await ref.read(categoriesProvider.notifier).remove(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () => context.go('/'),
          tooltip: 'Back',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Add New Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'both', child: Text('Both')),
                  ],
                  onChanged: (value) => setState(() => _type = value ?? 'expense'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<_CategoryIconOption>(
                  value: _selectedIcon,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  items: _iconOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Row(
                            children: [
                              FaIcon(option.icon, size: 16),
                              const SizedBox(width: 8),
                              Text(option.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _selectedIcon = value);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        return;
                      }

                      final newCategory = Category(
                        id: const Uuid().v4(),
                        name: _nameController.text,
                        type: _type,
                        icon: _selectedIcon.icon.codePoint,
                        iconFamily: _selectedIcon.icon.fontFamily,
                        iconPackage: _selectedIcon.icon.fontPackage,
                        color: Theme.of(context).colorScheme.primary.value,
                        isDefault: false,
                        createdAt: DateTime.now(),
                      );

                      await ref.read(categoriesProvider.notifier).add(newCategory);
                      _nameController.clear();
                    },
                    child: const Text('Save Category'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('All Categories', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (categories.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No categories yet.'),
              ),
            )
          else
            ...categories.map(
              (category) => ListTile(
                leading: CircleAvatar(child: Icon(category.iconData)),
                title: Text(category.name),
                subtitle: Text(category.type),
                trailing: category.isDefault
                    ? const FaIcon(FontAwesomeIcons.lock)
                    : IconButton(
                        icon: const FaIcon(FontAwesomeIcons.trash),
                        onPressed: () => _confirmDeleteCategory(category),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryIconOption {
  const _CategoryIconOption(this.label, this.icon);

  final String label;
  final IconData icon;
}
