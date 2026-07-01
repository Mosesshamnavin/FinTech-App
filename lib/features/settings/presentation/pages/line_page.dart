import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_state.dart';
import '../../../collections/presentation/widgets/add_line_modal.dart';

class LinePage extends StatelessWidget {
  const LinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Line'),
        elevation: 2,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddLineModal(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is SettingsLoaded) {
            if (state.lines.isEmpty) {
              return const Center(child: Text('No Lines found.'));
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('RE ORDER'),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300, width: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/settings/move-line-customer');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('LINE MOVE'),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.lines.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final line = state.lines[index];
                      return ListTile(
                        title: Text(line.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(line.type, style: const TextStyle(color: Colors.grey)),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
