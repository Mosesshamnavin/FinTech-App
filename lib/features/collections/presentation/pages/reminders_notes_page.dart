import 'package:flutter/material.dart';
import '../widgets/add_reminder_modal.dart';

class RemindersNotesPage extends StatelessWidget {
  const RemindersNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black26,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          titleSpacing: 0,
          title: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            indicatorSize: TabBarIndicatorSize.tab,
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
    );
  }
}

class _ReminderTab extends StatelessWidget {
  const _ReminderTab();

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
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const AddReminderModal(),
                              );
                            },
                            icon: const Icon(Icons.add, size: 28),
                          ),
                        ],
                      ),
                      // List of reminders would go here
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

class _NotesTab extends StatelessWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Notes', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 8,
            minLines: 8,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('SAVE', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
