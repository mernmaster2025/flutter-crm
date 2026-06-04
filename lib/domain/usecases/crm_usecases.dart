import '../entities/crm_models.dart';
import '../repositories/crm_repository.dart';

class CrmUseCases {
  const CrmUseCases(this._repository);

  final CrmRepository _repository;

  Future<DashboardMetrics> dashboardMetrics() => _repository.getDashboardMetrics();

  Future<List<RevenuePoint>> revenueSeries() => _repository.getRevenueSeries();

  Future<List<Lead>> leads({String query = '', LeadStatus? status}) async {
    final leads = await _repository.getLeads();
    return leads.where((lead) {
      final matchesQuery = query.isEmpty ||
          lead.name.toLowerCase().contains(query.toLowerCase()) ||
          lead.company.toLowerCase().contains(query.toLowerCase()) ||
          lead.email.toLowerCase().contains(query.toLowerCase());
      final matchesStatus = status == null || lead.status == status;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  Future<Lead> upsertLead(Lead lead) => _repository.saveLead(lead);

  Future<void> removeLead(String id) => _repository.deleteLead(id);

  Future<List<Customer>> customers({String query = '', bool favoritesOnly = false}) async {
    final customers = await _repository.getCustomers();
    return customers.where((customer) {
      final matchesQuery = query.isEmpty ||
          customer.name.toLowerCase().contains(query.toLowerCase()) ||
          customer.company.toLowerCase().contains(query.toLowerCase());
      final matchesFavorite = !favoritesOnly || customer.isFavorite;
      return matchesQuery && matchesFavorite;
    }).toList();
  }

  Future<Customer> upsertCustomer(Customer customer) => _repository.saveCustomer(customer);

  Future<void> removeCustomer(String id) => _repository.deleteCustomer(id);

  Future<Customer> toggleFavorite(Customer customer) {
    return _repository.saveCustomer(customer.copyWith(isFavorite: !customer.isFavorite));
  }

  Future<Customer> addCustomerNote(Customer customer, String note) {
    return _repository.saveCustomer(customer.copyWith(history: [...customer.history, note]));
  }

  Future<List<Deal>> deals() => _repository.getDeals();

  Future<Deal> upsertDeal(Deal deal) => _repository.saveDeal(deal);

  Future<void> removeDeal(String id) => _repository.deleteDeal(id);

  Future<List<Deal>> moveDeal(String id, DealStage stage) => _repository.moveDeal(id, stage);

  Future<List<TaskItem>> tasks() => _repository.getTasks();

  Future<TaskItem> upsertTask(TaskItem task) => _repository.saveTask(task);

  Future<TaskItem> setTaskStatus(TaskItem task, TaskStatus status) {
    return _repository.saveTask(task.copyWith(status: status));
  }

  Future<void> removeTask(String id) => _repository.deleteTask(id);

  Future<List<Meeting>> meetings() => _repository.getMeetings();

  Future<Meeting> upsertMeeting(Meeting meeting) => _repository.saveMeeting(meeting);

  Future<void> removeMeeting(String id) => _repository.deleteMeeting(id);

  Future<List<ActivityItem>> activities() => _repository.getActivities();

  Future<ActivityItem> upsertActivity(ActivityItem activity) => _repository.saveActivity(activity);

  Future<void> removeActivity(String id) => _repository.deleteActivity(id);

  Future<List<CrmNotification>> notifications() => _repository.getNotifications();

  Future<CrmNotification> upsertNotification(CrmNotification notification) => _repository.saveNotification(notification);

  Future<CrmNotification> markNotificationRead(String id, bool isRead) {
    return _repository.markNotificationRead(id, isRead);
  }

  Future<void> removeNotification(String id) => _repository.deleteNotification(id);

  Future<List<CommunicationRecord>> communications() => _repository.getCommunications();

  Future<CommunicationRecord> upsertCommunication(CommunicationRecord record) {
    return _repository.saveCommunication(record);
  }

  Future<List<ExportRecord>> exports() => _repository.getExports();

  Future<ExportRecord> upsertExport(ExportRecord record) => _repository.saveExport(record);
}
