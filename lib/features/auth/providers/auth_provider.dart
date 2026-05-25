import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((_) => AuthService());

final authStateProvider = StreamProvider<AuthState>(
  (ref) => Supabase.instance.client.auth.onAuthStateChange,
);

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.session?.user
      ?? Supabase.instance.client.auth.currentUser;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Seeded from main() before runApp. Tracks whether the user has seen
/// the onboarding flow, regardless of login state.
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// Holds onboarding answers while the user is on the sign-up screen.
/// Stored in a provider instead of GoRouter `extra` so it survives
/// router rebuilds triggered by the Supabase auth stream.
final pendingOnboardingDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

/// Fetches the current user's profile row from Supabase.
/// autoDispose ensures the provider re-fetches fresh data each time the
/// ProfileScreen is opened, and discards stale data on sign-out.
final profileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();
});
