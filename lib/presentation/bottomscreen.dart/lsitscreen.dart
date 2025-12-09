import 'package:_abm/presentation/mydrawer.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../constants/mytextfield.dart';
import '../../dbmodels/models.dart';
import '../studentlist.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final Box<Collection> _collectionsBox =
      Hive.box<Collection>('collectionsBox');

  String selectedFilter = 'All'; // ✅ Filter control (All, Paid, Unpaid)

  final List<String> studentNames = [
    'ABHIJITH MOHANAN',
    'ABHINAV BIJUKUMAR',
    'ABIN SUDHAKARAN',
    'ADHARSH VARGHESE JOJO',
    'ADHIN GEORGE',
    'AIMAL JINOY',
    'AJO PRASAD',
    'ALAN JOY',
    'ALBIN BIJU',
    'ALBIN SANY',
    'ANAND S JACOB',
    'ANN MARIYA BIJU',
    'ASWIN MANOJ',
    'BASIL ELDHO',
    'BASIL GEORGE',
    'BESTO VARGHESE B',
    'BINEX SHIBU THOMAS',
    'CHRISTO BENNY',
    'DAVID SEBASTIAN GIGI',
    'DHANANJAY M JAYAN',
    'EDVIN JOHN',
    'GOUTHAM GOPAN',
    'HEAVEN JOSE',
    'IBNU EBRAHIM',
    'JACOB LAL',
    'JAYADEV BIJU',
    'JOYES JOSEPH TOJI',
    'JUDE GIGIMON',
    'LEO SAN GEORGE',
    'MAHIN KABEER',
    'MALAVIKA BIJU',
    'MIJU SHAJI',
    'MURSHID IQBAAL.K.M',
    'NIKHIL V',
    'NIKIL SHAJI',
    'NOYAL BINOY',
    'SANJAY SUNIL',
    'SREEHARI UNNIKRISHNAN',
    'SUBIN V S',
    'VINAYAK SURESH',
    'ALINA SAJAN',
    'AMEENA T A',
    'ANGEL MARY SAJI',
    'ANJAL CHANDRAN',
    'APARNA MOHAN',
    'ASHNA HAMEED',
    'DEVIKA DASAN',
    'DEVU S NAIR',
    'DINAH BIJU',
    'DRISHYA ANTONY',
    'ERFANA RAHMAN',
    'FASNA ASHRAF',
    'FATHIMA SHARIEF',
    'HANNAH ELIZABETH REGI',
    'JESNA JOY',
    'KARTHKA S',
    'MEENAKSHI ',
    'MUFEEDHA MAHEEN',
    'NANDHANA AJITH',
    'NEENU O S',
    'RAHMATH RABIYA.KM',
    'REES JAMES',
    'RISNA N A',
    'ROSE MARY BENNY',
    'SONA JOY',
    'SREELEKSHMI B R',
    'FAYAZ P AJIMS',
  ];

  void _addItem(String name, String amount) {
    final List<Student> students = studentNames
        .map((studentName) => Student(
              name: studentName,
              isSelected: false,
              studentsWithLessThanAmount: [],
              balance: 0.0,
              paymentMethod: '',
            ))
        .toList();

    final collection = Collection(
      title: name,
      amount: amount,
      studentList: students,
    );

    _collectionsBox.add(collection);
    setState(() {});
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Collection'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            MyTextField(
              HintText: 'Enter title',
              Controller: _titleController,
              LabelText: const Text('Title'),
              ObscureText: false,
              KeyBoardType: TextInputType.text,
            ),
            const SizedBox(height: 10),
            MyTextField(
              HintText: 'Enter amount',
              Controller: _amountController,
              LabelText: const Text('Amount'),
              ObscureText: false,
              KeyBoardType: TextInputType.number,
            ),
          ]),
          actions: [
            SlideAction(
              text: 'Slide to create',
              textStyle: const TextStyle(color: Colors.white, fontSize: 16),
              innerColor: Colors.purple,
              outerColor: Colors.purple.shade300,
              sliderButtonIcon: const Icon(Icons.create),
              onSubmit: () {
                if (_titleController.text.isNotEmpty &&
                    _amountController.text.isNotEmpty) {
                  _addItem(_titleController.text, _amountController.text);
                  _titleController.clear();
                  _amountController.clear();
                  Navigator.of(context).pop();
                }
                return null;
              },
              animationDuration: const Duration(milliseconds: 800),
            ),
          ],
        );
      },
    );
  }

  void _shareCollection(Collection collection) {
    String text =
        '*Collection:* ${collection.title}\n*Amount:* ${collection.amount}\n*Selected:* ${collection.studentList.where((s) => s.isSelected).length}/${collection.studentList.length}\n\n';
    for (int i = 0; i < collection.studentList.length; i++) {
      var student = collection.studentList[i];
      String status = student.isSelected ? 'Paid' : 'Pending';
      String paymentInfo =
          student.paymentMethod.isNotEmpty ? '(${student.paymentMethod})' : '';
      text += '${i + 1}. ${student.name} : $status $paymentInfo\n';
    }
    Share.share(text, subject: 'Collection Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Center(
          child: AvatarGlow(
            duration: const Duration(seconds: 2),
            glowColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.blueAccent
                : const Color.fromARGB(255, 224, 207, 50),
            child: Text(
              'A B M',
              style: GoogleFonts.anaheim(
                  color: Theme.of(context).appBarTheme.titleTextStyle?.color ??
                      Colors.black87),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ✅ Filter dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Filter: ',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: ['All', 'Paid', 'Unpaid']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _collectionsBox.listenable(),
              builder: (context, Box<Collection> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('No collections added.'));
                }

                final collections = box.values.toList();

                return ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(),
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];

                    // ✅ Filter logic
                    final paidCount = collection.studentList
                        .where((s) => s.isSelected)
                        .length;

                    if (selectedFilter == 'Paid' && paidCount == 0) {
                      return const SizedBox.shrink();
                    }
                    if (selectedFilter == 'Unpaid' &&
                        paidCount == collection.studentList.length) {
                      return const SizedBox.shrink();
                    }

                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              _shareCollection(collection);
                            },
                            backgroundColor: Colors.blue,
                            icon: Icons.share,
                            // label: 'Share',
                          ),
                          SlidableAction(
                            onPressed: ((context) async {
                              await box.deleteAt(index);
                              setState(() {});
                            }),
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).cardColor,
                          ),
                          child: ListTile(
                            textColor:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            trailing: Text(
                              '₹${collection.amount}',
                              style: GoogleFonts.poppins(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                            title: Text(
                              collection.title,
                              style: GoogleFonts.bodoniModa(
                                  fontSize: 24,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                            subtitle: Text(
                              '$paidCount / ${collection.studentList.length}',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => StudentListScreen(
                                  collection: collection,
                                  title: collection.title,
                                  amount: collection.amount,
                                  studentsWithLessThanAmount: [],
                                ),
                              ));
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
