import 'package:flutter_quill/quill_delta.dart';

class DeltaToHtmlConverter {
  static String extractFormattedText(Delta delta) {
    String formattedText = '';
    for (var op in delta.toList()) {
      if (op.data is String) {
        String text = op.data as String;
        if (op.attributes != null) {
          String style = '';

          if (op.attributes!.containsKey('font')) {
            style += 'font-family: ${op.attributes!['font']};';
          }

          if (op.attributes!.containsKey('size')) {
            style += 'font-size: ${op.attributes!['size']};';
          }

          if (op.attributes!.containsKey('bold') && op.attributes!['bold']) {
            style += 'font-weight: bold;';
          }

          if (op.attributes!.containsKey('italic') &&
              op.attributes!['italic']) {
            style += 'font-style: italic;';
          }

          if (op.attributes!.containsKey('underline') &&
              op.attributes!['underline']) {
            style += 'text-decoration: underline;';
          }

          if (op.attributes!.containsKey('color')) {
            style += 'color: ${op.attributes!['color']};';
          }

          if (op.attributes!.containsKey('background')) {
            style += 'background-color: ${op.attributes!['background']};';
          }

          if (op.attributes!.containsKey('align')) {
            text =
                '<div style="text-align: ${op.attributes!['align']};">$text</div>';
          } else if (style.isNotEmpty) {
            // Apply span style only if no align attribute
            text = '<span style="$style">$text</span>';
          }

          if (op.attributes!.containsKey('header')) {
            switch (op.attributes!['header']) {
              case 1:
                text = '<h1>$text</h1>';
                break;
              case 2:
                text = '<h2>$text</h2>';
                break;
              case 3:
                text = '<h3>$text</h3>';
                break;
            }
          }

          if (style.isNotEmpty) {
            text = '<span style="$style">$text</span>';
          }
        }
        formattedText += text;
      }
    }
    return formattedText;
  }
}
