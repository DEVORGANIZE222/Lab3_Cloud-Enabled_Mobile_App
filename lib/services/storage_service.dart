import 'dart:typed_data';

abstract class StorageService {
  Future<String> uploadRosterPdf({
    required String userId,
    required String teamId,
    required Uint8List pdfBytes,
    void Function(double progress)? onProgress,
  });
}

class FirebaseStorageService implements StorageService {
  @override
  Future<String> uploadRosterPdf({
    required String userId,
    required String teamId,
    required Uint8List pdfBytes,
    void Function(double progress)? onProgress,
  }) async => '';
}
