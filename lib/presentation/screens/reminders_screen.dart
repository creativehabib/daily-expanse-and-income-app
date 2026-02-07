import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../data/local/hive_service.dart';
import '../../services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
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
    _loadReminders();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    _dateController.dispose();
    _timeController.dispose();
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
        _dateController.text = _formattedDate();
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
        _timeController.text = _formattedTime(context);
      });
    }
  }

  String _formattedDate() {
    return DateFormat.yMMMd().format(_selectedDate);
  }

  String _formattedTime(BuildContext context) {
    return _selectedTime.format(context);
  }

  Future<void> _saveReminder() async {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reminder name')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    if (scheduledDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a future time')),
      );
      return;
    }

    final isEditing = _editingIndex != null;
    final existingReminder =
        isEditing ? _reminders[_editingIndex!] : null;
    final reminderId =
        existingReminder?.id ?? NotificationService.instance.generateId();
    final reminder = _Reminder(
      id: reminderId,
      name: name,
      frequency: _selectedFrequency,
      date: _selectedDate,
      time: _selectedTime,
      comment: _commentEnabled ? _commentController.text.trim() : '',
      createdAt: existingReminder?.createdAt ?? DateTime.now(),
    );

    var scheduleFailed = false;
    try {
      await NotificationService.instance.scheduleReminder(
        id: reminderId,
        title: reminder.name,
        body: reminder.comment.isNotEmpty
            ? reminder.comment
            : 'It is time for your reminder.',
        scheduledDateTime: scheduledDateTime,
      );
    } catch (_) {
      scheduleFailed = true;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (!isEditing) {
        _reminders.insert(0, reminder);
      } else {
        _reminders[_editingIndex!] = reminder;
      }
      _resetFormState();
    });
    await _persistReminder(reminder);

    final message = scheduleFailed
        ? 'Reminder saved, but notification could not be scheduled'
        : isEditing
            ? 'Reminder updated'
            : 'Reminder saved';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _resetFormState() {
    _nameController.clear();
    _commentController.clear();
    _dateController.clear();
    _timeController.clear();
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
      _dateController.text = _formattedDate();
      _timeController.text = _formattedTime(context);
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
      _dateController.text = DateFormat.yMMMd().format(reminder.date);
      _timeController.text = reminder.time.format(context);
      _commentEnabled = reminder.comment.isNotEmpty;
      _commentController.text = reminder.comment;
    });
  }

  Future<void> _deleteReminder(int index) async {
    final reminder = _reminders[index];
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('Delete "${reminder.name}"? This cannot be undone.'),
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

    if (shouldDelete != true || !mounted) {
      return;
    }

    setState(() {
      _reminders.removeAt(index);
    });
    await _removeReminder(reminder.id);
    await NotificationService.instance.cancelReminder(reminder.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder deleted')),
    );
  }

  Future<void> _loadReminders() async {
    final box = Hive.box<Map>(HiveService.reminderBox);
    final reminders = box.values
        .map(
          (value) => _Reminder.fromMap(Map<String, dynamic>.from(value)),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (!mounted) {
      return;
    }
    setState(() {
      _reminders
        ..clear()
        ..addAll(reminders);
    });
  }

  Future<void> _persistReminder(_Reminder reminder) async {
    final box = Hive.box<Map>(HiveService.reminderBox);
    await box.put(reminder.id, reminder.toMap());
  }

  Future<void> _removeReminder(int id) async {
    final box = Hive.box<Map>(HiveService.reminderBox);
    await box.delete(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
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
                icon: const FaIcon(FontAwesomeIcons.plus),
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
                            controller: _dateController,
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: const OutlineInputBorder(),
                              suffixIcon: const FaIcon(
                                FontAwesomeIcons.calendarDays,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _timeController,
                            readOnly: true,
                            onTap: _pickTime,
                            decoration: InputDecoration(
                              labelText: 'Time',
                              border: const OutlineInputBorder(),
                              suffixIcon:
                                  const FaIcon(FontAwesomeIcons.clock, size: 16),
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
                            icon: const FaIcon(FontAwesomeIcons.bell),
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
                  leading: const FaIcon(FontAwesomeIcons.bell),
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
                        icon: const FaIcon(FontAwesomeIcons.penToSquare),
                        onPressed: () => _editReminder(index),
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.trash),
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
    required this.id,
    required this.name,
    required this.frequency,
    required this.date,
    required this.time,
    required this.comment,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String frequency;
  final DateTime date;
  final TimeOfDay time;
  final String comment;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'frequency': frequency,
      'date': date.millisecondsSinceEpoch,
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory _Reminder.fromMap(Map<String, dynamic> map) {
    return _Reminder(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      frequency: map['frequency'] as String? ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(
        map['date'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      time: TimeOfDay(
        hour: map['timeHour'] as int? ?? 0,
        minute: map['timeMinute'] as int? ?? 0,
      ),
      comment: map['comment'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
