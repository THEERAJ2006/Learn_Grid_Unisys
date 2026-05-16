import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Temporary current-user id.
///
/// Until onboarding/auth/device-id is implemented, we use a stable local id to
/// scope progress and engagement.
final currentUserIdProvider = Provider<String>((ref) => 'local-user');
