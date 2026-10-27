import '../../../core/utils/parsing.dart';

enum ServiceCategory {
  webAndApps('Web & Apps'),
  business('CMS, CRM & ERP'),
  aiAutomation('AI & Automation'),
  design('Design');

  const ServiceCategory(this.label);
  final String label;

  static ServiceCategory fromKey(String? key) =>
      ServiceCategory.values.firstWhere((c) => c.name == key, orElse: () => ServiceCategory.webAndApps);
}

/// A Busiserve service. `id` equals the slug used on busiserve.in/services/<id>.
class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.focusAreas,
    required this.category,
    required this.iconKey,
    required this.order,
    this.description,
    this.highlights = const [],
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, {String? id}) => ServiceModel(
        id: id ?? Parse.requireString(map, 'id'),
        title: Parse.requireString(map, 'title'),
        summary: Parse.string(map, 'summary'),
        focusAreas: Parse.stringList(map, 'focusAreas'),
        category: ServiceCategory.fromKey(Parse.optString(map, 'category')),
        iconKey: Parse.string(map, 'iconKey', 'web'),
        order: Parse.integer(map, 'order', 999),
        description: Parse.optString(map, 'description'),
        highlights: Parse.stringList(map, 'highlights'),
      );

  final String id;
  final String title;
  final String summary;
  final List<String> focusAreas;
  final ServiceCategory category;
  final String iconKey;
  final int order;

  /// Long-form text. Only present when supplied by staff via Firestore.
  final String? description;
  final List<String> highlights;

  String get websiteUrl => 'https://www.busiserve.in/services/$id';

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'summary': summary,
        'focusAreas': focusAreas,
        'category': category.name,
        'iconKey': iconKey,
        'order': order,
        if (description != null) 'description': description,
        'highlights': highlights,
      };
}
