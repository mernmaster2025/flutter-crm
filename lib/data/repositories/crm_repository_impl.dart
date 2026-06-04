import '../../domain/entities/crm_models.dart';
import '../../domain/repositories/crm_repository.dart';
import '../sample/sample_crm_data.dart';
import '../services/local_cache_service.dart';
import '../services/mock_crm_api.dart';

class CrmRepositoryImpl implements CrmRepository {
  CrmRepositoryImpl({
    required MockCrmApi api,
    required LocalCacheService cache,
  })  : _api = api,
        _cache = cache,
        _leads = SampleCrmData.leads,
        _deals = SampleCrmData.deals;

  final MockCrmApi _api;
  final LocalCacheService _cache;
  final List<Lead> _leads;
  List<Deal> _deals;

  @override
  Future<DashboardMetrics> getDashboardMetrics() async {
    final metrics = await _api.getDashboardMetrics();
    await _cache.write('dashboard_updated_at', DateTime.now().toIso8601String());
    return metrics;
  }

  @override
  Future<List<RevenuePoint>> getRevenueSeries() => _api.getRevenueSeries();

  @override
  Future<List<Lead>> getLeads() async {
    await _api.getLeads();
    return List.unmodifiable(_leads);
  }

  @override
  Future<Lead> saveLead(Lead lead) async {
    final index = _leads.indexWhere((item) => item.id == lead.id);
    if (index == -1) {
      _leads.insert(0, lead);
    } else {
      _leads[index] = lead;
    }
    await _cache.write('lead_count', _leads.length);
    return lead;
  }

  @override
  Future<void> deleteLead(String id) async {
    _leads.removeWhere((lead) => lead.id == id);
    await _cache.write('lead_count', _leads.length);
  }

  @override
  Future<List<Customer>> getCustomers() => _api.getCustomers();

  @override
  Future<List<Deal>> getDeals() async {
    await _api.getDeals();
    return List.unmodifiable(_deals);
  }

  @override
  Future<List<Deal>> moveDeal(String id, DealStage stage) async {
    _deals = _deals.map((deal) => deal.id == id ? deal.copyWith(stage: stage) : deal).toList();
    await _cache.write('pipeline_updated_at', DateTime.now().toIso8601String());
    return List.unmodifiable(_deals);
  }

  @override
  Future<List<TaskItem>> getTasks() => _api.getTasks();

  @override
  Future<List<Meeting>> getMeetings() => _api.getMeetings();

  @override
  Future<List<ActivityItem>> getActivities() => _api.getActivities();

  @override
  Future<List<CrmNotification>> getNotifications() => _api.getNotifications();
}
