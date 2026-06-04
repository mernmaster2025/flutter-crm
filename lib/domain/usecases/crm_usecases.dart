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

  Future<List<Deal>> deals() => _repository.getDeals();

  Future<List<Deal>> moveDeal(String id, DealStage stage) => _repository.moveDeal(id, stage);

  Future<List<TaskItem>> tasks() => _repository.getTasks();

  Future<List<Meeting>> meetings() => _repository.getMeetings();

  Future<List<ActivityItem>> activities() => _repository.getActivities();

  Future<List<CrmNotification>> notifications() => _repository.getNotifications();
}
