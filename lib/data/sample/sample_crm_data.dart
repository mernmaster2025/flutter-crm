import '../../domain/entities/crm_models.dart';

class SampleCrmData {
  SampleCrmData._();

  static final now = DateTime.now();

  static const user = AppUser(
    id: 'u_001',
    name: 'Maya Chen',
    email: 'maya@apexcrm.dev',
    role: UserRole.salesManager,
    avatarUrl: '',
    team: 'Revenue',
  );

  static DashboardMetrics get metrics => const DashboardMetrics(
        revenue: 1284000,
        totalLeads: 348,
        activeCustomers: 126,
        openPipeline: 4725000,
        tasksDueToday: 18,
        upcomingMeetings: 9,
        conversionRate: 31.8,
        monthlyGrowth: 14.6,
      );

  static const revenueSeries = [
    RevenuePoint(label: 'Jan', revenue: 620000, leads: 140, conversionRate: 22),
    RevenuePoint(label: 'Feb', revenue: 710000, leads: 156, conversionRate: 24),
    RevenuePoint(label: 'Mar', revenue: 820000, leads: 192, conversionRate: 27),
    RevenuePoint(label: 'Apr', revenue: 990000, leads: 220, conversionRate: 29),
    RevenuePoint(label: 'May', revenue: 1180000, leads: 276, conversionRate: 30),
    RevenuePoint(label: 'Jun', revenue: 1284000, leads: 348, conversionRate: 31.8),
  ];

  static List<Lead> get leads => [
        Lead(
          id: 'lead_001',
          name: 'Olivia Grant',
          company: 'Northstar Robotics',
          email: 'olivia@northstar.ai',
          phone: '+1 (415) 555-0191',
          source: 'LinkedIn Campaign',
          status: LeadStatus.qualified,
          priority: PriorityLevel.high,
          assignedTo: 'Maya Chen',
          estimatedValue: 240000,
          createdAt: now.subtract(const Duration(days: 8)),
          nextFollowUp: now.add(const Duration(hours: 4)),
          notes: const ['Interested in enterprise automation package.', 'Needs procurement review.'],
        ),
        Lead(
          id: 'lead_002',
          name: 'Ethan Brooks',
          company: 'Atlas Freight',
          email: 'ethan@atlasfreight.com',
          phone: '+1 (212) 555-0134',
          source: 'Webinar',
          status: LeadStatus.proposal,
          priority: PriorityLevel.urgent,
          assignedTo: 'Nora Patel',
          estimatedValue: 410000,
          createdAt: now.subtract(const Duration(days: 12)),
          nextFollowUp: now.add(const Duration(days: 1)),
          notes: const ['Proposal sent with multi-region rollout.', 'CFO requested ROI model.'],
        ),
        Lead(
          id: 'lead_003',
          name: 'Ava Moreno',
          company: 'Helio Health',
          email: 'ava@heliohealth.co',
          phone: '+1 (646) 555-0177',
          source: 'Partner Referral',
          status: LeadStatus.contacted,
          priority: PriorityLevel.medium,
          assignedTo: 'Leo Martin',
          estimatedValue: 156000,
          createdAt: now.subtract(const Duration(days: 3)),
          nextFollowUp: now.add(const Duration(days: 2)),
          notes: const ['Wants HIPAA-ready workflows.', 'Schedule technical discovery.'],
        ),
        Lead(
          id: 'lead_004',
          name: 'Noah Singh',
          company: 'Summit Retail Group',
          email: 'noah@summitretail.com',
          phone: '+1 (303) 555-0188',
          source: 'Organic Search',
          status: LeadStatus.newLead,
          priority: PriorityLevel.low,
          assignedTo: 'Maya Chen',
          estimatedValue: 84000,
          createdAt: now.subtract(const Duration(hours: 20)),
          nextFollowUp: now.add(const Duration(hours: 18)),
          notes: const ['Downloaded CRM migration checklist.'],
        ),
      ];

  static const customers = [
    Customer(
      id: 'cust_001',
      name: 'Grace Kim',
      company: 'Vanta Labs',
      email: 'grace@vantalabs.io',
      phone: '+1 (415) 555-0101',
      location: 'San Francisco, CA',
      segment: CustomerSegment.enterprise,
      owner: 'Maya Chen',
      revenue: 920000,
      isFavorite: true,
      tags: ['Enterprise', 'Expansion', 'AI'],
      history: ['Signed annual contract', 'Expanded to 420 seats', 'Renewal due Q4'],
    ),
    Customer(
      id: 'cust_002',
      name: 'Lucas Meyer',
      company: 'Evergreen Bank',
      email: 'lucas@evergreen.bank',
      phone: '+1 (312) 555-0156',
      location: 'Chicago, IL',
      segment: CustomerSegment.midMarket,
      owner: 'Nora Patel',
      revenue: 520000,
      isFavorite: true,
      tags: ['Finance', 'Compliance'],
      history: ['Security review passed', 'Added analytics module'],
    ),
    Customer(
      id: 'cust_003',
      name: 'Priya Raman',
      company: 'BluePeak Solar',
      email: 'priya@bluepeaksolar.com',
      phone: '+1 (512) 555-0162',
      location: 'Austin, TX',
      segment: CustomerSegment.smallBusiness,
      owner: 'Leo Martin',
      revenue: 124000,
      isFavorite: false,
      tags: ['Energy', 'Growth'],
      history: ['Migrated from spreadsheet CRM', 'Requested field service integration'],
    ),
  ];

  static List<Deal> get deals => [
        Deal(
          id: 'deal_001',
          title: 'Global revenue operations rollout',
          customerId: 'cust_001',
          customerName: 'Vanta Labs',
          stage: DealStage.proposal,
          value: 980000,
          probability: 0.72,
          closeDate: now.add(const Duration(days: 22)),
          owner: 'Maya Chen',
        ),
        Deal(
          id: 'deal_002',
          title: 'Compliance workflow expansion',
          customerId: 'cust_002',
          customerName: 'Evergreen Bank',
          stage: DealStage.negotiation,
          value: 420000,
          probability: 0.66,
          closeDate: now.add(const Duration(days: 14)),
          owner: 'Nora Patel',
        ),
        Deal(
          id: 'deal_003',
          title: 'Solar contractor partner portal',
          customerId: 'cust_003',
          customerName: 'BluePeak Solar',
          stage: DealStage.discovery,
          value: 180000,
          probability: 0.38,
          closeDate: now.add(const Duration(days: 41)),
          owner: 'Leo Martin',
        ),
        Deal(
          id: 'deal_004',
          title: 'North America field team CRM',
          customerId: 'lead_002',
          customerName: 'Atlas Freight',
          stage: DealStage.qualified,
          value: 610000,
          probability: 0.54,
          closeDate: now.add(const Duration(days: 33)),
          owner: 'Nora Patel',
        ),
      ];

  static List<TaskItem> get tasks => [
        TaskItem(
          id: 'task_001',
          title: 'Send ROI model to Atlas Freight',
          assignee: 'Nora Patel',
          category: 'Proposal',
          priority: PriorityLevel.urgent,
          status: TaskStatus.todo,
          dueAt: now.add(const Duration(hours: 2)),
          isRecurring: false,
        ),
        TaskItem(
          id: 'task_002',
          title: 'Weekly renewal health review',
          assignee: 'Maya Chen',
          category: 'Customer Success',
          priority: PriorityLevel.medium,
          status: TaskStatus.inProgress,
          dueAt: now.add(const Duration(hours: 5)),
          isRecurring: true,
        ),
        TaskItem(
          id: 'task_003',
          title: 'Prepare HIPAA technical discovery notes',
          assignee: 'Leo Martin',
          category: 'Discovery',
          priority: PriorityLevel.high,
          status: TaskStatus.todo,
          dueAt: now.add(const Duration(days: 1)),
          isRecurring: false,
        ),
      ];

  static List<Meeting> get meetings => [
        Meeting(
          id: 'meet_001',
          title: 'Executive pipeline review',
          customerName: 'Apex Revenue Team',
          startsAt: now.add(const Duration(hours: 3)),
          durationMinutes: 45,
          videoLink: 'https://meet.example.com/pipeline-review',
          notes: 'Review forecast confidence and blocked enterprise deals.',
        ),
        Meeting(
          id: 'meet_002',
          title: 'Security review',
          customerName: 'Evergreen Bank',
          startsAt: now.add(const Duration(days: 1, hours: 1)),
          durationMinutes: 60,
          videoLink: 'https://meet.example.com/evergreen-security',
          notes: 'Discuss SSO, audit exports, and data retention.',
        ),
      ];

  static List<ActivityItem> get activities => [
        ActivityItem(
          id: 'act_001',
          type: ActivityType.email,
          title: 'Proposal accepted for review',
          description: 'Atlas Freight forwarded the commercial proposal to finance.',
          actor: 'Nora Patel',
          occurredAt: now.subtract(const Duration(minutes: 28)),
        ),
        ActivityItem(
          id: 'act_002',
          type: ActivityType.call,
          title: 'Discovery call completed',
          description: 'Helio Health confirmed compliance and integration requirements.',
          actor: 'Leo Martin',
          occurredAt: now.subtract(const Duration(hours: 2)),
        ),
        ActivityItem(
          id: 'act_003',
          type: ActivityType.meeting,
          title: 'Renewal planning session',
          description: 'Vanta Labs requested seat expansion scenarios for Q4.',
          actor: 'Maya Chen',
          occurredAt: now.subtract(const Duration(hours: 6)),
        ),
      ];

  static List<CrmNotification> get notifications => [
        CrmNotification(
          id: 'not_001',
          title: 'Follow-up due',
          body: 'Olivia Grant expects a technical package today.',
          createdAt: now.subtract(const Duration(minutes: 12)),
          isRead: false,
        ),
        CrmNotification(
          id: 'not_002',
          title: 'Meeting starts soon',
          body: 'Executive pipeline review starts in 3 hours.',
          createdAt: now.subtract(const Duration(hours: 1)),
          isRead: false,
        ),
      ];
}
