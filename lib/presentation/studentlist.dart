// ignore_for_file: unused_element

import 'package:_abm/constants/mytextfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dbmodels/models.dart';

class StudentListScreen extends StatefulWidget {
  final Collection collection;

  const StudentListScreen({
    super.key,
    required this.collection,
    required String title,
    required String amount,
    required List<Student> studentsWithLessThanAmount,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  int totalSum = 0;
  int totalBalanceSum1 = 0;
  int totalBalanceSum2 = 0;
  int totalsum1 = 0;
  int results = 0;

  // ignore: unused_field
  List<Student> _filteredStudents = [];
  List<Student> studentsWithLessThanAmount = [];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _balanceController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    _filteredStudents = widget.collection.studentList;
  }

  void _calculateTotal() {
    int total = 0;
    //int totalNegativeBalance = 0;

    for (var student in widget.collection.studentList) {
      // int balanceValue = int.tryParse(student.balance ?? '0') ?? 0;
      int amountValue = int.tryParse(widget.collection.amount) ?? 0;

      if (student.isSelected) {
        total += amountValue;
        //int result = balanceValue;

        // Add to negative balance total if the result is negative
        // if (results < 0) {
        //   totalNegativeBalance += results.abs();
        // }
      }
    }

    setState(() {
      totalSum = total;
      totalsum1 = totalBalanceSum1;
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      bool wasSelected = widget.collection.studentList[index].isSelected;

      // Toggle the selection
      widget.collection.studentList[index].isSelected = !wasSelected;

      // If the checkbox is ticked, show the payment dialog
      if (widget.collection.studentList[index].isSelected) {
        _showPaymentDialog(index);
      } else {
        // If checkbox is deselected, clear the payment method and balance
        widget.collection.studentList[index].paymentMethod = '';
        widget.collection.studentList[index].balance = null;

        // Recalculate the totalBalanceSum1 based on the deselected result
        // int balanceValue =
        //     int.tryParse(widget.collection.studentList[index].balance ?? '0') ??
        //         0;
        // int amountValue = int.tryParse(widget.collection.amount) ?? 0;
        //int result = (balanceValue - amountValue);
        // if (result < 0) {
        //   totalBalanceSum1 -= result; // Adjust the negative balance total
        // }
      }

      // Save the updated state into Hive
      widget.collection.save();
      _calculateTotal(); // Recalculate the total when selection changes
    });
  }

  void _filterStudentsWithLessAmount() {
    int amountValue = widget.collection.amount as int;

    setState(() {
      studentsWithLessThanAmount =
          widget.collection.studentList.where((student) {
        int balanceValue = int.tryParse(student.balance ?? '0') ?? 0;
        return (balanceValue - amountValue) < 0;
      }).toList();
    });
  }

  void _showPaymentDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        int? selector;
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('GPay'),
                onTap: () {
                  setState(() {
                    selector = 1;
                  });
                },
              ),
              ListTile(
                title: const Text('Liquid'),
                onTap: () {
                  setState(() {
                    selector = 2;
                  });
                },
              ),
              MyTextField(
                HintText: 'Type amount',
                Controller: _balanceController,
                LabelText: Text('Correption'),
                ObscureText: false,
                KeyBoardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save the entered balance into the specific student
                setState(() {
                  widget.collection.studentList[index].balance =
                      _balanceController.text;

                  // int balance = _balanceController.text as int;
                  // int? Amount = int.tryParse(widget.collection.amount);
                  // int result = Amount! - balance;
                  // if (result < Amount) {
                  //   addToStudentsWithLessThanAmount(index);
                  //   //print(studentsWithLessThanAmount);
                  // }
                  if (selector == 1) {
                    widget.collection.studentList[index].paymentMethod = 'GPay';
                  } else if (selector == 2) {
                    widget.collection.studentList[index].paymentMethod =
                        'Liquid';
                  } else {
                    selector = null;
                  }
                  _balanceController.clear();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredStudents = widget.collection.studentList; // Reset to full list
      }
    });
  }

  void _filterStudents(String query) {
    final List<Student> filteredList =
        widget.collection.studentList.where((student) {
      return student.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredStudents = filteredList;
    });

    if (filteredList.isNotEmpty) {
      // Get the index of the first matching student and scroll to their position
      int index = widget.collection.studentList.indexWhere((student) =>
          student.name.toLowerCase().contains(query.toLowerCase()));

      if (index != -1) {
        _scrollController.animateTo(
          index * 60.0, // Assumes each ListTile has a height of ~60 pixels
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void addToStudentsWithLessThanAmount(index) {
    studentsWithLessThanAmount =
        widget.collection.studentList[index] as List<Student>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromRGBO(253, 245, 230, 0.51),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (query) => _filterStudents(query), // Update search
                autofocus: true,
              )
            : Text(
                '${widget.collection.title.toUpperCase()}  ${widget.collection.amount}₹',
                style: const TextStyle(color: Colors.black),
              ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              // color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach ScrollController
              itemCount: widget.collection.studentList.length,
              itemBuilder: (context, index) {
                final student = widget.collection.studentList[index];
                return ListTile(
                  title: Row(
                    children: [
                      Text('${index + 1}.  '),
                      Text(
                        student.name,
                        style: GoogleFonts.electrolize(),
                      ),
                    ],
                  ),
                  subtitle: student.paymentMethod.isNotEmpty
                      ? Row(
                          children: [
                            Text(
                              'Payment: ${student.paymentMethod}  ',
                              style: TextStyle(
                                fontSize: 14,
                                color: student.paymentMethod == 'GPay'
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                            if (student.balance != null &&
                                student.balance!.isNotEmpty)
                              Builder(
                                builder: (context) {
                                  int balanceValue =
                                      int.tryParse(student.balance ?? '0') ?? 0;
                                  int amountValue =
                                      int.tryParse(widget.collection.amount) ??
                                          0;

                                  results = balanceValue - amountValue;
                                  int result = results.abs();
                                  results < 0
                                      ? totalBalanceSum1 += result
                                      : totalBalanceSum2 += results;
                                  // if (result < 0) {
                                  //   addToStudentsWithLessThanAmount(index);
                                  //   //print(studentsWithLessThanAmount);
                                  // }
                                  return Text(
                                    results >= 0
                                        ? '+$results'
                                        : '$results', // Show positive or negative results
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: results >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                },
                              ),
                          ],
                        )
                      : null,
                  trailing: Checkbox(
                    value: student.isSelected,
                    onChanged: (bool? value) {
                      _toggleSelection(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(240, 240, 240, 1.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total :',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              Row(
                children: [
                  // if (totalBalanceSum1 != 0)
                  //   Text(
                  //     '₹($totalsum1)',
                  //     style: const TextStyle(
                  //       fontSize: 20,
                  //       color: Colors.red,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  Text(
                    ' ₹${totalSum.toString()}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
