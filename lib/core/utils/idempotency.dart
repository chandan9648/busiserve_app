import 'package:uuid/uuid.dart';

/// Generates keys that let the backend recognise a repeated submission.
/// One key per form session; regenerate only after a confirmed success.
class IdempotencyKey {
  IdempotencyKey._();
  static const Uuid _uuid = Uuid();
  static String generate() => _uuid.v4();
  static final RegExp pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );
}
