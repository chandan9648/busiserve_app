import '../models/case_study_model.dart';

/// Case studies as summarised on https://www.busiserve.in/case-studies.
/// Confirm with the business that these may appear in the app before release.
class PortfolioLocalDataSource {
  const PortfolioLocalDataSource();

  List<CaseStudyModel> getCaseStudies() => const [
        CaseStudyModel(
          id: 'fintech-app-revolution',
          title: 'Fintech App Revolution',
          industry: 'Finance',
          summary:
              'Re-architected a legacy financial application for a global bank, resulting '
              'in a 40% increase in user retention and a significant reduction in '
              'transaction latency.',
          order: 1,
        ),
        CaseStudyModel(
          id: 'ecommerce-scale-up',
          title: 'E-commerce Scale-up',
          industry: 'Retail',
          summary:
              'Developed a robust, scalable infrastructure for a rapidly growing online '
              'retailer, ensuring seamless performance during peak holiday traffic spikes.',
          order: 2,
        ),
        CaseStudyModel(
          id: 'enterprise-cms-migration',
          title: 'Enterprise CMS Migration',
          industry: 'Technology',
          summary:
              "Successfully migrated a multinational corporation's complex content "
              'ecosystem to a modern headless CMS, improving editorial workflows by 60%.',
          order: 3,
        ),
      ];
}
