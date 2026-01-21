import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                        icon: Icons.category.codePoint,
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
                leading: CircleAvatar(child: Icon(IconData(category.icon, fontFamily: 'MaterialIcons'))),
                title: Text(category.name),
                subtitle: Text(category.type),
                trailing: category.isDefault
                    ? const Icon(Icons.lock_outline)
                    : IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(categoriesProvider.notifier)
                            .remove(category.id),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
