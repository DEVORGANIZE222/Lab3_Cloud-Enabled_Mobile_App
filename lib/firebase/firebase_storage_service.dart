import 'dart:async';
import 'dart:io';
import '../services/services.dart';

/// Firebase Cloud Storage implementation for reports export.
///
/// Requirement: Upload to `reports/{uid}/{fileName}` under security rules.
class FirebaseStorageService implements StorageService {
  @override
  Stream<UploadProgress> uploadReport({required File file, required String uid}) {
    // TODO: Implement FirebaseStorage.instance.ref('reports/$uid/...').putFile(...)
    final controller = StreamController<UploadProgress>();
    // placeholder emitting 0% then finishing
    return controller.stream;
  }
}
