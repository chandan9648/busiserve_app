import '../../../core/utils/parsing.dart';

/// Customer profile stored at `users/{uid}`. The document also carries a
/// `role` field that the security rules read, but only an admin may write it,
/// so this model deliberately neither parses nor sends it.
class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.company,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {required String uid}) => UserModel(
        uid: uid,
        name: Parse.string(map, 'name'),
        email: Parse.string(map, 'email'),
        phone: Parse.optString(map, 'phone'),
        company: Parse.optString(map, 'company'),
        createdAt: Parse.date(map, 'createdAt'),
      );

  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? company;
  final DateTime? createdAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return email.isNotEmpty ? email[0].toUpperCase() : '?';
    return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
  }

  /// Fields the owner may write (mirrors firestore.rules).
  Map<String, dynamic> toEditableMap() => {
        'name': name.trim(),
        'phone': phone?.trim().isEmpty ?? true ? null : phone!.trim(),
        'company': company?.trim().isEmpty ?? true ? null : company!.trim(),
      };
}
