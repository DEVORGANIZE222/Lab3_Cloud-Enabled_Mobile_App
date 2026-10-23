import 'package:flutter/foundation.dart';
import '../models/view_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService authService;
  final ViewState<UserModel?> _state = const InitialState();

  AuthViewModel({required this.authService});

  ViewState<UserModel?> get state => _state;
  UserModel? get currentUser => authService.currentUser;

  Future<void> signInWithGoogle() async {
    // TODO: Team implement sign in logic
  }

  Future<void> signOut() async {
    // TODO: Team implement sign out logic
  }
}
