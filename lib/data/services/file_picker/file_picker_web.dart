// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import '../../../domain/entities/selected_file.dart';
export '../../../domain/entities/selected_file.dart' show SelectedFile;

Future<SelectedFile?> pickImageFile() async {
  final completer = Completer<SelectedFile?>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;
  
  input.click();

  input.onChange.listen((e) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      completer.complete(null);
      return;
    }
    final file = files[0];
    final reader = html.FileReader();
    
    reader.onLoadEnd.listen((e) {
      final result = reader.result;
      if (result is String) {
        final commaIndex = result.indexOf(',');
        final base64Content = commaIndex != -1 ? result.substring(commaIndex + 1) : result;
        final bytes = base64.decode(base64Content);
        completer.complete(SelectedFile(
          bytes: bytes,
          base64String: result,
          name: file.name,
        ));
      } else {
        completer.complete(null);
      }
    });

    reader.readAsDataUrl(file);
  });

  return completer.future;
}
