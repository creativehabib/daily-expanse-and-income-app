import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Assuming these exist in your project structure
import '../../domain/models/transaction_entry.dart';
import '../providers/providers.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String? _categoryId;

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final settings = ref.watch(settingsProvider);
    final currencySymbol = _currencySymbol(settings.currency);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Transaction', style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() => _type = value.first);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: currencySymbol.isEmpty ? null : '$currencySymbol ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.calculate, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    tooltip: 'Calculator',
                    onPressed: () => _openCalculator(context),
                  ),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                if (double.tryParse(value) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: categories
                  .where((category) => category.type == _type || category.type == 'both')
                  .map((category) => DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _categoryId = value),
              validator: (value) => value == null ? 'Please select category' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;

                  final entry = TransactionEntry(
                    id: const Uuid().v4(),
                    type: _type,
                    amount: double.parse(_amountController.text),
                    categoryId: _categoryId!,
                    note: _noteController.text,
                    date: DateTime.now(),
                    paymentMethod: null,
                    createdAt: DateTime.now(),
                  );

                  await ref.read(transactionsProvider.notifier).add(entry);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Transaction'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _openCalculator(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => _CalculatorSheet(initialValue: _amountController.text),
    );
    if (result != null) {
      _amountController.text = _formatNumber(result);
      _amountFocusNode.requestFocus();
    }
  }
}

// -----------------------------------------------------------------------------
// PREMIUM CALCULATOR UI
// -----------------------------------------------------------------------------

class _CalculatorSheet extends StatefulWidget {
  const _CalculatorSheet({required this.initialValue});

  final String initialValue;

  @override
  State<_CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<_CalculatorSheet> {
  late String _expression;
  String _liveResult = '';

  @override
  void initState() {
    super.initState();
    _expression = widget.initialValue.trim();
    if (_expression.isEmpty) _expression = '0';
    _updateLiveResult();
  }

  void _updateLiveResult() {
    if (_expression.isEmpty || _expression == '0') {
      setState(() => _liveResult = '');
      return;
    }
    // Don't calculate if the last char is an operator
    if ('+-×÷.'.contains(_expression[_expression.length - 1])) {
      return;
    }

    final val = _evaluateExpression(_expression);
    if (val != null) {
      setState(() => _liveResult = _formatNumber(val));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 360 || size.height < 700;
    final rowSpacing = isCompact ? 8.0 : 12.0;
    final keypadPadding = isCompact ? 12.0 : 16.0;

    final expressionFontSize = (theme.textTheme.displaySmall?.fontSize ?? 34) * (isCompact ? 0.85 : 1);
    final resultFontSize = (theme.textTheme.headlineSmall?.fontSize ?? 24) * (isCompact ? 0.9 : 1);

    return Container(
      height: size.height * 0.75, // Occupy 75% of screen
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Display Area
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 16 : 24,
                vertical: isCompact ? 12 : 16,
              ),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // The equation text
                  Text(
                    _expression,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                      fontSize: expressionFontSize,
                    ),
                  ),
                  SizedBox(height: isCompact ? 4 : 8),
                  // The live preview text
                  if (_liveResult.isNotEmpty && _liveResult != _expression)
                    Text(
                      '= $_liveResult',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                        fontSize: resultFontSize,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Keypad Area
          Padding(
            padding: EdgeInsets.all(keypadPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final widthBased = (constraints.maxWidth - (rowSpacing * 3)) / 4;
                final heightBased = (constraints.maxHeight - (rowSpacing * 4)) / 5;
                final buttonSize = widthBased < heightBased ? widthBased : heightBased;

                return Column(
                  children: [
                    _buildRow(
                      children: [
                        _buildButton('C', _clear, style: _ButtonStyle.error),
                        _buildButton('⌫', _backspace, style: _ButtonStyle.secondary),
                        _buildButton('%', _percent, style: _ButtonStyle.secondary),
                        _buildButton('÷', () => _append('÷'), style: _ButtonStyle.operator),
                      ],
                      size: buttonSize,
                      spacing: rowSpacing,
                    ),
                    SizedBox(height: rowSpacing),
                    _buildRow(
                      children: [
                        _buildButton('7', () => _append('7')),
                        _buildButton('8', () => _append('8')),
                        _buildButton('9', () => _append('9')),
                        _buildButton('×', () => _append('×'), style: _ButtonStyle.operator),
                      ],
                      size: buttonSize,
                      spacing: rowSpacing,
                    ),
                    SizedBox(height: rowSpacing),
                    _buildRow(
                      children: [
                        _buildButton('4', () => _append('4')),
                        _buildButton('5', () => _append('5')),
                        _buildButton('6', () => _append('6')),
                        _buildButton('-', () => _append('-'), style: _ButtonStyle.operator),
                      ],
                      size: buttonSize,
                      spacing: rowSpacing,
                    ),
                    SizedBox(height: rowSpacing),
                    _buildRow(
                      children: [
                        _buildButton('1', () => _append('1')),
                        _buildButton('2', () => _append('2')),
                        _buildButton('3', () => _append('3')),
                        _buildButton('+', () => _append('+'), style: _ButtonStyle.operator),
                      ],
                      size: buttonSize,
                      spacing: rowSpacing,
                    ),
                    SizedBox(height: rowSpacing),
                    _buildRow(
                      children: [
                        _buildButton('.', () => _append('.')),
                        _buildButton('0', () => _append('0')),
                        // Equal / OK button combo
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(left: rowSpacing),
                            child: FilledButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _submit();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: EdgeInsets.symmetric(vertical: buttonSize / 2.5),
                              ),
                              child: Text(
                                'OK',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      size: buttonSize,
                      spacing: rowSpacing,
                      isLastRow: true,
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildRow({
    required List<Widget> children,
    required double size,
    required double spacing,
    bool isLastRow = false,
  }) {
    // For the last row, we handle spacing differently due to the expanded button
    if (isLastRow) {
      return Row(
        children: children.map((w) {
          if (w is Expanded) return w;
          return Padding(
            padding: EdgeInsets.only(right: spacing),
            child: SizedBox(width: size, height: size, child: w),
          );
        }).toList(),
      );
    }

    return Row(
      children: children.map((w) {
        return Padding(
          padding: EdgeInsets.only(right: w == children.last ? 0 : spacing),
          child: SizedBox(width: size, height: size, child: w),
        );
      }).toList(),
    );
  }

  Widget _buildButton(
      String label,
      VoidCallback onPressed, {
        _ButtonStyle style = _ButtonStyle.standard,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    Color bgColor;
    Color fgColor;

    switch (style) {
      case _ButtonStyle.standard:
        bgColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
        fgColor = colorScheme.onSurface;
        break;
      case _ButtonStyle.secondary:
        bgColor = colorScheme.secondaryContainer;
        fgColor = colorScheme.onSecondaryContainer;
        break;
      case _ButtonStyle.operator:
        bgColor = colorScheme.tertiaryContainer;
        fgColor = colorScheme.onTertiaryContainer;
        break;
      case _ButtonStyle.error:
        bgColor = colorScheme.errorContainer;
        fgColor = colorScheme.onErrorContainer;
        break;
      default:
        bgColor = colorScheme.surface;
        fgColor = colorScheme.onSurface;
    }

    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: fgColor,
            ),
          ),
        ),
      ),
    );
  }

  void _append(String value) {
    setState(() {
      if (_expression == '0' && value != '.') {
        _expression = value;
      } else {
        _expression += value;
      }
      _updateLiveResult();
    });
  }

  void _clear() {
    setState(() {
      _expression = '0';
      _liveResult = '';
    });
  }

  void _backspace() {
    if (_expression.isEmpty || _expression == '0') return;
    setState(() {
      if (_expression.length == 1) {
        _expression = '0';
      } else {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      _updateLiveResult();
    });
  }

  void _percent() {
    final value = _evaluateExpression(_expression);
    if (value == null) return;
    setState(() {
      _expression = _formatNumber(value / 100);
      _updateLiveResult();
    });
  }

  void _submit() {
    final value = _evaluateExpression(_expression);
    if (value == null) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop(value);
  }
}

enum _ButtonStyle { standard, secondary, operator, error }

// -----------------------------------------------------------------------------
// LOGIC UTILS (Kept mostly similar, just robustified)
// -----------------------------------------------------------------------------

String _currencySymbol(String currency) {
  switch (currency) {
    case 'BDT':
      return '৳';
    case 'USD':
      return r'$';
    case 'EUR':
      return '€';
    default:
      return currency;
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  // Remove trailing zeros for decimals
  return value.toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
}

double? _evaluateExpression(String expression) {
  try {
    if (expression.trim().isEmpty) return 0;

    final sanitized = expression.replaceAll('×', '*').replaceAll('÷', '/');
    final tokens = <String>[];
    final buffer = StringBuffer();
    String? previousToken;

    for (var i = 0; i < sanitized.length; i++) {
      final char = sanitized[i];
      if ('0123456789.'.contains(char)) {
        buffer.write(char);
        continue;
      }

      if ('+-*/'.contains(char)) {
        if (buffer.isEmpty && (char == '-') && (previousToken == null || '+-*/'.contains(previousToken!))) {
          buffer.write(char);
          continue;
        }
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(char);
        previousToken = char;
      }
    }

    if (buffer.isNotEmpty) tokens.add(buffer.toString());
    if (tokens.isEmpty) return null;

    final values = <double>[];
    final operators = <String>[];

    for (final token in tokens) {
      if ('+-*/'.contains(token)) {
        while (operators.isNotEmpty && _precedence(operators.last) >= _precedence(token)) {
          final result = _applyOperation(operators.removeLast(), values.removeLast(), values.removeLast());
          if (result == null) return null;
          values.add(result);
        }
        operators.add(token);
      } else {
        final value = double.tryParse(token);
        if (value == null) return null;
        values.add(value);
      }
    }

    while (operators.isNotEmpty) {
      final result = _applyOperation(operators.removeLast(), values.removeLast(), values.removeLast());
      if (result == null) return null;
      values.add(result);
    }

    return values.isEmpty ? null : values.last;
  } catch (e) {
    return null; // Return null on any math errors
  }
}

int _precedence(String operator) {
  if (operator == '*' || operator == '/') return 2;
  return 1;
}

double? _applyOperation(String operator, double b, double a) {
  switch (operator) {
    case '+': return a + b;
    case '-': return a - b;
    case '*': return a * b;
    case '/': return b == 0 ? null : a / b;
  }
  return null;
}
