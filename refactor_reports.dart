
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
        "import 'package:flutter_bloc/flutter_bloc.dart';\nimport '../../../../settings/presentation/bloc/settings_bloc.dart';\nimport '../../../../settings/presentation/bloc/settings_state.dart';"
      );
    }

    // 2. Remove class properties
    content = content.replaceAll(RegExp(r"final List<String> _mockLines = \['Line 1', 'Line 2'\];"), "");
    content = content.replaceAll(RegExp(r"final List<String> _mockLines = \['Line 1', 'Line 2', 'Line 3'\];"), "");
    content = content.replaceAll(RegExp(r"final List<String> _mockAreas = \['Area A', 'Area B', 'Area C'\];"), "");

    // 3. Find the Scaffold body and wrap it in a BlocBuilder
    // A bit tricky, let's just find "body: " and wrap whatever is after it up to the end of the Scaffold.
    // Instead, let's use a simpler approach: wrap the whole Scaffold with BlocBuilder!
    
    if (!content.contains('BlocBuilder<SettingsBloc, SettingsState>')) {
      content = content.replaceAll("return Scaffold(", "return BlocBuilder<SettingsBloc, SettingsState>(\n      builder: (context, settingsState) {\n        List<String> _mockLines = [];\n        if (settingsState is SettingsLoaded) {\n          _mockLines = settingsState.lines.map((e) => e.name).toList();\n        }\n        return Scaffold(");
      
      // We need to close the builder.
      // The Scaffold ends right before "  }\n}" of the State class.
      // So let's replace "    );\n  }\n}" with "    );\n      },\n    );\n  }\n}"
      content = content.replaceFirst("    );\n  }\n}", "    );\n      },\n    );\n  }\n}");
    }

    file.writeAsStringSync(content);
    print('Updated ${file.path}');
  }
}

