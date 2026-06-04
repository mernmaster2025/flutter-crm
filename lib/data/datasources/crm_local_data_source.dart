import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/crm_models.dart';
import '../sample/sample_crm_data.dart';

class CrmLocalDataSource {
  CrmLocalDataSource({
    required Box<dynamic> metaBox,
    required Box<dynamic> leadsBox,
    required Box<dynamic> customersBox,
    required Box<dynamic> dealsBox,
    required Box<dynamic> tasksBox,
    required Box<dynamic> meetingsBox,
    required Box<dynamic> activitiesBox,
    required Box<dynamic> notificationsBox,
    required Box<dynamic> communicationsBox,
    required Box<dynamic> exportsBox,
  })  : _metaBox = metaBox,
        _leadsBox = leadsBox,
        _customersBox = customersBox,
        _dealsBox = dealsBox,
        _tasksBox = tasksBox,
        _meetingsBox = meetingsBox,
        _activitiesBox = activitiesBox,
        _notificationsBox = notificationsBox,
        _communicationsBox = communicationsBox,
        _exportsBox = exportsBox;

  static const _seedKey = 'seeded_v2';

  final Box<dynamic> _metaBox;
  final Box<dynamic> _leadsBox;
  final Box<dynamic> _customersBox;
  final Box<dynamic> _dealsBox;
  final Box<dynamic> _tasksBox;
  final Box<dynamic> _meetingsBox;
  final Box<dynamic> _activitiesBox;
  final Box<dynamic> _notificationsBox;
  final Box<dynamic> _communicationsBox;
  final Box<dynamic> _exportsBox;

  static Future<CrmLocalDataSource> open() async {
    final source = CrmLocalDataSource(
      metaBox: await Hive.openBox<dynamic>('crm_meta'),
      leadsBox: await Hive.openBox<dynamic>('crm_leads'),
      customersBox: await Hive.openBox<dynamic>('crm_customers'),
      dealsBox: await Hive.openBox<dynamic>('crm_deals'),
      tasksBox: await Hive.openBox<dynamic>('crm_tasks'),
      meetingsBox: await Hive.openBox<dynamic>('crm_meetings'),
      activitiesBox: await Hive.openBox<dynamic>('crm_activities'),
      notificationsBox: await Hive.openBox<dynamic>('crm_notifications'),
      communicationsBox: await Hive.openBox<dynamic>('crm_communications'),
      exportsBox: await Hive.openBox<dynamic>('crm_exports'),
    );
    await source.seedIfNeeded();
    return source;
  }

  Future<void> seedIfNeeded() async {
    if (_metaBox.get(_seedKey) == true) return;

    await _seedBox(_leadsBox, SampleCrmData.leads, (lead) => lead.toJson());
    await _seedBox(_customersBox, SampleCrmData.customers, (customer) => customer.toJson());
    await _seedBox(_dealsBox, SampleCrmData.deals, (deal) => deal.toJson());
    await _seedBox(_tasksBox, SampleCrmData.tasks, (task) => task.toJson());
    await _seedBox(_meetingsBox, SampleCrmData.meetings, (meeting) => meeting.toJson());
    await _seedBox(_activitiesBox, SampleCrmData.activities, (activity) => activity.toJson());
    await _seedBox(_notificationsBox, SampleCrmData.notifications, (notification) => notification.toJson());
    await _metaBox.put(_seedKey, true);
  }

  Future<void> _seedBox<T>(Box<dynamic> box, List<T> items, Map<String, dynamic> Function(T item) toJson) async {
    if (box.isNotEmpty) return;
    for (final item in items) {
      final json = toJson(item);
      await box.put(json['id'] as String, json);
    }
  }

  Future<List<Lead>> getLeads() async => _readAll(_leadsBox, Lead.fromJson);
  Future<Lead> saveLead(Lead lead) => _put(_leadsBox, lead.id, lead, (item) => item.toJson());
  Future<void> deleteLead(String id) => _leadsBox.delete(id);

  Future<List<Customer>> getCustomers() async => _readAll(_customersBox, Customer.fromJson);
  Future<Customer> saveCustomer(Customer customer) => _put(_customersBox, customer.id, customer, (item) => item.toJson());
  Future<void> deleteCustomer(String id) => _customersBox.delete(id);

  Future<List<Deal>> getDeals() async => _readAll(_dealsBox, Deal.fromJson);
  Future<Deal> saveDeal(Deal deal) => _put(_dealsBox, deal.id, deal, (item) => item.toJson());
  Future<void> deleteDeal(String id) => _dealsBox.delete(id);

  Future<List<TaskItem>> getTasks() async => _readAll(_tasksBox, TaskItem.fromJson);
  Future<TaskItem> saveTask(TaskItem task) => _put(_tasksBox, task.id, task, (item) => item.toJson());
  Future<void> deleteTask(String id) => _tasksBox.delete(id);

  Future<List<Meeting>> getMeetings() async => _readAll(_meetingsBox, Meeting.fromJson);
  Future<Meeting> saveMeeting(Meeting meeting) => _put(_meetingsBox, meeting.id, meeting, (item) => item.toJson());
  Future<void> deleteMeeting(String id) => _meetingsBox.delete(id);

  Future<List<ActivityItem>> getActivities() async {
    final activities = _readAll(_activitiesBox, ActivityItem.fromJson);
    activities.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return activities;
  }

  Future<ActivityItem> saveActivity(ActivityItem activity) {
    return _put(_activitiesBox, activity.id, activity, (item) => item.toJson());
  }

  Future<void> deleteActivity(String id) => _activitiesBox.delete(id);

  Future<List<CrmNotification>> getNotifications() async {
    final notifications = _readAll(_notificationsBox, CrmNotification.fromJson);
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  Future<CrmNotification> saveNotification(CrmNotification notification) {
    return _put(_notificationsBox, notification.id, notification, (item) => item.toJson());
  }

  Future<void> deleteNotification(String id) => _notificationsBox.delete(id);

  Future<List<CommunicationRecord>> getCommunications() async {
    final records = _readAll(_communicationsBox, CommunicationRecord.fromJson);
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Future<CommunicationRecord> saveCommunication(CommunicationRecord record) {
    return _put(_communicationsBox, record.id, record, (item) => item.toJson());
  }

  Future<List<ExportRecord>> getExports() async {
    final records = _readAll(_exportsBox, ExportRecord.fromJson);
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Future<ExportRecord> saveExport(ExportRecord record) {
    return _put(_exportsBox, record.id, record, (item) => item.toJson());
  }

  Future<void> clearAll() async {
    await Future.wait([
      _metaBox.clear(),
      _leadsBox.clear(),
      _customersBox.clear(),
      _dealsBox.clear(),
      _tasksBox.clear(),
      _meetingsBox.clear(),
      _activitiesBox.clear(),
      _notificationsBox.clear(),
      _communicationsBox.clear(),
      _exportsBox.clear(),
    ]);
  }

  Future<T> _put<T>(
    Box<dynamic> box,
    String id,
    T item,
    Map<String, dynamic> Function(T item) toJson,
  ) async {
    await box.put(id, toJson(item));
    return item;
  }

  List<T> _readAll<T>(Box<dynamic> box, T Function(Map<String, dynamic> json) fromJson) {
    return box.values.map((value) => fromJson(_mapFromHive(value))).toList();
  }

  Map<String, dynamic> _mapFromHive(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }
}
