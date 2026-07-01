import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/collections_bloc.dart';
import '../bloc/collections_event.dart';
import '../bloc/collections_state.dart';
import '../widgets/add_reminder_modal.dart';

class RemindersNotesPage extends StatelessWidget {
  const RemindersNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CollectionsBloc>(),
      child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black26,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: const [
            SizedBox(width: 48), // Balances the leading back button for perfect centering
          ],
          titleSpacing: 0,
          title: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'REMINDER'),
              Tab(text: 'NOTES'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ReminderTab(),
            _NotesTab(),
          ],
        ),
      ),
    ),
  );
}
}

class _ReminderTab extends StatefulWidget {
  const _ReminderTab();

  @override
  State<_ReminderTab> createState() => _ReminderTabState();
}

class _ReminderTabState extends State<_ReminderTab> {
  @override
  void initState() {
    super.initState();
    context.read<CollectionsBloc>().add(const LoadRemindersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'TODAY'),
              Tab(text: 'HISTORY'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // TODAY TAB
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('CLEAR ALL'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('SCHEDULE ALL'),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () async {
                              final bloc = context.read<CollectionsBloc>();
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => BlocProvider.value(
                                  value: bloc,
                                  child: const AddReminderModal(),
                                ),
                              );
                              if (result == true) {
                                bloc.add(const LoadRemindersRequested());
                              }
                            },
                            icon: const Icon(Icons.add, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // List of reminders
                      Expanded(
                        child: BlocBuilder<CollectionsBloc, CollectionsState>(
                          builder: (context, state) {
                            if (state is RemindersLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is RemindersError) {
                              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                            } else if (state is RemindersLoaded) {
                              if (state.reminders.isEmpty) {
                                return const Center(child: Text('No reminders found.', style: TextStyle(color: Colors.grey)));
                              }
                              return ListView.separated(
                                itemCount: state.reminders.length,
                                separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                                itemBuilder: (context, index) {
                                  final reminder = state.reminders[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(reminder.text, style: const TextStyle(fontSize: 14)),
                                    subtitle: Text(reminder.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  );
                                },
                              );
                            }
                            return const Center(child: Text('No reminders found.', style: TextStyle(color: Colors.grey)));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // HISTORY TAB
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('BULK DELETE'),
                          ),
                        ],
                      ),
                      // History list would go here
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesTab extends StatefulWidget {
  const _NotesTab();

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CollectionsBloc>().add(const LoadNotesRequested());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectionsBloc, CollectionsState>(
      listener: (context, state) {
        if (state is AddNoteActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note saved successfully!')),
          );
          _noteController.clear();
          context.read<CollectionsBloc>().add(const LoadNotesRequested());
        } else if (state is AddNoteActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Notes', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 4,
              minLines: 4,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                hintText: 'Type your note here...',
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_noteController.text.trim().isNotEmpty) {
                    context.read<CollectionsBloc>().add(AddNoteSubmitted(text: _noteController.text));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('SAVE', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Past Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
            const Divider(),
            Expanded(
              child: BlocBuilder<CollectionsBloc, CollectionsState>(
                buildWhen: (previous, current) {
                  return current is NotesLoading || current is NotesLoaded || current is NotesError;
                },
                builder: (context, state) {
                  if (state is NotesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is NotesError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  } else if (state is NotesLoaded) {
                    if (state.notes.isEmpty) {
                      return const Center(child: Text('No notes found.', style: TextStyle(color: Colors.grey)));
                    }
                    return ListView.separated(
                      itemCount: state.notes.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                      itemBuilder: (context, index) {
                        final note = state.notes[index];
                        // Parse timestamp if needed, or just display
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(note.text, style: const TextStyle(fontSize: 14)),
                          subtitle: Text(
                            note.createdAt, 
                            style: const TextStyle(fontSize: 12, color: Colors.grey)
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
