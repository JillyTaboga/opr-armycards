import 'dart:typed_data';

class SelectedFile {
  final Uint8List? bytes;
  final String? base64String;
  final String name;

  SelectedFile({this.bytes, this.base64String, required this.name});
}
