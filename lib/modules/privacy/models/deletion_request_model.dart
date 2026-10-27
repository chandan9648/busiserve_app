/// Sent to the `deleteAccount` Cloud Function.
class DeletionRequest {
  const DeletionRequest({this.reason});
  final String? reason;

  Map<String, dynamic> toPayload() => {
        if (reason != null && reason!.trim().isNotEmpty) 'reason': reason!.trim(),
      };
}
