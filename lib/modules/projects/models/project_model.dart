import '../../../core/utils/parsing.dart';
import '../../../core/constants/status_tone.dart';

enum ProjectStatus {
  planning('Planning', StatusTone.info),
  inProgress('In progress', StatusTone.info),
  review('Your review', StatusTone.warning),
  onHold('On hold', StatusTone.neutral),
  completed('Completed', StatusTone.success);

  const ProjectStatus(this.label, this.tone);
  final String label;
  final StatusTone tone;

  static ProjectStatus fromKey(String? key) => switch (key) {
        'in_progress' => ProjectStatus.inProgress,
        'review' => ProjectStatus.review,
        'on_hold' => ProjectStatus.onHold,
        'completed' => ProjectStatus.completed,
        _ => ProjectStatus.planning,
      };
}

/// `projects/{id}` — staff-managed, readable by the owning customer.
class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    this.summary,
    this.serviceId,
    this.managerName,
    this.startDate,
    this.targetDate,
    this.updatedAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, {required String id}) => ProjectModel(
        id: id,
        title: Parse.string(map, 'title', 'Project'),
        status: ProjectStatus.fromKey(Parse.optString(map, 'status')),
        progress: Parse.integer(map, 'progress').clamp(0, 100).toInt(),
        summary: Parse.optString(map, 'summary'),
        serviceId: Parse.optString(map, 'serviceId'),
        managerName: Parse.optString(map, 'managerName'),
        startDate: Parse.date(map, 'startDate'),
        targetDate: Parse.date(map, 'targetDate'),
        updatedAt: Parse.date(map, 'updatedAt'),
      );

  final String id;
  final String title;
  final ProjectStatus status;

  /// 0–100, set by staff.
  final int progress;
  final String? summary;
  final String? serviceId;
  final String? managerName;
  final DateTime? startDate;
  final DateTime? targetDate;
  final DateTime? updatedAt;
}

enum MilestoneStatus {
  pending('Upcoming'),
  inProgress('In progress'),
  done('Done');

  const MilestoneStatus(this.label);
  final String label;

  static MilestoneStatus fromKey(String? key) => switch (key) {
        'in_progress' => MilestoneStatus.inProgress,
        'done' => MilestoneStatus.done,
        _ => MilestoneStatus.pending,
      };
}

/// `projects/{id}/milestones/{milestoneId}`
class MilestoneModel {
  const MilestoneModel({
    required this.id,
    required this.title,
    required this.status,
    required this.order,
    this.description,
    this.dueDate,
    this.completedAt,
  });

  factory MilestoneModel.fromMap(Map<String, dynamic> map, {required String id}) => MilestoneModel(
        id: id,
        title: Parse.string(map, 'title', 'Milestone'),
        status: MilestoneStatus.fromKey(Parse.optString(map, 'status')),
        order: Parse.integer(map, 'order'),
        description: Parse.optString(map, 'description'),
        dueDate: Parse.date(map, 'dueDate'),
        completedAt: Parse.date(map, 'completedAt'),
      );

  final String id;
  final String title;
  final MilestoneStatus status;
  final int order;
  final String? description;
  final DateTime? dueDate;
  final DateTime? completedAt;
}
