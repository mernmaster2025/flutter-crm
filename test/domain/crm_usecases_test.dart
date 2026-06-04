import 'package:flutter_crm/data/sample/sample_crm_data.dart';
import 'package:flutter_crm/domain/entities/crm_models.dart';
import 'package:flutter_crm/domain/repositories/crm_repository.dart';
import 'package:flutter_crm/domain/usecases/crm_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CrmUseCases useCases;

  setUp(() {
    useCases = CrmUseCases(_FakeCrmRepository());
  });

  test('filters leads by query and status', () async {
    final results = await useCases.leads(query: 'atlas', status: LeadStatus.proposal);

    expect(results, hasLength(1));
    expect(results.single.company, 'Atlas Freight');
  });

  test('filters favorite customers', () async {
    final results = await useCases.customers(favoritesOnly: true);

    expect(results.every((customer) => customer.isFavorite), isTrue);
  });
}

class _FakeCrmRepository implements CrmRepository {
  @override
  Future<DashboardMetrics> getDashboardMetrics() async => SampleCrmData.metrics;

  @override
  Future<List<RevenuePoint>> getRevenueSeries() async => SampleCrmData.revenueSeries;

  @override
  Future<List<Lead>> getLeads() async => SampleCrmData.leads;

  @override
  Future<Lead> saveLead(Lead lead) async => lead;

  @override
  Future<void> deleteLead(String id) async {}

  @override
  Future<List<Customer>> getCustomers() async => SampleCrmData.customers;

  @override
  Future<Customer> saveCustomer(Customer customer) async => customer;

  @override
  Future<void> deleteCustomer(String id) async {}

  @override
  Future<List<Deal>> getDeals() async => SampleCrmData.deals;

  @override
  Future<Deal> saveDeal(Deal deal) async => deal;

  @override
  Future<void> deleteDeal(String id) async {}

  @override
  Future<List<Deal>> moveDeal(String id, DealStage stage) async => SampleCrmData.deals;

  @override
  Future<List<TaskItem>> getTasks() async => SampleCrmData.tasks;

  @override
  Future<TaskItem> saveTask(TaskItem task) async => task;

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<List<Meeting>> getMeetings() async => SampleCrmData.meetings;

  @override
  Future<Meeting> saveMeeting(Meeting meeting) async => meeting;

  @override
  Future<void> deleteMeeting(String id) async {}

  @override
  Future<List<ActivityItem>> getActivities() async => SampleCrmData.activities;

  @override
  Future<ActivityItem> saveActivity(ActivityItem activity) async => activity;

  @override
  Future<void> deleteActivity(String id) async {}

  @override
  Future<List<CrmNotification>> getNotifications() async => SampleCrmData.notifications;

  @override
  Future<CrmNotification> saveNotification(CrmNotification notification) async => notification;

  @override
  Future<CrmNotification> markNotificationRead(String id, bool isRead) async {
    return SampleCrmData.notifications.first.copyWith(isRead: isRead);
  }

  @override
  Future<void> deleteNotification(String id) async {}

  @override
  Future<List<CommunicationRecord>> getCommunications() async => const [];

  @override
  Future<CommunicationRecord> saveCommunication(CommunicationRecord record) async => record;

  @override
  Future<List<ExportRecord>> getExports() async => const [];

  @override
  Future<ExportRecord> saveExport(ExportRecord record) async => record;
}
