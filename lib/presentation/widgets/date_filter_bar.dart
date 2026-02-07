import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/date_filter_provider.dart';

class DateFilterBar extends ConsumerWidget {
  const DateFilterBar({super.key, this.title = 'Date Range'});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dateRangeProvider);
    final notifier = ref.read(dateRangeProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in _presetOptions)
              ChoiceChip(
                label: Text(_labelForPreset(preset)),
                selected: filter.preset == preset,
                onSelected: (_) => notifier.setPreset(preset),
              ),
            _CustomRangeButton(
              isSelected: filter.preset == DateRangePreset.custom,
              onPressed: () => _pickCustomRange(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _rangeLabel(filter),
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final filter = ref.read(dateRangeProvider);
    final notifier = ref.read(dateRangeProvider.notifier);
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: filter.range,
    );

    if (picked != null) {
      notifier.setCustomRange(picked);
    }
  }
}

class _CustomRangeButton extends StatelessWidget {
  const _CustomRangeButton({
    required this.isSelected,
    required this.onPressed,
  });

  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const FaIcon(FontAwesomeIcons.calendarDays, size: 16),
      label: const Text('Custom'),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF0F766E) : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
    );
  }
}

String _labelForPreset(DateRangePreset preset) {
  switch (preset) {
    case DateRangePreset.allTime:
      return 'All Time';
    case DateRangePreset.thisWeek:
      return 'This Week';
    case DateRangePreset.thisMonth:
      return 'This Month';
    case DateRangePreset.lastMonth:
      return 'Last Month';
    case DateRangePreset.thisYear:
      return 'This Year';
    case DateRangePreset.custom:
      return 'Custom';
  }
}

String _rangeLabel(DateRangeState filter) {
  if (filter.range == null) {
    return 'Showing all transactions.';
  }

  final formatter = DateFormat.yMMMd();
  return '${formatter.format(filter.range!.start)} - '
      '${formatter.format(filter.range!.end)}';
}

const _presetOptions = [
  DateRangePreset.allTime,
  DateRangePreset.thisWeek,
  DateRangePreset.thisMonth,
  DateRangePreset.lastMonth,
  DateRangePreset.thisYear,
];
