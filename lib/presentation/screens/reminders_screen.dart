import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final List<String> _frequencies = const [
    'Once',
    'Daily',
    'Every 2 weeks',
    'Every 4 weeks',
    'Monthly',
    'Every 2 months',
    'Every quarter',
    'Every 6 months',
    'Every year',
  ];
  late String _selectedFrequency;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _commentEnabled = false;
  final List<_Reminder> _reminders = [];
  bool _showForm = false;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _selectedFrequency = _frequencies.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formattedDate() {
    return DateFormat.yMMMd().format(_selectedDate);
  }

  String _formattedTime(BuildContext context) {
    return _selectedTime.format(context);
  }

  void _saveReminder() {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reminder name')),
      );
      return;
    }

    final isEditing = _editingIndex != null;
    final reminder = _Reminder(
      name: name,
      frequency: _selectedFrequency,
      date: _selectedDate,
      time: _selectedTime,
      comment: _commentEnabled ? _commentController.text.trim() : '',
    );

    setState(() {
      if (!isEditing) {
        _reminders.insert(0, reminder);
      } else {
        _reminders[_editingIndex!] = reminder;
      }
      _resetFormState();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'Reminder updated' : 'Reminder saved',
        ),
      ),
    );
  }

  void _resetFormState() {
    _nameController.clear();
    _commentController.clear();
    _commentEnabled = false;
    _selectedFrequency = _frequencies.first;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _editingIndex = null;
    _showForm = false;
  }

  void _startCreate() {
    setState(() {
      _editingIndex = null;
      _showForm = true;
      _nameController.clear();
      _commentController.clear();
      _commentEnabled = false;
      _selectedFrequency = _frequencies.first;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
  }

  void _editReminder(int index) {
    final reminder = _reminders[index];
    setState(() {
      _editingIndex = index;
      _showForm = true;
      _nameController.text = reminder.name;
      _selectedFrequency = reminder.frequency;
      _selectedDate = reminder.date;
      _selectedTime = reminder.time;
      _commentEnabled = reminder.comment.isNotEmpty;
      _commentController.text = reminder.comment;
    });
  }

  void _deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved reminders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              FilledButton.icon(
                onPressed: _startCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_showForm)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _editingIndex == null
                          ? 'Create a reminder'
                          : 'Edit reminder',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Reminder name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Reminder frequency',
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFrequency,
                          isExpanded: true,
                          items: _frequencies
                              .map(
                                (frequency) => DropdownMenuItem(
                                  value: frequency,
                                  child: Text(frequency),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedFrequency = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: const OutlineInputBorder(),
                              suffixIcon:
                                  const Icon(Icons.calendar_today_outlined),
                              hintText: _formattedDate(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: _pickTime,
                            decoration: InputDecoration(
                              labelText: 'Time',
                              border: const OutlineInputBorder(),
                              suffixIcon:
                                  const Icon(Icons.access_time_outlined),
                              hintText: _formattedTime(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _commentEnabled,
                      onChanged: (value) {
                        setState(() {
                          _commentEnabled = value;
                          if (!value) {
                            _commentController.clear();
                          }
                        });
                      },
                      title: const Text('Comment option'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      enabled: _commentEnabled,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Comment',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _saveReminder,
                            icon:
                                const Icon(Icons.notifications_active_outlined),
                            label: Text(
                              _editingIndex == null
                                  ? 'Save reminder'
                                  : 'Update reminder',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _resetFormState();
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          if (_reminders.isEmpty)
            const Text('No reminders yet.')
          else
            ...List.generate(_reminders.length, (index) {
              final reminder = _reminders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(reminder.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder.frequency),
                      Text(
                        '${DateFormat.yMMMd().format(reminder.date)} · '
                        '${reminder.time.format(context)}',
                      ),
                      if (reminder.comment.isNotEmpty)
                        Text(reminder.comment),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editReminder(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteReminder(index),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _Reminder {
  _Reminder({
    required this.name,
    required this.frequency,
    required this.date,
    required this.time,
    required this.comment,
  });

  final String name;
  final String frequency;
  final DateTime date;
  final TimeOfDay time;
  final String comment;
}
