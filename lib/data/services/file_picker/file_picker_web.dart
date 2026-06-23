// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../../../domain/entities/selected_file.dart';
export '../../../domain/entities/selected_file.dart' show SelectedFile;

Future<SelectedFile?> pickImageFile() async {
  final completer = Completer<SelectedFile?>();
  final input = web.document.createElement('input') as web.HTMLInputElement;
  input.type = 'file';
  input.accept = 'image/*';
  input.multiple = false;
  
  input.addEventListener('change', (web.Event event) {
    final files = input.files;
    if (files == null || files.length == 0) {
      completer.complete(null);
      return;
    }
    final file = files.item(0);
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = web.FileReader();
    
    reader.addEventListener('loadend', (web.Event event) {
      final result = reader.result;
      if (result != null && result.isA<JSString>()) {
        final resultString = (result as JSString).toDart;
        final commaIndex = resultString.indexOf(',');
        final base64Content = commaIndex != -1 ? resultString.substring(commaIndex + 1) : resultString;
        final bytes = base64.decode(base64Content);
        completer.complete(SelectedFile(
          bytes: bytes,
          base64String: resultString,
          name: file.name,
        ));
      } else {
        completer.complete(null);
      }
    }.toJS);

    reader.readAsDataURL(file);
  }.toJS);

  input.click();

  return completer.future;
}
