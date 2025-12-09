// ignore_for_file: unused_element

import 'package:_abm/constants/mytextfield.dart';
import 'package:_abm/utils/share_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dbmodels/models.dart';
import '../services/database_service.dart';

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
  // State for search and UI
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _balanceController = TextEditingController();
  bool _isSearching = false;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    // No local calculation needed, StreamBuilder handles it
  }

  // Helper to calculate totals from a list of students
  // Helper to calculate totals from a list of students
  Map<String, int> _calculateTotals(List<Student> students) {
    int total = 0;
    int count = 0;
    int surplus = 0; // + value
    int deficit = 0; // - value

    int amountModel = int.tryParse(widget.collection.amount) ?? 0;

    for (var student in students) {
      if (student.isSelected) {
        double paidAmount = student.balance ?? amountModel.toDouble();

        // Use amountModel (Expectation) for Total, so deficits don't reduce it.
        total += amountModel;

        int diff = (paidAmount - amountModel).toInt();

        if (diff > 0) {
          surplus += diff;
        } else if (diff < 0) {
          deficit += diff.abs();
        }
        count++;
      }
    }
    return {
      'totalSum': total,
      'surplus': surplus,
      'deficit': deficit,
      'selectedCount': count,
    };
  }

  void _toggleSelection(Student student) {
    // Optimistic Update
    setState(() {
      final newSelected = !student.isSelected;
      student.isSelected = newSelected;

      // Logic from original: if deselected, clear payment info
      if (!newSelected) {
        student.paymentMethod = '';
        student.balance = null;
      }
    });

    // Update in Supabase
    _databaseService.updateStudent(student).then((_) {
      // Optional: Show payment dialog if selected
      if (student.isSelected) {
        _showPaymentDialog(student);
      }
    });
  }

  void _showPaymentDialog(Student student) {
    _balanceController.text = student.balance?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        int? selector;
        // Pre-fill selector based on current method
        if (student.paymentMethod == 'GPay') selector = 1;
        if (student.paymentMethod == 'Liquid') selector = 2;

        return StatefulBuilder(// Use StatefulBuilder to update dialog state
            builder: (context, setDialogState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('GPay'),
                  trailing: selector == 1
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    setDialogState(() {
                      selector = 1;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Liquid'),
                  trailing: selector == 2
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () {
                    setDialogState(() {
                      selector = 2;
                    });
                  },
                ),
                MyTextField(
                  HintText: 'Type amount',
                  Controller: _balanceController,
                  LabelText: const Text('Correption'),
                  ObscureText: false,
                  KeyBoardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Update Student object properties
                  student.balance = double.tryParse(_balanceController.text);

                  if (selector == 1) {
                    student.paymentMethod = 'GPay';
                  } else if (selector == 2) {
                    student.paymentMethod = 'Liquid';
                  } else {
                    // Keep existing or clear? Original code: selector = null -> nothing
                    // Original code: } else { selector = null; } which didn't set paymentMethod to empty string explicitly unless logic above
                    // actually, original code logic was: if (selector == 1) ... else if (selector == 2) ... else { selector = null; }
                    // It didn't clear the payment method if selector was null, it just didn't set it.
                    // But effectively it retains whatever was set or nothing.
                    // If we assume user wants to clear if they untick? Button logic in dialog handles selection used checkmarks.
                  }

                  _databaseService.updateStudent(student);

                  _balanceController.clear();
                  Navigator.pop(context);

                  // Optimistic UI Update AFTER dialog closes
                  setState(() {});
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Student>>(
        stream: _databaseService.getStudentsStream(widget.collection.id!),
        builder: (context, snapshot) {
          List<Student> allStudents = [];
          List<Student> filteredStudents = [];

          if (snapshot.hasData) {
            allStudents = snapshot.data!;
            // Apply search filter here
            if (_searchController.text.isNotEmpty) {
              filteredStudents = allStudents
                  .where((student) => student.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .toList();
            } else {
              filteredStudents = allStudents;
            }
          }

          // Calculate totals based on ALL students (usually totals reflect the whole list, not just search results?
          // Original code used `_filteredStudents` inside `build` logic implicitly?
          // Original `_calculateTotal` iterated over `widget.collection.studentList` (ALL students).
          // So we calculate totals on allStudents.
          final totals = _calculateTotals(allStudents);

          // Prepare a Collection object with populated students for export functions
          // creating a temporary collection object
          final exportCollection = Collection(
              title: widget.collection.title,
              amount: widget.collection.amount,
              studentList: allStudents, // Must pass all students for export
              id: widget.collection.id);

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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (query) {
                        setState(() {}); // Trigger rebuild to filter
                      },
                      autofocus: true,
                    )
                  : Text(
                      '${widget.collection.title.toUpperCase()}  ${widget.collection.amount}₹',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _toggleSearch,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'text') {
                      shareCollectionAsText(exportCollection);
                    } else if (value == 'excel') {
                      generateAndShareExcel(exportCollection);
                    } else if (value == 'copy') {
                      copyCollectionToClipboard(context, exportCollection);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
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
                  child: snapshot.hasError
                      ? Center(child: Text('Error: ${snapshot.error}'))
                      : (snapshot.connectionState == ConnectionState.waiting)
                          ? const Center(child: CircularProgressIndicator())
                          : filteredStudents.isEmpty
                              ? Center(
                                  child: Text(
                                    'No student found',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 18),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    setState(() {});
                                  },
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    controller: _scrollController,
                                    itemCount: filteredStudents.length,
                                    itemBuilder: (context, index) {
                                      final student = filteredStudents[index];

                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Text(
                                              '${index + 1}.  ',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant),
                                            ),
                                            Text(
                                              student.name,
                                              style: GoogleFonts.electrolize(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface),
                                            ),
                                          ],
                                        ),
                                        subtitle: student
                                                .paymentMethod.isNotEmpty
                                            ? Row(
                                                children: [
                                                  Text(
                                                    'Payment: ${student.paymentMethod}  ',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          student.paymentMethod ==
                                                                  'GPay'
                                                              ? Colors.green
                                                              : Colors.blue,
                                                    ),
                                                  ),
                                                  if (student.balance != null)
                                                    Builder(builder: (context) {
                                                      double paid =
                                                          student.balance ??
                                                              0.0;
                                                      double expected =
                                                          double.tryParse(widget
                                                                  .collection
                                                                  .amount) ??
                                                              0.0;
                                                      int diff =
                                                          (paid - expected)
                                                              .toInt();
                                                      return Text(
                                                        diff > 0
                                                            ? '+$diff'
                                                            : '$diff',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: diff > 0
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      );
                                                    }),
                                                ],
                                              )
                                            : null,
                                        trailing: Checkbox(
                                          value: student.isSelected,
                                          onChanged: (bool? value) {
                                            _toggleSelection(student);
                                          },
                                          fillColor:
                                              MaterialStateProperty.resolveWith(
                                                  (states) =>
                                                      Colors.blueAccent),
                                        ),
                                      );
                                    },
                                  ),
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
                      'Total (${totals['selectedCount']}) :',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    Row(
                      children: [
                        if ((totals['surplus'] ?? 0) > 0)
                          Text(
                            '+${totals['surplus']} ',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if ((totals['deficit'] ?? 0) > 0)
                          Text(
                            '-${totals['deficit']} ',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          ' ₹${totals['totalSum']}',
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
        });
  }
}
