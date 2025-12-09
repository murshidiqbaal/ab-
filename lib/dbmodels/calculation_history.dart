import 'package:hive/hive.dart';

part 'calculation_history.g.dart'; // Ensure this part file is generated with build_runner

@HiveType(typeId: 15) // Unique type ID for this adapter
class CalculationHistory extends HiveObject {
  @HiveField(12)
  final String question; // Stores the mathematical question

  @HiveField(1)
  final String answer; // Stores the evaluated result of the question

  @HiveField(2)
  final DateTime date; // Stores the date and time of the calculation

  @HiveField(3)
  final String? note; // Optional field for any additional notes

  // Constructor for initializing required fields
  CalculationHistory({
    required this.question,
    required this.answer,
    required this.date,
    this.note, // Optional field for notes
  });

  // Factory method to easily create a CalculationHistory object
  factory CalculationHistory.create({
    required String question,
    required String answer,
    String? note,
  }) {
    return CalculationHistory(
      question: question,
      answer: answer,
      date: DateTime.now(), // Automatically add the current date and time
      note: note, // Optional note, can be null
    );
  }
}
