import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dbmodels/models.dart';
import '../services/database_service.dart';
import 'create_list_screen.dart';
import 'studentlist.dart';

class CustomListsScreen extends StatefulWidget {
  const CustomListsScreen({super.key});

  @override
  State<CustomListsScreen> createState() => _CustomListsScreenState();
}

class _CustomListsScreenState extends State<CustomListsScreen> {
  final DatabaseService _databaseService = DatabaseService();

  void _navigateToCreateList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateListScreen()),
    );
  }

  Future<void> _deleteCollection(int id) async {
    try {
      await _databaseService.deleteCollection(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('List deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting list: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Custom Lists'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateList,
            tooltip: 'Create New List',
          ),
        ],
      ),
      body: StreamBuilder<List<Collection>>(
        stream: _databaseService.getCollectionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final collections = snapshot.data ?? [];

          if (collections.isEmpty) {
            return const Center(
              child: Text('No lists found. Create one!'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: collections.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final collection = collections[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Theme.of(context).cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    collection.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      StreamBuilder<Map<String, int>>(
                          stream: _databaseService
                              .getCollectionStatsStream(collection.id!),
                          builder: (context, statsSnapshot) {
                            if (statsSnapshot.hasData) {
                              final total = statsSnapshot.data!['total'];
                              final paid = statsSnapshot.data!['paid'];
                              return Text('$paid / $total Students Paid');
                            }
                            return const SizedBox.shrink();
                          }),
                      Text('Amount: ₹${collection.amount}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      if (collection.id != null) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Delete List?'),
                                  content: const Text(
                                      'This will delete the list and all student data within it.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteCollection(collection.id!);
                                        },
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                ));
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentListScreen(
                          collection: collection,
                          title: collection.title,
                          amount: collection.amount,
                          studentsWithLessThanAmount: [],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateList,
        child: const Icon(Icons.add),
      ),
    );
  }
}
