import 'dart:io';

import 'package:_abm/dbmodels/models.dart';
import 'package:_abm/presentation/mydrawer.dart';
import 'package:_abm/services/memories_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  final List<Student> studentsWithLessThanAmount;

  const HomePage({super.key, required this.studentsWithLessThanAmount});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MemoriesService _memoriesService = MemoriesService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadMemory() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        await _memoriesService.uploadMemory(File(image.path));
        setState(() {}); // Trigger rebuild
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory uploaded successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteMemory(int id, String imageUrl) async {
    try {
      await _memoriesService.deleteMemory(id, imageUrl);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memory deleted successfully'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return _DarkHomePage(
        uploadMemory: _uploadMemory,
        deleteMemory: _deleteMemory,
        memoriesService: _memoriesService,
      );
    } else {
      return _LightHomePage(
        uploadMemory: _uploadMemory,
        deleteMemory: _deleteMemory,
        memoriesService: _memoriesService,
      );
    }
  }
}

// ==========================================
// LIGHT MODE UI (Early Design)
// ==========================================
class _LightHomePage extends StatelessWidget {
  final VoidCallback uploadMemory;
  final Function(int, String) deleteMemory;
  final MemoriesService memoriesService;

  const _LightHomePage({
    required this.uploadMemory,
    required this.deleteMemory,
    required this.memoriesService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('A B M', style: TextStyle(color: Colors.black)),
        ),
        backgroundColor: const Color.fromRGBO(240, 240, 240, 1.0),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      drawer: MyDrawer(),
      backgroundColor: Colors.white70,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Memories',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: uploadMemory,
                  icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                  label:
                      const Text('Add', style: TextStyle(color: Colors.blue)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: memoriesService.getMemoriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.blue));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading memories'));
                }

                final memories = snapshot.data ?? [];

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    final memory = memories[index];
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Delete Memory"),
                            content: const Text(
                                "Are you sure you want to delete this memory?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  deleteMemory(
                                      memory['id'], memory['image_url']);
                                },
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: Image.network(
                              memory['image_url'],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.grey.shade300,
                          image: DecorationImage(
                            image: NetworkImage(memory['image_url']),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
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
    );
  }
}

// ==========================================
// DARK MODE UI (Aesthetic Design)
// ==========================================
class _DarkHomePage extends StatelessWidget {
  final VoidCallback uploadMemory;
  final Function(int, String) deleteMemory;
  final MemoriesService memoriesService;

  const _DarkHomePage({
    required this.uploadMemory,
    required this.deleteMemory,
    required this.memoriesService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'A B M',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027), // Deep Blue/Black
              Color(0xFF203A43),
              Color(0xFF2C5364), // Teal-ish Grey
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100), // Spacing for AppBar

            // Hero / Welcome Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Powered by A B M',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gallery',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: IconButton(
                      onPressed: uploadMemory,
                      icon: const Icon(Icons.add_a_photo_outlined,
                          color: Colors.white),
                      tooltip: 'Add Memory',
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Memories Grid
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: memoriesService.getMemoriesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading memories',
                        style: GoogleFonts.outfit(color: Colors.redAccent),
                      ),
                    );
                  }

                  final memories = snapshot.data ?? [];

                  if (memories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined,
                              size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            "No memories yet.",
                            style: GoogleFonts.outfit(
                                color: Colors.white54, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          2, // 2 columns looks better for "polariod" style
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E1E),
                              title: Text("Delete Memory",
                                  style:
                                      GoogleFonts.outfit(color: Colors.white)),
                              content: Text(
                                "Are you sure you want to delete this memory?",
                                style:
                                    GoogleFonts.outfit(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text("Cancel",
                                      style: GoogleFonts.outfit(
                                          color: Colors.white54)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    deleteMemory(
                                        memory['id'], memory['image_url']);
                                  },
                                  child: Text("Delete",
                                      style: GoogleFonts.outfit(
                                          color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(20),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // The Frame
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 50),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          child: InteractiveViewer(
                                            minScale: 0.1,
                                            maxScale: 5.0,
                                            child: Image.network(
                                              memory['image_url'],
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.broken_image,
                                                      size: 50),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Memories',
                                          style: GoogleFonts.caveat(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Close Button
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 1. Image with Shimmer Loading
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(
                                memory['image_url'],
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[800]!,
                                    highlightColor: Colors.grey[600]!,
                                    child: Container(
                                      color: Colors.grey[800],
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[900],
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.white54),
                                ),
                              ),
                            ),
                            // 2. Gradient Overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                  stops: const [0.7, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
