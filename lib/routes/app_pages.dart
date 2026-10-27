import 'package:get/get.dart';

import '../modules/auth/bindings/auth_bindings.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/enquiry/bindings/enquiry_binding.dart';
import '../modules/enquiry/views/enquiry_form_view.dart';
import '../modules/enquiry/views/enquiry_success_view.dart';
import '../modules/home/bindings/main_binding.dart';
import '../modules/home/views/main_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/portfolio/bindings/portfolio_binding.dart';
import '../modules/portfolio/views/case_study_detail_view.dart';
import '../modules/privacy/bindings/privacy_bindings.dart';
import '../modules/privacy/views/delete_account_view.dart';
import '../modules/privacy/views/privacy_settings_view.dart';
import '../modules/profile/bindings/profile_bindings.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/projects/bindings/project_bindings.dart';
import '../modules/projects/views/project_detail_view.dart';
import '../modules/projects/views/projects_view.dart';
import '../modules/quotations/bindings/quotation_bindings.dart';
import '../modules/quotations/views/my_enquiries_view.dart';
import '../modules/quotations/views/quotation_detail_view.dart';
import '../modules/services/bindings/services_binding.dart';
import '../modules/services/views/service_detail_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/support/bindings/support_bindings.dart';
import '../modules/support/views/create_ticket_view.dart';
import '../modules/support/views/ticket_detail_view.dart';
import '../modules/support/views/tickets_view.dart';
import 'app_routes.dart';
import 'middlewares.dart';

/// Central route table. Public routes need no middleware; everything with
/// customer data goes through [AuthMiddleware]. Firestore rules enforce the
/// same boundary on the server.
abstract final class AppPages {
  static List<GetPage<dynamic>> get routes => [
        GetPage(name: Routes.splash, page: () => const SplashView(), binding: SplashBinding()),
        GetPage(name: Routes.onboarding, page: () => const OnboardingView(), binding: OnboardingBinding()),
        GetPage(name: Routes.main, page: () => const MainView(), binding: MainBinding()),

        // Public
        GetPage(name: Routes.serviceDetail, page: () => const ServiceDetailView(), binding: ServiceDetailBinding()),
        GetPage(
          name: Routes.caseStudyDetail,
          page: () => const CaseStudyDetailView(),
          binding: CaseStudyDetailBinding(),
        ),
        GetPage(name: Routes.enquiry, page: () => const EnquiryFormView(), binding: EnquiryBinding()),
        GetPage(name: Routes.enquirySuccess, page: () => const EnquirySuccessView()),
        GetPage(name: Routes.login, page: () => const LoginView(), binding: LoginBinding()),
        GetPage(name: Routes.register, page: () => const RegisterView(), binding: RegisterBinding()),
        GetPage(
          name: Routes.forgotPassword,
          page: () => const ForgotPasswordView(),
          binding: ForgotPasswordBinding(),
        ),
        GetPage(name: Routes.privacy, page: () => const PrivacySettingsView(), binding: PrivacyBinding()),

        // Signed-in only
        ..._protected([
          GetPage(name: Routes.editProfile, page: () => const EditProfileView(), binding: EditProfileBinding()),
          GetPage(name: Routes.myEnquiries, page: () => const MyEnquiriesView(), binding: MyEnquiriesBinding()),
          GetPage(
            name: Routes.quotationDetail,
            page: () => const QuotationDetailView(),
            binding: QuotationDetailBinding(),
          ),
          GetPage(name: Routes.projects, page: () => const ProjectsView(), binding: ProjectsBinding()),
          GetPage(name: Routes.projectDetail, page: () => const ProjectDetailView(), binding: ProjectDetailBinding()),
          GetPage(name: Routes.notifications, page: () => const NotificationsView(), binding: NotificationsBinding()),
          GetPage(name: Routes.tickets, page: () => const TicketsView(), binding: TicketsBinding()),
          GetPage(name: Routes.createTicket, page: () => const CreateTicketView(), binding: CreateTicketBinding()),
          GetPage(name: Routes.ticketDetail, page: () => const TicketDetailView(), binding: TicketDetailBinding()),
          GetPage(name: Routes.deleteAccount, page: () => const DeleteAccountView(), binding: DeleteAccountBinding()),
        ]),
      ];

  static List<GetPage<dynamic>> _protected(List<GetPage<dynamic>> pages) => [
        for (final p in pages) p.copy(middlewares: [AuthMiddleware()]),
      ];

  /// Route names that require sign-in. Used by tests.
  static Set<String> get protectedRouteNames => {
        Routes.editProfile,
        Routes.myEnquiries,
        Routes.quotationDetail,
        Routes.projects,
        Routes.projectDetail,
        Routes.notifications,
        Routes.tickets,
        Routes.createTicket,
        Routes.ticketDetail,
        Routes.deleteAccount,
      };
}
