import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';
import '../services/reminder_service.dart';

/// Screen for scheduling movie watch reminders
/// Provides calendar view and time picker for setting reminders
class ScheduleScreen extends StatefulWidget {
  final String watchlistItemId;
  final String movieTitle;
  final String? moviePosterUrl;

  const ScheduleScreen({
    super.key,
    required this.watchlistItemId,
    required this.movieTitle,
    this.moviePosterUrl,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final ReminderService _reminderService = ReminderService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedTimezone = tz.local.name;

  List<Reminder> _existingReminders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Load existing reminders
    _loadExistingReminders();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadExistingReminders() {
    setState(() {
      _existingReminders = _reminderService.getRemindersForMovie(
        widget.watchlistItemId,
      );
    });
  }

  List<Reminder> _getRemindersForDay(DateTime day) {
    return _existingReminders.where((reminder) {
      return isSameDay(reminder.scheduledDateTime, day);
    }).toList();
  }

  bool _hasRemindersForDay(DateTime day) {
    return _getRemindersForDay(day).isNotEmpty;
  }

  Future<void> _scheduleReminder() async {
    if (_selectedDay == null) {
      _showErrorSnackBar('Please select a date first');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Combine selected date and time
      final scheduledDateTime = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Validate the scheduled time is in the future
      if (!_reminderService.canScheduleReminder(
        scheduledDateTime,
        _selectedTimezone,
      )) {
        _showErrorSnackBar('Cannot schedule reminder in the past');
        return;
      }

      // Create the reminder
      final success = await _reminderService.createReminder(
        watchlistItemId: widget.watchlistItemId,
        movieTitle: widget.movieTitle,
        moviePosterUrl: widget.moviePosterUrl,
        scheduledDateTime: scheduledDateTime,
        timezone: _selectedTimezone,
      );

      if (success) {
        _showSuccessSnackBar('Reminder set for ${widget.movieTitle}!');
        _loadExistingReminders(); // Refresh the calendar

        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _showErrorSnackBar('Failed to set reminder. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF667eea),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final confirmed = await _showDeleteConfirmation(reminder);
    if (confirmed == true) {
      final success = await _reminderService.deleteReminder(reminder.id);
      if (success) {
        _showSuccessSnackBar('Reminder deleted');
        _loadExistingReminders();
      } else {
        _showErrorSnackBar('Failed to delete reminder');
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(Reminder reminder) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2940),
        title: const Text(
          'Delete Reminder',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete the reminder for ${reminder.movieTitle}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B2A),
      appBar: AppBar(
        title: const Text(
          'Movie Dexter',
          style: TextStyle(
            color: Color(0xFFFFD233),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie info header
                _buildMovieHeader(),
                const SizedBox(height: 32),

                // Calendar
                _buildCalendar(),
                const SizedBox(height: 32),

                // Time picker
                if (_selectedDay != null) ...[
                  _buildTimePicker(),
                  const SizedBox(height: 32),
                ],

                // Existing reminders for selected day
                if (_selectedDay != null &&
                    _hasRemindersForDay(_selectedDay!)) ...[
                  _buildExistingReminders(),
                  const SizedBox(height: 32),
                ],

                // Schedule button
                if (_selectedDay != null) _buildScheduleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.movie_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movieTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Set a reminder to watch this movie',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2940),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TableCalendar<Reminder>(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) {
          try {
            return _getRemindersForDay(day);
          } catch (e) {
            return [];
          }
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: Colors.white70),
          defaultTextStyle: const TextStyle(color: Colors.white),
          selectedDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          todayDecoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          markerDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 3,
          markersAlignment: Alignment.bottomCenter,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white70),
          weekendStyle: TextStyle(color: Colors.white70),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2940),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3A395B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF667eea)),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingReminders() {
    final reminders = _getRemindersForDay(_selectedDay!);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2940),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Existing Reminders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reminders.map(
            (reminder) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${TimeOfDay.fromDateTime(reminder.scheduledDateTime).format(context)} - ${reminder.movieTitle}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deleteReminder(reminder),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _scheduleReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Set Reminder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
