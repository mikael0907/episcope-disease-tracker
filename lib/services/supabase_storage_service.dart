//lib/services/supabase_storage_service.dart



import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String bucketName = 'case_photos';

  Future<String?> uploadPhoto(File file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = '$userId/$timestamp.$extension';

      final mimeType = lookupMimeType(file.path);
      
      debugPrint('📤 Uploading file: $fileName');
      debugPrint('📦 File size: ${await file.length()} bytes');
      debugPrint('🎨 MIME type: $mimeType');

      final bytes = await file.readAsBytes();

      final uploadPath = await _supabase.storage.from(bucketName).uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(
          contentType: mimeType,
          upsert: false,
        ),
      );

      debugPrint('✅ Upload successful: $uploadPath');

      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(fileName);
      
      debugPrint('🔗 Public URL: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }

  Future<bool> deletePhoto(String photoUrl) async {
    try {
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      
      final bucketIndex = pathSegments.indexOf(bucketName);
      if (bucketIndex == -1) {
        debugPrint('❌ Invalid photo URL: bucket not found');
        return false;
      }
      
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      debugPrint('🗑️ Deleting file: $filePath');

      await _supabase.storage.from(bucketName).remove([filePath]);
      
      debugPrint('✅ File deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      return false;
    }
  }

  Future<List<String>> deleteMultiplePhotos(List<String> photoUrls) async {
    final failedDeletions = <String>[];
    
    for (final url in photoUrls) {
      final success = await deletePhoto(url);
      if (!success) {
        failedDeletions.add(url);
      }
    }
    
    return failedDeletions;
  }
}