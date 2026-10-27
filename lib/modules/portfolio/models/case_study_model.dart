import '../../../core/utils/parsing.dart';

class CaseStudyModel {
  const CaseStudyModel({
    required this.id,
    required this.title,
    required this.industry,
    required this.summary,
    required this.order,
    this.challenge,
    this.solution,
    this.results = const [],
    this.technologies = const [],
  });

  factory CaseStudyModel.fromMap(Map<String, dynamic> map, {String? id}) => CaseStudyModel(
        id: id ?? Parse.requireString(map, 'id'),
        title: Parse.requireString(map, 'title'),
        industry: Parse.string(map, 'industry', 'Technology'),
        summary: Parse.string(map, 'summary'),
        order: Parse.integer(map, 'order', 999),
        challenge: Parse.optString(map, 'challenge'),
        solution: Parse.optString(map, 'solution'),
        results: Parse.stringList(map, 'results'),
        technologies: Parse.stringList(map, 'technologies'),
      );

  final String id;
  final String title;
  final String industry;
  final String summary;
  final int order;

  /// Optional long-form sections, supplied by staff through Firestore.
  final String? challenge;
  final String? solution;
  final List<String> results;
  final List<String> technologies;

  String get websiteUrl => 'https://www.busiserve.in/case-studies/$id';
}
