class CsvHelper {
  /// Converts a header list and a list of row maps into a CSV string.
  static String toCsv({
    required List<String> headers,
    required List<Map<String, String>> rows,
  }) {
    final StringBuffer sb = StringBuffer();
    
    // Write headers
    sb.writeln(headers.map(_escapeValue).join(','));
    
    // Write rows
    for (final row in rows) {
      final line = headers.map((h) => _escapeValue(row[h] ?? '')).join(',');
      sb.writeln(line);
    }
    
    return sb.toString();
  }

  /// Parses a CSV string into a list of maps using the headers.
  static List<Map<String, String>> parseCsv(String csvContent) {
    final List<Map<String, String>> result = [];
    final List<String> lines = csvContent.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return result;

    final String firstLine = lines.first.trim();
    if (firstLine.isEmpty) return result;

    final List<String> headers = _splitCsvLine(firstLine);
    if (headers.isEmpty) return result;

    for (int i = 1; i < lines.length; i++) {
      final String line = lines[i].trim();
      if (line.isEmpty) continue;

      final List<String> values = _splitCsvLine(line);
      final Map<String, String> row = {};

      for (int j = 0; j < headers.length; j++) {
        final header = headers[j];
        final value = j < values.length ? values[j] : '';
        row[header] = value;
      }
      result.add(row);
    }

    return result;
  }

  /// Escapes a single CSV cell value if it contains quotes, commas, or newlines.
  static String _escapeValue(String val) {
    String clean = val.replaceAll('\r', '').replaceAll('\n', ' ');
    if (clean.contains(',') || clean.contains('"')) {
      clean = clean.replaceAll('"', '""');
      return '"$clean"';
    }
    return clean;
  }

  /// Helper to split a CSV line while respecting quoted commas.
  static List<String> _splitCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer currentField = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final String char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote character
          currentField.write('"');
          i++; // Skip the next quote
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(currentField.toString().trim());
        currentField.clear();
      } else {
        currentField.write(char);
      }
    }
    result.add(currentField.toString().trim());
    return result;
  }
}
