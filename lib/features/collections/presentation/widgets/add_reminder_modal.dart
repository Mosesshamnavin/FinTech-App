import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../bloc/collections_bloc.dart';
import '../bloc/collections_event.dart';
import '../bloc/collections_state.dart';

class AddReminderModal extends StatefulWidget {
  const AddReminderModal({super.key});

  @override
  State<AddReminderModal> createState() => _AddReminderModalState();
}

class _AddReminderModalState extends State<AddReminderModal> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  /// Schedule a local notification for the reminder date at 8:00 AM.
  void _scheduleReminderNotification() {
    final notificationsEnabled = sl<StorageService>().getBool('notifications_enabled', defaultValue: true);
    if (!notificationsEnabled) return;

    final dateText = _dateController.text.trim();
    final reminderText = _textController.text.trim();
    if (dateText.isEmpty) return;

    try {
      // Parse dd/MM/yyyy format
      final parts = dateText.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final scheduledDate = DateTime(year, month, day, 8, 0); // 8:00 AM

      // Generate a unique notification ID from the date
      final notificationId = year * 10000 + month * 100 + day;

      sl<NotificationService>().scheduleNotification(
        id: notificationId,
        title: '📋 Reminder',
        body: reminderText,
        scheduledDate: scheduledDate,
        payload: 'reminder_$dateText',
      );
    } catch (e) {
      print('Failed to schedule notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectionsBloc, CollectionsState>(
      listener: (context, state) {
        if (state is AddReminderActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder saved successfully')),
          );
          // Schedule a local notification if notifications are enabled
          _scheduleReminderNotification();
          Navigator.of(context).pop(true);
        } else if (state is AddReminderActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Reminder', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
                  IconButton(
                    icon: Icon(Icons.close, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Reminder Text', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    maxLines: 8,
                    minLines: 8,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final date = _dateController.text.trim();
                        final text = _textController.text.trim();
                        if (date.isEmpty || text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a date and enter a reminder text')),
                          );
                          return;
                        }
                        context.read<CollectionsBloc>().add(AddReminderSubmitted(date: date, text: text));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text('SUBMIT', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
