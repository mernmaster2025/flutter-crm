import '../entities/crm_models.dart';

abstract interface class CrmRepository {
  Future<DashboardMetrics> getDashboardMetrics();
  Future<List<RevenuePoint>> getRevenueSeries();
  Future<List<Lead>> getLeads();
  Future<Lead> saveLead(Lead lead);
  Future<void> deleteLead(String id);
  Future<List<Customer>> getCustomers();
  Future<Customer> saveCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
  Future<List<Deal>> getDeals();
  Future<Deal> saveDeal(Deal deal);
  Future<void> deleteDeal(String id);
  Future<List<Deal>> moveDeal(String id, DealStage stage);
  Future<List<TaskItem>> getTasks();
  Future<TaskItem> saveTask(TaskItem task);
  Future<void> deleteTask(String id);
  Future<List<Meeting>> getMeetings();
  Future<Meeting> saveMeeting(Meeting meeting);
  Future<void> deleteMeeting(String id);
  Future<List<ActivityItem>> getActivities();
  Future<ActivityItem> saveActivity(ActivityItem activity);
  Future<void> deleteActivity(String id);
  Future<List<CrmNotification>> getNotifications();
  Future<CrmNotification> saveNotification(CrmNotification notification);
  Future<CrmNotification> markNotificationRead(String id, bool isRead);
  Future<void> deleteNotification(String id);
  Future<List<CommunicationRecord>> getCommunications();
  Future<CommunicationRecord> saveCommunication(CommunicationRecord record);
  Future<List<ExportRecord>> getExports();
  Future<ExportRecord> saveExport(ExportRecord record);
}
