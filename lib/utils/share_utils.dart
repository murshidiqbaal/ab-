import 'dart:io';

import 'package:_abm/dbmodels/models.dart';
import 'package:clipboard/clipboard.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Helper to format the collection as a string
String _formatCollectionToString(Collection collection) {
  String text =
      '*Collection:* ${collection.title}\n*Expected Amount:* ${collection.amount}\n';

  int paidCount = collection.studentList.where((s) => s.isSelected).length;
  text += '*Status:* $paidCount/${collection.studentList.length} Paid\n\n';

  for (int i = 0; i < collection.studentList.length; i++) {
    var student = collection.studentList[i];
    String status = student.isSelected ? '✅ Paid' : '❌ Pending';

    // Add payment method if present
    String details = '';
    if (student.paymentMethod.isNotEmpty) {
      details += ' (${student.paymentMethod})';
    }

    // Add balance/correction if present
    if (student.balance != null && student.balance != 0) {
      double expected = double.tryParse(collection.amount) ?? 0;
      double paid = student.balance!;
      int diff = (paid - expected).toInt();
      if (diff > 0) details += ' [+$diff]';
      if (diff < 0) details += ' [$diff]';
    }

    text += '${i + 1}. ${student.name} : $status$details\n';
  }
  return text;
}

/// 1. Share List as Text
Future<void> shareCollectionAsText(Collection collection) async {
  String text = _formatCollectionToString(collection);
  await Share.share(text, subject: 'Collection Report: ${collection.title}');
}

/// 2. Copy List to Clipboard
Future<void> copyCollectionToClipboard(
    BuildContext context, Collection collection) async {
  String text = _formatCollectionToString(collection);
  await FlutterClipboard.copy(text);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('List copied to clipboard!'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
}

/// 3. Generate and Share Excel
Future<void> generateAndShareExcel(Collection collection) async {
  var excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];

  // Add Headers
  sheet.appendRow([
    TextCellValue('Sl No'),
    TextCellValue('Name'),
    TextCellValue('Status'),
    TextCellValue('Payment Method'),
    TextCellValue('Paid Amount'),
    TextCellValue('Difference'),
  ]);

  double expectedAmount = double.tryParse(collection.amount) ?? 0;

  // Add Data
  for (int i = 0; i < collection.studentList.length; i++) {
    var student = collection.studentList[i];

    String status = student.isSelected ? 'Paid' : 'Pending';
    double paid = student.balance ?? (student.isSelected ? expectedAmount : 0);
    double diff = student.isSelected ? (paid - expectedAmount) : 0;

    sheet.appendRow([
      IntCellValue(i + 1),
      TextCellValue(student.name),
      TextCellValue(status),
      TextCellValue(student.paymentMethod),
      DoubleCellValue(paid),
      DoubleCellValue(diff),
    ]);
  }

  // Save file
  var fileBytes = excel.save();
  var directory = await getApplicationDocumentsDirectory();

  // Sanitize filename
  String safeTitle = collection.title.replaceAll(RegExp(r'[^\w\s]+'), '');
  String path = '${directory.path}/$safeTitle.xlsx';

  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes!);

  // Share file
  await Share.shareXFiles(
    [XFile(path)],
    text: 'Excel Report for ${collection.title}',
    subject: 'Collection Excel Report',
  );
}
