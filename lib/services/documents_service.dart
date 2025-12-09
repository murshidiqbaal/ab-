import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucketName = 'documents';
  final String _tableName = 'documents';

  // 1. Upload Document
  Future<void> uploadDocument(File file) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}';
      final path = fileName;

      // Upload to Storage
      await _client.storage.from(_bucketName).upload(path, file);

      // Get Public URL
      final fileUrl = _client.storage.from(_bucketName).getPublicUrl(path);

      // Insert into Table
      await _client.from(_tableName).insert({
        'name': file.path.split(Platform.pathSeparator).last,
        'url': fileUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  // 2. Fetch Documents (Real-time Stream)
  Stream<List<Map<String, dynamic>>> getDocumentsStream() {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id']).order('created_at', ascending: false);
  }

  // 3. Delete Document
  Future<void> deleteDocument(int id, String fileUrl) async {
    try {
      // Extract filename from URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.last;

      // Remove from storage
      await _client.storage.from(_bucketName).remove([fileName]);

      // Remove from table
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }
}
