// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<void> printImages(
  List<Uint8List> imagesBytes,
  double paperWidth,
  double cardWidth,
  double cardHeight,
) async {
  final styleElement =
      web.document.createElement('style') as web.HTMLStyleElement;
  styleElement.textContent =
      '''
    @media print {
      body > *:not(#print-container) {
        display: none !important;
      }
      html, body {
        background: white !important;
        margin: 0 !important;
        padding: 0 !important;
        width: 100% !important;
        height: auto !important;
      }
      #print-container {
        display: block !important;
        width: ${paperWidth}px !important;
        margin: 0 auto !important;
        padding: 0 !important;
        background: white !important;
      }
      .print-sheet {
        display: flex !important;
        flex-wrap: wrap !important;
        gap: 16px !important;
        justify-content: center !important;
        background: white !important;
        padding: 24px !important;
      }
      .print-card-img {
        width: ${cardWidth}px !important;
        height: ${cardHeight}px !important;
        border-radius: 16px !important;
        page-break-inside: avoid !important;
        break-inside: avoid !important;
        display: block !important;
      }
    }
    @media screen {
      #print-container {
        display: none !important;
      }
    }
  ''';
  web.document.head?.appendChild(styleElement);

  final printContainer =
      web.document.createElement('div') as web.HTMLDivElement;
  printContainer.id = 'print-container';

  final printSheet = web.document.createElement('div') as web.HTMLDivElement;
  printSheet.className = 'print-sheet';
  printContainer.appendChild(printSheet);

  for (final bytes in imagesBytes) {
    final base64String = base64Encode(bytes);
    final img = web.document.createElement('img') as web.HTMLImageElement;
    img.className = 'print-card-img';
    img.src = 'data:image/png;base64,$base64String';
    printSheet.appendChild(img);
  }

  web.document.body?.appendChild(printContainer);

  // Wait for the images to load/render in the DOM before printing
  await Future.delayed(const Duration(milliseconds: 300));

  try {
    web.window.focus();
    web.window.print();
  } catch (e) {
    // Print dialog failed
  }

  // Clean up DOM after printing dialog is closed/resumed
  printContainer.remove();
  styleElement.remove();
}
