import '../models/user_model.dart';

abstract class AuthService {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  String? get currentUserId;

  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  @override
  Stream<UserModel?> get authStateChanges => const Stream.empty();

  @override
  UserModel? get currentUser => null;

  @override
  String? get currentUserId => null;

  @override
  Future<UserModel> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}
}
