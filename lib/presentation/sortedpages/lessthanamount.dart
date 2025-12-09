import 'package:flutter/material.dart';

import '../../dbmodels/models.dart';

class LessThanAmountPage extends StatelessWidget {
  final Collection collection;

  const LessThanAmountPage({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    List<Student> lessThanAmountStudents =
        collection.studentList.where((student) {
      double balance = student.balance ?? 0.0;
      double amount = double.tryParse(collection.amount) ?? 0.0;
      return balance < amount;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Balance < Amount'),
      ),
      body: ListView.builder(
        itemCount: lessThanAmountStudents.length,
        itemBuilder: (context, index) {
          final student = lessThanAmountStudents[index];
          return ListTile(
            title: Text(student.name),
            subtitle: Text('Balance: ${student.balance}'),
          );
        },
      ),
    );
  }
}
