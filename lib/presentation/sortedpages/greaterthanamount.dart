import 'package:_abm/dbmodels/models.dart';
import 'package:flutter/material.dart';

class GreaterThanAmountPage extends StatelessWidget {
  final Collection collection;

  const GreaterThanAmountPage({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    List<Student> greaterThanAmountStudents =
        collection.studentList.where((student) {
      double balance = student.balance ?? 0.0;
      double amount = double.tryParse(collection.amount) ?? 0;
      return balance > amount;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Balance > Amount'),
      ),
      body: ListView.builder(
        itemCount: greaterThanAmountStudents.length,
        itemBuilder: (context, index) {
          final student = greaterThanAmountStudents[index];
          return ListTile(
            title: Text(student.name),
            subtitle: Text('Balance: ${student.balance}'),
          );
        },
      ),
    );
  }
}
