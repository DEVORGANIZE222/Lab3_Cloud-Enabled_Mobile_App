import 'package:flutter/foundation.dart';

import '../models/view_state.dart';
import '../services/services.dart';

enum SignInStatus { idle, signingIn }

/// SCR_01: Google sign-in with cancel and wrong-domain handling.
class SignInViewModel extends ChangeNotifier {
  SignInViewModel(this._auth, this._analytics);

  final AuthService _auth;
  final AnalyticsService _analytics;

  SignInStatus status = SignInStatus.idle;

  /// Inline message under the button (cancelled, wrong domain, offline).
  AppFailure? message;

  Future<void> signIn() async {
    if (status == SignInStatus.signingIn) return;
    status = SignInStatus.signingIn;
    message = null;
    notifyListeners();
    try {
      await _auth.signInWithGoogle();
      await _analytics.logLogin(method: 'google');
    } on SignInCancelled {
      message = const AppFailure(
        'Sign-in cancelled',
        'Tap "Continue with Google" when you are ready.',
        code: 'cancelled',
      );
    } on WrongDomain catch (e) {
      message = AppFailure(
        'This is not an FPT account',
        'You chose ${e.email}. Sign in with your @fpt.edu.vn Google account.',
        code: 'wrong-domain',
      );
    } on AppFailure catch (f) {
      message = f;
    } catch (e) {
      message = AppFailure.unexpected(e);
    } finally {
      status = SignInStatus.idle;
      notifyListeners();
    }
  }
}
