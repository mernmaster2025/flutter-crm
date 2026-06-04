import '../../domain/entities/crm_models.dart';
import '../../domain/repositories/crm_repository.dart';
import '../datasources/crm_local_data_source.dart';
import '../sample/sample_crm_data.dart';

class CrmRepositoryImpl implements CrmRepository {
  CrmRepositoryImpl({
    required CrmLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final CrmLocalDataSource _localDataSource;

  @override
  Future<DashboardMetrics> getDashboardMetrics() async {
    final leads = await getLeads();
    final customers = await getCustomers();
    final deals = await getDeals();
    final tasks = await getTasks();
    final meetings = await getMeetings();
    final now = DateTime.now();
    final wonRevenue = deals
        .where((deal) => deal.stage == DealStage.won)
        .fold<double>(0, (sum, deal) => sum + deal.value);
    final openPipeline = deals
        .where((deal) => deal.stage != DealStage.won && deal.stage != DealStage.lost)
        .fold<double>(0, (sum, deal) => sum + deal.value);
    final converted = leads.where((lead) => lead.status == LeadStatus.converted).length + deals.where((deal) => deal.stage == DealStage.won).length;
    final conversionRate = leads.isEmpty ? 0.0 : (converted / leads.length * 100).clamp(0, 100).toDouble();

    return DashboardMetrics(
      revenue: customers.fold<double>(wonRevenue, (sum, customer) => sum + customer.revenue),
      totalLeads: leads.length,
      activeCustomers: customers.length,
      openPipeline: openPipeline,
      tasksDueToday: tasks.where((task) => _sameDay(task.dueAt, now) && task.status != TaskStatus.done).length,
      upcomingMeetings: meetings.where((meeting) => meeting.startsAt.isAfter(now)).length,
      conversionRate: double.parse(conversionRate.toStringAsFixed(1)),
      monthlyGrowth: SampleCrmData.metrics.monthlyGrowth,
    );
  }

  @override
  Future<List<RevenuePoint>> getRevenueSeries() async => SampleCrmData.revenueSeries;

  @override
  Future<List<Lead>> getLeads() => _localDataSource.getLeads();

  @override
  Future<Lead> saveLead(Lead lead) async {
    final saved = await _localDataSource.saveLead(lead);
    await _logActivity(
      type: ActivityType.note,
      title: 'Lead saved',
      description: '${lead.name} at ${lead.company} was updated.',
    );
    return saved;
  }

  @override
  Future<void> deleteLead(String id) => _localDataSource.deleteLead(id);

  @override
  Future<List<Customer>> getCustomers() => _localDataSource.getCustomers();

  @override
  Future<Customer> saveCustomer(Customer customer) async {
    final saved = await _localDataSource.saveCustomer(customer);
    await _logActivity(
      type: ActivityType.note,
      title: 'Customer updated',
      description: '${customer.company} profile was saved.',
    );
    return saved;
  }

  @override
  Future<void> deleteCustomer(String id) => _localDataSource.deleteCustomer(id);

  @override
  Future<List<Deal>> getDeals() => _localDataSource.getDeals();

  @override
  Future<Deal> saveDeal(Deal deal) async {
    final saved = await _localDataSource.saveDeal(deal);
    await _logActivity(
      type: ActivityType.note,
      title: 'Deal saved',
      description: '${deal.title} is now in ${deal.stage.label}.',
    );
    return saved;
  }

  @override
  Future<void> deleteDeal(String id) => _localDataSource.deleteDeal(id);

  @override
  Future<List<Deal>> moveDeal(String id, DealStage stage) async {
    final deals = await getDeals();
    final deal = deals.firstWhere((item) => item.id == id);
    await saveDeal(deal.copyWith(stage: stage));
    return getDeals();
  }

  @override
  Future<List<TaskItem>> getTasks() => _localDataSource.getTasks();

  @override
  Future<TaskItem> saveTask(TaskItem task) async {
    final saved = await _localDataSource.saveTask(task);
    if (task.status != TaskStatus.done) {
      await saveNotification(
        CrmNotification(
          id: 'task_${task.id}_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Task reminder',
          body: '${task.title} is due soon for ${task.assignee}.',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );
    }
    return saved;
  }

  @override
  Future<void> deleteTask(String id) => _localDataSource.deleteTask(id);

  @override
  Future<List<Meeting>> getMeetings() => _localDataSource.getMeetings();

  @override
  Future<Meeting> saveMeeting(Meeting meeting) async {
    final saved = await _localDataSource.saveMeeting(meeting);
    await _logActivity(
      type: ActivityType.meeting,
      title: 'Meeting scheduled',
      description: '${meeting.title} with ${meeting.customerName}.',
    );
    await saveNotification(
      CrmNotification(
        id: 'meeting_${meeting.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Meeting scheduled',
        body: '${meeting.title} starts ${meeting.startsAt.month}/${meeting.startsAt.day}.',
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );
    return saved;
  }

  @override
  Future<void> deleteMeeting(String id) => _localDataSource.deleteMeeting(id);

  @override
  Future<List<ActivityItem>> getActivities() => _localDataSource.getActivities();

  @override
  Future<ActivityItem> saveActivity(ActivityItem activity) => _localDataSource.saveActivity(activity);

  @override
  Future<void> deleteActivity(String id) => _localDataSource.deleteActivity(id);

  @override
  Future<List<CrmNotification>> getNotifications() => _localDataSource.getNotifications();

  @override
  Future<CrmNotification> saveNotification(CrmNotification notification) => _localDataSource.saveNotification(notification);

  @override
  Future<CrmNotification> markNotificationRead(String id, bool isRead) async {
    final notification = (await getNotifications()).firstWhere((item) => item.id == id);
    return saveNotification(notification.copyWith(isRead: isRead));
  }

  @override
  Future<void> deleteNotification(String id) => _localDataSource.deleteNotification(id);

  @override
  Future<List<CommunicationRecord>> getCommunications() => _localDataSource.getCommunications();

  @override
  Future<CommunicationRecord> saveCommunication(CommunicationRecord record) async {
    final saved = await _localDataSource.saveCommunication(record);
    await _logActivity(
      type: switch (record.channel) {
        CommunicationChannel.email => ActivityType.email,
        CommunicationChannel.sms => ActivityType.sms,
        CommunicationChannel.whatsapp => ActivityType.whatsapp,
        CommunicationChannel.bulk => ActivityType.email,
      },
      title: '${record.channel.label} queued',
      description: '${record.subject} sent to ${record.recipient}.',
    );
    await saveNotification(
      CrmNotification(
        id: 'comm_${record.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Communication queued',
        body: '${record.channel.label} message saved for ${record.recipient}.',
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );
    return saved;
  }

  @override
  Future<List<ExportRecord>> getExports() => _localDataSource.getExports();

  @override
  Future<ExportRecord> saveExport(ExportRecord record) async {
    final saved = await _localDataSource.saveExport(record);
    await _logActivity(
      type: ActivityType.note,
      title: 'Report exported',
      description: '${record.reportName} generated as ${record.format.label}.',
    );
    return saved;
  }

  Future<ActivityItem> _logActivity({
    required ActivityType type,
    required String title,
    required String description,
  }) {
    return saveActivity(
      ActivityItem(
        id: 'act_${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        title: title,
        description: description,
        actor: 'Apex CRM',
        occurredAt: DateTime.now(),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
