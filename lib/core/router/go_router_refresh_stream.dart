import 'dart:async';
import 'package:flutter/foundation.dart';

/// Bridges a Stream into a ChangeNotifier so GoRouter's refreshListenable
/// re-evaluates redirect callbacks whenever the stream emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
