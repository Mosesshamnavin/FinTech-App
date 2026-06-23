import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/settings_entities.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class AddAreaPage extends StatefulWidget {
  const AddAreaPage({super.key});

  @override
  State<AddAreaPage> createState() => _AddAreaPageState();
}

class _AddAreaPageState extends State<AddAreaPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isDropdownOpen = false;
  LineEntity? _selectedLine;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showLineDialog(List<LineEntity> lines) async {
    setState(() {
      _isDropdownOpen = true;
    });
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Line'),
          contentPadding: const EdgeInsets.only(top: 16),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: lines.map((line) {
                return RadioListTile<LineEntity>(
                  title: Text(line.name),
                  value: line,
                  groupValue: _selectedLine,
                  onChanged: (value) {
                    setState(() {
                      _selectedLine = value;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Area'),
        elevation: 2,
        shadowColor: Colors.black26,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          List<LineEntity> lines = [];
          if (state is SettingsLoaded) {
            lines = state.lines;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'AreaName',
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _showLineDialog(lines),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_isDropdownOpen || _selectedLine != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Line', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                              const SizedBox(height: 4),
                              Text(_selectedLine?.name ?? 'Select Line', style: TextStyle(fontSize: 16, color: _isDropdownOpen ? Colors.red : Colors.black)),
                            ],
                          )
                        else
                          const Text('Line', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        Icon(
                          _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: _isDropdownOpen ? Colors.red : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Area Name')));
                        return;
                      }
                      if (_selectedLine == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Line')));
                        return;
                      }
                      
                      final newArea = AreaEntity(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text.trim(),
                        lineId: _selectedLine!.id,
                      );
                      
                      context.read<SettingsBloc>().add(AddAreaSubmitted(newArea));
                      Navigator.of(context).pop();
                    },
                    child: const Text('SAVE'),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
