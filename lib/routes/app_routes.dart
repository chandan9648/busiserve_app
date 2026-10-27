/// Every named route in the app. Use the helpers for parameterised paths.
abstract final class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const main = '/main';

  static const serviceDetail = '/services/:id';
  static const caseStudyDetail = '/case-studies/:id';

  static const enquiry = '/enquiry';
  static const enquirySuccess = '/enquiry-success';

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const editProfile = '/edit-profile';
  static const myEnquiries = '/my-enquiries';
  static const quotationDetail = '/quotations/:id';
  static const projects = '/projects';
  static const projectDetail = '/projects/:id';
  static const notifications = '/notifications';
  static const tickets = '/tickets';
  static const createTicket = '/new-ticket';
  static const ticketDetail = '/tickets/:id';
  static const privacy = '/privacy';
  static const deleteAccount = '/delete-account';

  static String serviceDetailPath(String id) => '/services/${Uri.encodeComponent(id)}';
  static String caseStudyPath(String id) => '/case-studies/${Uri.encodeComponent(id)}';
  static String quotationPath(String id) => '/quotations/${Uri.encodeComponent(id)}';
  static String projectPath(String id) => '/projects/${Uri.encodeComponent(id)}';
  static String ticketPath(String id) => '/tickets/${Uri.encodeComponent(id)}';
}
