import '../entities/crm_models.dart';

abstract interface class CrmRepository {
  Future<DashboardMetrics> getDashboardMetrics();
  Future<List<RevenuePoint>> getRevenueSeries();
  Future<List<Lead>> getLeads();
  Future<Lead> saveLead(Lead lead);
  Future<void> deleteLead(String id);
  Future<List<Customer>> getCustomers();
  Future<List<Deal>> getDeals();
  Future<List<Deal>> moveDeal(String id, DealStage stage);
  Future<List<TaskItem>> getTasks();
  Future<List<Meeting>> getMeetings();
  Future<List<ActivityItem>> getActivities();
  Future<List<CrmNotification>> getNotifications();
}
