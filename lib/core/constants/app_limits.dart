/// Input limits shared by client validators. The backend enforces the same
/// values independently (firebase/functions/src/validation.ts).
class AppLimits {
  AppLimits._();
  static const int nameMin = 2;
  static const int nameMax = 80;
  static const int messageMin = 10;
  static const int messageMax = 3000;
  static const int passwordMin = 8;
  static const int companyMax = 120;
  static const int ticketSubjectMax = 120;
  static const int chatMessageMax = 2000;
  static const Duration requestTimeout = Duration(seconds: 20);
}
