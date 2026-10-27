import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/services/auth_session.dart';
import '../datasources/project_remote_datasource.dart';
import '../models/project_model.dart';

class ProjectRepository {
  ProjectRepository({required ProjectRemoteDataSource remote, required AuthSession session})
      : _remote = remote,
        _session = session;

  final ProjectRemoteDataSource _remote;
  final AuthSession _session;

  Stream<List<ProjectModel>> watchMine() =>
      guardStream(_remote.watchForCustomer(_session.requireUid()), context: 'watch projects');

  Stream<ProjectModel> watch(String id) {
    _session.requireUid();
    return guardStream(
      _remote.watchById(id).map((p) => p ?? (throw const NotFoundException('This project is no longer available.'))),
      context: 'watch project',
    );
  }

  Stream<List<MilestoneModel>> watchMilestones(String projectId) {
    _session.requireUid();
    return guardStream(_remote.watchMilestones(projectId), context: 'watch milestones');
  }
}
