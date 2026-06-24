
import 'dart:io';

void main() {
  final dir = Directory('lib/features/reports/presentation/pages');
  final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    if (!content.contains('_mockLines')) continue;

    // 1. Add settings bloc imports
    if (!content.contains('settings_bloc.dart')) {
      content = content.replaceFirst(
        "import 'package:flutter_bloc/flutter_bloc.dart';",
        "import 'package:flutter_bloc/flutter_bloc.dart';\nimport '../../../settings/presentation/bloc/settings_bloc.dart';\nimport '../../../settings/presentation/bloc/settings_state.dart';"
      );
    }

    // 2. Remove class properties
    content = content.replaceAll(RegExp(r"final List<String> _mockLines = \[.*?\];"), "");
    content = content.replaceAll(RegExp(r"final List<String> _mockAreas = \[.*?\];"), "");

    // 3. Inject context.watch inside build()
    content = content.replaceFirst(
      "Widget build(BuildContext context) {",
      "Widget build(BuildContext context) {\n    final settingsState = context.watch<SettingsBloc>().state;\n    List<String> _mockLines = settingsState is SettingsLoaded ? settingsState.lines.map((e) => e.name).toList() : [];\n    List<String> _mockAreas = settingsState is SettingsLoaded ? settingsState.areas.map((e) => e.name).toList() : [];"
    );

    file.writeAsStringSync(content);
    print('Updated ${file.path}');
  }
}

