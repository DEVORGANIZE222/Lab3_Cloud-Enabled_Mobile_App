import 'dart:async';
import '../models/student.dart';
import '../services/services.dart';

/// Firebase Authentication + Google Sign-In implementation.
///
/// Lab 3 Requirement:
/// - Restrict sign-in to domain @fpt.edu.vn.
/// - Persist session with FirebaseAuth.
class FirebaseAuthService implements AuthService {
  final _controller = StreamController<Student?>.broadcast();
  Student? _currentStudent;

  @override
  Stream<Student?> authStateChanges() => _controller.stream;

  @override
  Student? get currentStudent => _currentStudent;

  @override
  Future<Student> signInWithGoogle() async {
    // TODO: Implement GoogleSignIn + FirebaseAuth.instance.signInWithCredential
    throw UnimplementedError('FirebaseAuthService.signInWithGoogle not implemented yet');
  }

  @override
  Future<void> signOut() async {
    // TODO: Implement FirebaseAuth.instance.signOut() + GoogleSignIn.signOut()
    _currentStudent = null;
    _controller.add(null);
  }
}
