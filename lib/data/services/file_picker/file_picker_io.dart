import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../../domain/entities/selected_file.dart';
export '../../../domain/entities/selected_file.dart' show SelectedFile;

Future<SelectedFile?> pickImageFile() async {
  if (!Platform.isWindows) {
    return null;
  }
  
  try {
    final psCommand = '''
    Add-Type -AssemblyName System.Windows.Forms;
    \$dialog = New-Object System.Windows.Forms.OpenFileDialog;
    \$dialog.Filter = "Image Files (*.jpg;*.jpeg;*.png;*.gif)|*.jpg;*.jpeg;*.png;*.gif";
    \$res = \$dialog.ShowDialog();
    if (\$res -eq "OK") {
      Write-Output \$dialog.FileName;
    }
    ''';
    
    final result = await Process.run('powershell', ['-Command', psCommand]);
    final path = result.stdout.toString().trim();
    if (path.isEmpty || !File(path).existsSync()) {
      return null;
    }
    
    final file = File(path);
    final bytes = await file.readAsBytes();
    final base64String = base64.encode(bytes);
    final fileName = path.split(Platform.pathSeparator).last;
    
    return SelectedFile(
      bytes: bytes,
      base64String: 'data:image/${fileName.split('.').last};base64,$base64String',
      name: fileName,
    );
  } catch (e) {
    return null;
  }
}
