import 'dart:io';
import 'dart:convert';

void main() {
  File('assets/images/transparent.png').writeAsBytesSync(base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='));
}
