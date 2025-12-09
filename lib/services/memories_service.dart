import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class MemoriesService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucketName = 'memories';
  final String _tableName = 'memories';

  // 1. Upload Image
  Future<void> uploadMemory(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$fileName';

      // Upload to Storage
      await _client.storage.from(_bucketName).upload(path, imageFile);

      // Get Public URL
      final imageUrl = _client.storage.from(_bucketName).getPublicUrl(path);

      // Insert into Table
      await _client.from(_tableName).insert({
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error uploading memory: $e');
    }
  }

  // 2. Fetch Memories (Real-time Stream)
  Stream<List<Map<String, dynamic>>> getMemoriesStream() {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id']).order('created_at', ascending: false);
  }

  // Fetch as Future (optional)
  Future<List<Map<String, dynamic>>> getMemories() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);
    return response;
  }

  // 3. Delete Memory
  Future<void> deleteMemory(int id, String imageUrl) async {
    try {
      // 1. Delete from Storage
      // Extract filename from URL (assuming standard Supabase URL structure)
      // URL: .../storage/v1/object/public/memories/FILENAME.jpg
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.last;

      await _client.storage.from(_bucketName).remove([fileName]);

      // 2. Delete from Table
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting memory: $e');
    }
  }
}
