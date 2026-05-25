import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  /// Creates a new account and saves onboarding profile data.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String? goal,
    required List<String> habits,
    required String? frequency,
    required String? timeOfDay,
  }) async {
    // Pass onboarding data as user metadata so the handle_new_user trigger
    // can populate the profiles row atomically — no race condition with
    // the profileProvider fetching a blank row before our upsert lands.
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'goal': goal,
        'habits': habits,
        'frequency': frequency,
        'time_of_day': timeOfDay,
      },
    );

    if (response.user != null) {
      // Belt-and-suspenders: upsert in case the trigger didn't capture metadata.
      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'name': name,
        'goal': goal,
        'preferred_habit_categories': habits,
        'frequency': frequency,
        'time_of_day': timeOfDay,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;
}
