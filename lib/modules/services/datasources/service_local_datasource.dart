import '../models/service_model.dart';

/// The service catalogue exactly as listed on https://www.busiserve.in
/// (October 2026). Used offline and whenever Firestore has no catalogue.
class ServiceLocalDataSource {
  const ServiceLocalDataSource();

  List<ServiceModel> getServices() => _catalogue;

  static const List<ServiceModel> _catalogue = [
    ServiceModel(
      id: 'web-development',
      title: 'Web Development',
      summary: 'Custom websites with responsive design.',
      focusAreas: ['Custom Websites', 'Responsive Design'],
      category: ServiceCategory.webAndApps,
      iconKey: 'web',
      order: 1,
    ),
    ServiceModel(
      id: 'app-development',
      title: 'App Development',
      summary: 'iOS, Android and hybrid apps.',
      focusAreas: ['iOS', 'Android', 'Hybrid Apps'],
      category: ServiceCategory.webAndApps,
      iconKey: 'app',
      order: 2,
    ),
    ServiceModel(
      id: 'cms-development',
      title: 'CMS Development',
      summary: 'WordPress, Drupal and content systems.',
      focusAreas: ['WordPress', 'Drupal', 'Content Systems'],
      category: ServiceCategory.business,
      iconKey: 'cms',
      order: 3,
    ),
    ServiceModel(
      id: 'crm-development',
      title: 'CRM Solutions',
      summary: 'Custom CRM and lead management.',
      focusAreas: ['Custom CRM', 'Lead Management'],
      category: ServiceCategory.business,
      iconKey: 'crm',
      order: 4,
    ),
    ServiceModel(
      id: 'wordpress-development',
      title: 'WordPress Development',
      summary: 'Business websites you can manage yourself.',
      focusAreas: ['Business Websites You Can Manage Yourself'],
      category: ServiceCategory.webAndApps,
      iconKey: 'wordpress',
      order: 5,
    ),
    ServiceModel(
      id: 'shopify-development',
      title: 'Shopify Development',
      summary: 'Online stores, products and checkout setup.',
      focusAreas: ['Online Stores', 'Products & Checkout Setup'],
      category: ServiceCategory.webAndApps,
      iconKey: 'shop',
      order: 6,
    ),
    ServiceModel(
      id: 'erp-development',
      title: 'ERP Development',
      summary: 'Custom ERP, inventory and business operations.',
      focusAreas: ['Custom ERP', 'Inventory & Business Operations'],
      category: ServiceCategory.business,
      iconKey: 'erp',
      order: 7,
    ),
    ServiceModel(
      id: 'ui-ux-design',
      title: 'UI/UX and Graphic Design',
      summary: 'Research, screen design and design systems.',
      focusAreas: ['Research', 'Screen Design & Design Systems'],
      category: ServiceCategory.design,
      iconKey: 'design',
      order: 8,
    ),
    ServiceModel(
      id: 'game-design',
      title: 'Game Design',
      summary: 'Game concepts, mechanics and player experiences.',
      focusAreas: ['Game Concepts', 'Mechanics & Player Experiences'],
      category: ServiceCategory.design,
      iconKey: 'game',
      order: 9,
    ),
    ServiceModel(
      id: 'api-development',
      title: 'API Development',
      summary: 'Custom APIs and third-party integrations.',
      focusAreas: ['Custom APIs', 'Third-Party Integrations'],
      category: ServiceCategory.business,
      iconKey: 'api',
      order: 10,
    ),
    ServiceModel(
      id: 'ai-agent-development',
      title: 'AI Agent Development',
      summary: 'AI assistants, business tools and knowledge integration.',
      focusAreas: ['AI Assistants', 'Business Tools & Knowledge Integration'],
      category: ServiceCategory.aiAutomation,
      iconKey: 'ai',
      order: 11,
    ),
    ServiceModel(
      id: 'automation-n8n',
      title: 'Automation (n8n)',
      summary: 'n8n workflows, app connections and task automation.',
      focusAreas: ['n8n Workflows', 'App Connections & Task Automation'],
      category: ServiceCategory.aiAutomation,
      iconKey: 'automation',
      order: 12,
    ),
  ];
}
