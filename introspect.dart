import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://161.97.111.142:8080/v1/graphql');
  final headers = {
    'Content-Type': 'application/json',
    'x-hasura-admin-secret': 'myadminsecretkey',
  };

  final query = '''
    query {
      __type(name: "collections") {
        fields {
          name
          type {
            name
            kind
            ofType {
              name
              kind
            }
          }
        }
      }
    }
  ''';

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode({'query': query}),
  );

  final data = jsonDecode(response.body);
  final typeData = data['data']['__type'];
  if (typeData == null) {
    print('Type collections not found');
    return;
  }
  final fields = typeData['fields'] as List;
  
  final columns = fields.map((f) {
    final typeName = f['type']['name'];
    final ofTypeName = f['type']['ofType']?['name'];
    return f['name'].toString() + ': ' + (typeName ?? ofTypeName).toString();
  }).toList();
  print('Columns in collections: ' + columns.toString());
}
