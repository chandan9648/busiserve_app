import 'package:cloud_firestore/cloud_firestore.dart';

import '../errors/app_exception.dart';

/// Per-user write limits. firestore.rules enforces the same numbers (see
/// `limitCooldown` / `limitPerDay`); keep the two in sync.
enum RateLimit {
  enquiry(cooldown: Duration(minutes: 2), perDay: 5, noun: 'enquiries'),
  ticket(cooldown: Duration(minutes: 2), perDay: 5, noun: 'support requests'),
  message(cooldown: Duration(seconds: 3), perDay: 200, noun: 'messages');

  const RateLimit({required this.cooldown, required this.perDay, required this.noun});
  final Duration cooldown;
  final int perDay;
  final String noun;
}

/// Spends one unit of a [RateLimit] in the same batch as the write it pays for.
///
/// The rules reject a limited create unless `users/{uid}/limits/{kind}` is
/// updated in the same commit with `lastId` set to the new document's id, so
/// the check below is only for a friendly message; the rules are the guard.
class RateLimits {
  RateLimits._();

  static const Duration window = Duration(hours: 24);

  static Future<void> spend(
    FirebaseFirestore db,
    WriteBatch batch, {
    required String uid,
    required RateLimit limit,
    required String docId,
  }) async {
    final ref = db.doc('users/$uid/limits/${limit.name}');
    final data = (await ref.get()).data();
    final now = DateTime.now();
    final windowStart = data?['windowStart'];
    final last = data?['last'];
    final count = (data?['count'] as num?)?.toInt() ?? 0;

    final inWindow = windowStart is Timestamp && now.isBefore(windowStart.toDate().add(window));
    if (!inWindow) {
      batch.set(ref, {
        'last': FieldValue.serverTimestamp(),
        'windowStart': FieldValue.serverTimestamp(),
        'count': 1,
        'lastId': docId,
      });
      return;
    }
    if (count >= limit.perDay) {
      throw RateLimitException(
        "You've reached today's limit of ${limit.perDay} ${limit.noun}. "
        'Try again tomorrow, or call or email us.',
      );
    }
    if (last is Timestamp && now.isBefore(last.toDate().add(limit.cooldown))) {
      throw const RateLimitException('Please wait a moment before sending again.');
    }
    batch.set(ref, {
      'last': FieldValue.serverTimestamp(),
      'windowStart': windowStart,
      'count': count + 1,
      'lastId': docId,
    });
  }
}
