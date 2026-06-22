import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> printImages(
  List<Uint8List> imagesBytes,
  double paperWidth,
  double cardWidth,
  double cardHeight,
) async {
  final htmlContent = StringBuffer();
  htmlContent.write('''
<!DOCTYPE html>
<html>
<head>
  <title>Imprimir Cartas - OPR Army Cards</title>
  <style>
    body {
      margin: 0;
      padding: 20px;
      background-color: #f1f5f9;
      display: flex;
      justify-content: center;
    }
    .sheet {
      width: ${paperWidth}px;
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
      justify-content: center;
      background-color: white;
      padding: 24px;
      box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
      border-radius: 8px;
    }
    .card-img {
      width: ${cardWidth}px;
      height: ${cardHeight}px;
      border-radius: 16px;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    }
    @media print {
      body {
        background-color: white;
        padding: 0;
      }
      .sheet {
        box-shadow: none;
        padding: 0;
      }
      .card-img {
        box-shadow: none;
        page-break-inside: avoid;
      }
    }
  </style>
</head>
<body>
  <div class="sheet">
''');

  for (final bytes in imagesBytes) {
    final base64String = base64Encode(bytes);
    htmlContent.write('    <img class="card-img" src="data:image/png;base64,$base64String" />\n');
  }

  htmlContent.write('''
  </div>
  <script>
    window.onload = function() {
      setTimeout(function() {
        window.print();
      }, 300);
    }
  </script>
</body>
</html>
''');

  final blob = html.Blob([htmlContent.toString()], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
}
