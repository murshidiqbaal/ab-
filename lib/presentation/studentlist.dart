// ignore_for_file: unused_element

import 'package:_abm/constants/mytextfield.dart';
import 'package:_abm/utils/share_utils.dart';
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
  int selectedCount = 0;

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
    int count = 0;
    int surplus = 0; // + value
    int deficit = 0; // - value

    int amountModel = int.tryParse(widget.collection.amount) ?? 0;

    for (var student in widget.collection.studentList) {
      if (student.isSelected) {
        // Logic Change:
        // amountModel = Expected Amount (from Collection)
        // student.balance = Actual Paid Amount (entered in correction)
        // If balance is null, assume they paid the full amountModel

        double paidAmount = student.balance ?? amountModel.toDouble();
        total += paidAmount.toInt();

        int diff = (paidAmount - amountModel).toInt();

        if (diff > 0) {
          surplus += diff;
        } else if (diff < 0) {
          deficit += diff.abs();
        }
      }
    }

    setState(() {
      totalSum = total;
      totalBalanceSum2 = surplus;
      totalBalanceSum1 = deficit;
      selectedCount = count;
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
    int amountValue = int.tryParse(widget.collection.amount) ?? 0;

    setState(() {
      studentsWithLessThanAmount =
          widget.collection.studentList.where((student) {
        double balanceValue = student.balance ?? 0.0;
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
                trailing: selector == 1
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    selector = 1;
                  });
                },
              ),
              ListTile(
                title: const Text('Liquid'),
                trailing: selector == 2
                    ? Icon(Icons.check_circle, color: Colors.blue)
                    : null,
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
                      double.tryParse(_balanceController.text);

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
                  _calculateTotal(); // Recalculate totals immediately after save
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
    if (query.isEmpty) {
      setState(() {
        _filteredStudents = widget.collection.studentList;
      });
      return;
    }
    setState(() {
      _filteredStudents = widget.collection.studentList
          .where((student) =>
              student.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addToStudentsWithLessThanAmount(index) {
    studentsWithLessThanAmount =
        widget.collection.studentList[index] as List<Student>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                onChanged: (query) => _filterStudents(query), // Update search
                autofocus: true,
              )
            : Text(
                '${widget.collection.title.toUpperCase()}  ${widget.collection.amount}₹',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'text') {
                shareCollectionAsText(widget.collection);
              } else if (value == 'excel') {
                generateAndShareExcel(widget.collection);
              } else if (value == 'copy') {
                copyCollectionToClipboard(context, widget.collection);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'text',
                child: ListTile(
                  leading: Icon(Icons.share, color: Colors.blue),
                  title: Text('Share as Text'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'excel',
                child: ListTile(
                  leading: Icon(Icons.table_chart, color: Colors.green),
                  title: Text('Export to Excel'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'copy',
                child: ListTile(
                  leading: Icon(Icons.copy, color: Colors.orange),
                  title: Text('Copy to Clipboard'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _filteredStudents.isEmpty
                ? Center(
                    child: Text(
                      'No student found',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController, // Attach ScrollController
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      // Find the original index for updates
                      final originalIndex =
                          widget.collection.studentList.indexOf(student);

                      return ListTile(
                        tileColor:
                            null, // Removed highlighting as we filter now
                        title: Row(
                          children: [
                            Text(
                              '${index + 1}.  ',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            ), // Filtered index
                            Text(
                              student.name,
                              style: GoogleFonts.electrolize(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
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
                                  if (student.balance != null)
                                    Builder(
                                      builder: (context) {
                                        double paidAmount =
                                            student.balance ?? 0.0;
                                        double expectedAmount = double.tryParse(
                                                widget.collection.amount) ??
                                            0.0;

                                        // results = Difference (Paid - Expected)
                                        results = (paidAmount - expectedAmount)
                                            .toInt();

                                        return Text(
                                          results > 0
                                              ? '+$results'
                                              : '$results', // Show positive or negative
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: results > 0
                                                ? Colors.green
                                                : Colors
                                                    .red, // Red for negative
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
                            if (originalIndex != -1) {
                              _toggleSelection(originalIndex);
                            }
                          },
                          fillColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.blueAccent),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total ($selectedCount) :',
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              Row(
                children: [
                  if (totalBalanceSum2 > 0)
                    Text(
                      '+$totalBalanceSum2 ',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (totalBalanceSum1 > 0)
                    Text(
                      '-$totalBalanceSum1 ',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    ' ₹${totalSum.toString()}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
