import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../theme/colors.dart';
import '../theme/custom_button.dart';
import '../theme/custom_text_field.dart';
import '../data/models.dart';
import '../data/providers.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  static const List<Map<String, dynamic>> eventCategories = [
    {'id': 'academic', 'name': 'Academic', 'icon': Icons.school_rounded},
    {'id': 'deadline', 'name': 'Deadline', 'icon': Icons.notification_important_rounded},
    {'id': 'personal', 'name': 'Personal', 'icon': Icons.celebration_rounded},
    {'id': 'news', 'name': 'News', 'icon': Icons.campaign_rounded},
  ];

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Future.microtask(() async {
      if (!mounted) return;
      final user = context.read<UserProvider>().user;
      if (user != null) {
        await context.read<CalendarProvider>().loadEvents(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final selectedEvents = _selectedDay != null
        ? calendarProvider.getEventsForDate(_selectedDay!)
        : <EventModel>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _CalendarCard(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            events: calendarProvider.events,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBackground
                    : Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: selectedEvents.isEmpty
                  ? _EmptyEvents(selectedDate: _selectedDay!)
                  : _EventsList(
                      events: selectedEvents,
                      selectedDate: _selectedDay!,
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "add_event_btn",
        onPressed: () => _showAddEventDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEventBottomSheet(selectedDate: _selectedDay!),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final List<EventModel> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;

  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.events,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        calendarFormat: calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 45,
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          titleCentered: true,
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
          rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: AppColors.error),
        ),
        eventLoader: (day) {
          return events.where((e) => isSameDay(e.date, day)).toList();
        },
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<EventModel> events;
  final DateTime selectedDate;

  const _EventsList({required this.events, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      itemCount: events.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              DateFormat('EEEE, d MMMM').format(selectedDate),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textGrey),
            ),
          );
        }
        return _EventCard(event: events[index - 1]);
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor(event.type);

    final category = CalendarScreen.eventCategories.firstWhere(
      (cat) => cat['id'] == event.type,
      orElse: () => {'icon': Icons.event_note_rounded},
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(category['icon'] as IconData, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(event.date),
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textGrey),
            onPressed: () => _showEventDetails(context),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'academic': return AppColors.books;
      case 'deadline': return AppColors.health;
      case 'personal': return AppColors.communication;
      case 'news': return AppColors.entertainment;
      default: return AppColors.primary;
    }
  }

  void _showEventDetails(BuildContext context) {
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailsSheet(event: event),
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  final DateTime selectedDate;

  const _EmptyEvents({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 80,
              color: AppColors.textGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            const Text('No events yet', style: TextStyle(color: AppColors.textGrey, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              DateFormat('d MMMM yyyy', 'en_US').format(selectedDate),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDetailsSheet extends StatelessWidget {
  final EventModel event;

  const _EventDetailsSheet({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor(event.type);

    final category = CalendarScreen.eventCategories.firstWhere(
      (cat) => cat['id'] == event.type,
      orElse: () => {'icon': Icons.event_note_rounded, 'name': 'Event'},
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(category['icon'] as IconData, color: color, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['name'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: DateFormat('d MMMM yyyy', 'en_US').format(event.date),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: DateFormat('HH:mm').format(event.date),
          ),
          if (event.description != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.description_rounded,
              label: 'Description',
              value: event.description!,
            ),
          ],
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'academic': return AppColors.books;
      case 'deadline': return AppColors.health;
      case 'personal': return AppColors.communication;
      case 'news': return AppColors.entertainment;
      default: return AppColors.primary;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddEventBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const _AddEventBottomSheet({required this.selectedDate});

  @override
  State<_AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<_AddEventBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'personal';
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add event',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          DateFormat('d MMMM yyyy', 'en_US').format(widget.selectedDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Name',
                hint: '...',
                controller: _titleController,
                prefixIcon: const Icon(Icons.title_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description (optional)',
                hint: '...',
                controller: _descriptionController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.description_rounded),
              ),
              const SizedBox(height: 16),
              Text(
                'Event type',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CalendarScreen.eventCategories.map((type) {
                  final isSelected = _selectedType == type['id'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type['icon'] as IconData,
                          size: 18,
                          color: isSelected ? AppColors.primary : AppColors.textGrey
                        ),
                        const SizedBox(width: 8),
                        Text(type['name'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedType = type['id'] as String);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundColor: AppColors.darkSurface,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textGrey,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.textGrey.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _TimeSelector(
                label: 'Time',
                time: _selectedTime,
                onTimeSelected: (time) => setState(() => _selectedTime = time),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Add',
                onPressed: _saveEvent,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<UserProvider>().user?.id ?? '';
    final eventDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final event = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      date: eventDate,
      type: _selectedType,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );

    context.read<CalendarProvider>().addEvent(userId, event);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${event.title} added to calendar'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (pickedTime != null) {
              onTimeSelected(pickedTime);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textGrey.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  time.format(context),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}