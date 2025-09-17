import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import '../models/chemical.dart';

class CSVParser {
  static Future<List<Chemical>> loadChemicalGuide(String csvData) async {
    final List<Chemical> chemicals = [];

    try {
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      if (rows.isEmpty) return chemicals;

      final headers = rows[0].map((e) => e.toString().trim()).toList();

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        final chemicalMap = <String, dynamic>{};

        for (int j = 0; j < headers.length; j++) {
          if (j < row.length) {
            chemicalMap[headers[j]] = row[j];
          }
        }

        try {
          final chemical = Chemical.fromMap(chemicalMap);
          if (chemical.name.isNotEmpty && chemical.casNumber.isNotEmpty) {
            chemicals.add(chemical);
          }
        } catch (e) {
          print('Error parsing row $i: $e');
        }
      }
    } catch (e) {
      print('Error parsing CSV: $e');
    }

    return chemicals;
  }

  static Future<List<Chemical>> loadFromAssets(String path) async {
    final data = await rootBundle.loadString(path);
    return loadChemicalGuide(data);
  }
}
