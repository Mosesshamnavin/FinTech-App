import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/bloc/settings_state.dart';

class CustomDropdownFormField<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool isExpanded;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
  });

  @override
  State<CustomDropdownFormField<T>> createState() => _CustomDropdownFormFieldState<T>();
}

class _CustomDropdownFormFieldState<T> extends State<CustomDropdownFormField<T>> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _hasFocus ? Colors.red[300]! : Colors.black87;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        List<DropdownMenuItem<T>> displayItems = widget.items;
        T? displayValue = widget.value;

        if (state is SettingsLoaded) {
          if (widget.label == 'Line' || widget.label == 'Select Line') {
            final lines = state.lines.map((e) => e.name).toList();
            displayItems = lines.map((line) => DropdownMenuItem(value: line as T, child: Text(line))).toList();
            if (displayValue != null && !lines.contains(displayValue as String)) {
              displayValue = null;
            }
          } else if (widget.label == 'Area' || widget.label == 'Select Area') {
            final areas = state.areas.map((e) => e.name).toList();
            displayItems = areas.map((area) => DropdownMenuItem(value: area as T, child: Text(area))).toList();
            if (displayValue != null && !areas.contains(displayValue as String)) {
              displayValue = null;
            }
          }
        }

        return DropdownButtonFormField<T>(
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(color: color),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red[300]!),
            ),
          ),
          icon: Icon(Icons.arrow_drop_down, color: color),
          isExpanded: widget.isExpanded,
          value: displayValue,
          items: displayItems,
          onChanged: widget.onChanged,
        );
      },
    );
  }
}
