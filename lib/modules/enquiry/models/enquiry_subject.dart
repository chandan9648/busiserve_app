/// The subject options from the contact form on busiserve.in/contact.
/// Service subjects use the same id as the service slug.
class EnquirySubject {
  const EnquirySubject(this.id, this.label);
  final String id;
  final String label;

  static const general = EnquirySubject('general', 'General Inquiry');
  static const partnership = EnquirySubject('partnership', 'Partnership');

  static const List<EnquirySubject> all = [
    general,
    EnquirySubject('web-development', 'Web Development'),
    EnquirySubject('wordpress-development', 'WordPress Website Development'),
    EnquirySubject('shopify-development', 'Shopify Store Development'),
    EnquirySubject('app-development', 'Mobile App Development'),
    EnquirySubject('game-design', 'Game Design and Prototyping'),
    EnquirySubject('ui-ux-design', 'UI/UX and Graphic Design'),
    EnquirySubject('cms-development', 'CMS Development'),
    EnquirySubject('crm-development', 'CRM Development'),
    EnquirySubject('erp-development', 'ERP Development'),
    EnquirySubject('api-development', 'API Development'),
    EnquirySubject('ai-agent-development', 'AI Agent Development'),
    EnquirySubject('automation-n8n', 'Automation (n8n)'),
    partnership,
  ];

  static EnquirySubject? byId(String? id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  static String labelFor(String id) => byId(id)?.label ?? 'General Inquiry';

  @override
  bool operator ==(Object other) => other is EnquirySubject && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
