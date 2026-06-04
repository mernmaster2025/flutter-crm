import 'package:dio/dio.dart';

import '../../domain/entities/crm_models.dart';
import '../sample/sample_crm_data.dart';

class MockCrmApi {
  MockCrmApi(this._dio);

  final Dio _dio;

  Future<T> _simulate<T>(T value) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    // Keep Dio in the stack so interceptors, headers, and later real clients use the same seam.
    _dio.options.headers['x-crm-demo'] = 'true';
    return value;
  }

  Future<DashboardMetrics> getDashboardMetrics() => _simulate(SampleCrmData.metrics);
  Future<List<RevenuePoint>> getRevenueSeries() => _simulate(SampleCrmData.revenueSeries);
  Future<List<Lead>> getLeads() => _simulate(SampleCrmData.leads);
  Future<List<Customer>> getCustomers() => _simulate(SampleCrmData.customers);
  Future<List<Deal>> getDeals() => _simulate(SampleCrmData.deals);
  Future<List<TaskItem>> getTasks() => _simulate(SampleCrmData.tasks);
  Future<List<Meeting>> getMeetings() => _simulate(SampleCrmData.meetings);
  Future<List<ActivityItem>> getActivities() => _simulate(SampleCrmData.activities);
  Future<List<CrmNotification>> getNotifications() => _simulate(SampleCrmData.notifications);
}
