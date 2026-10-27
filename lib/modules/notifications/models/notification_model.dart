import '../../../core/utils/parsing.dart';

enum NotificationType { enquiry, quotation, project, support, general }

/// `users/{uid}/notifications/{id}` — written by Cloud Functions.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    this.route,
    this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, {required String id}) => NotificationModel(
        id: id,
        title: Parse.string(map, 'title', 'Update from Busiserve'),
        body: Parse.string(map, 'body'),
        type: NotificationType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => NotificationType.general,
        ),
        read: Parse.boolean(map, 'read'),
        route: Parse.optString(map, 'route'),
        createdAt: Parse.date(map, 'createdAt'),
      );

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool read;
  final String? route;
  final DateTime? createdAt;
}
