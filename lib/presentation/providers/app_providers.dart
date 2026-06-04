import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/crm_repository_impl.dart';
import '../../data/services/local_cache_service.dart';
import '../../data/services/mock_crm_api.dart';
import '../../domain/entities/crm_models.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/crm_repository.dart';
import '../../domain/usecases/crm_usecases.dart';
import '../../services/biometric_service.dart';
import '../../services/integration_services.dart';
import '../../services/session_service.dart';

final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  throw UnimplementedError('LocalCacheService must be overridden at bootstrap.');
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://mock.apex-crm.local'));
});

final mockCrmApiProvider = Provider<MockCrmApi>((ref) {
  return MockCrmApi(ref.watch(dioProvider));
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(const FlutterSecureStorage());
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(LocalAuthentication());
});

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
final communicationServiceProvider = Provider<CommunicationService>((ref) => CommunicationService());
final exportServiceProvider = Provider<ExportService>((ref) => ExportService());
final calendarServiceProvider = Provider<CalendarService>((ref) => CalendarService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    sessionService: ref.watch(sessionServiceProvider),
    biometricService: ref.watch(biometricServiceProvider),
  );
});

final crmRepositoryProvider = Provider<CrmRepository>((ref) {
  return CrmRepositoryImpl(
    api: ref.watch(mockCrmApiProvider),
    cache: ref.watch(localCacheServiceProvider),
  );
});

final crmUseCasesProvider = Provider<CrmUseCases>((ref) {
  return CrmUseCases(ref.watch(crmRepositoryProvider));
});

final themeModeControllerProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() => ref.watch(authRepositoryProvider).restoreSession();

  Future<void> login(String email, String password, bool rememberMe) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
            rememberMe: rememberMe,
          ),
    );
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            password: password,
          ),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final dashboardProvider = FutureProvider<DashboardBundle>((ref) async {
  final useCases = ref.watch(crmUseCasesProvider);
  final metrics = await useCases.dashboardMetrics();
  final revenue = await useCases.revenueSeries();
  final activities = await useCases.activities();
  final tasks = await useCases.tasks();
  final meetings = await useCases.meetings();
  return DashboardBundle(
    metrics: metrics,
    revenue: revenue,
    activities: activities,
    tasks: tasks,
    meetings: meetings,
  );
});

class DashboardBundle {
  const DashboardBundle({
    required this.metrics,
    required this.revenue,
    required this.activities,
    required this.tasks,
    required this.meetings,
  });

  final DashboardMetrics metrics;
  final List<RevenuePoint> revenue;
  final List<ActivityItem> activities;
  final List<TaskItem> tasks;
  final List<Meeting> meetings;
}

final leadQueryProvider = StateProvider<String>((ref) => '');
final leadStatusFilterProvider = StateProvider<LeadStatus?>((ref) => null);

final leadsControllerProvider = AsyncNotifierProvider<LeadsController, List<Lead>>(
  LeadsController.new,
);

class LeadsController extends AsyncNotifier<List<Lead>> {
  @override
  Future<List<Lead>> build() {
    final query = ref.watch(leadQueryProvider);
    final status = ref.watch(leadStatusFilterProvider);
    return ref.watch(crmUseCasesProvider).leads(query: query, status: status);
  }

  Future<void> saveLead(Lead lead) async {
    await ref.read(crmUseCasesProvider).upsertLead(lead);
    ref.invalidateSelf();
  }

  Future<void> createDemoLead({
    required String name,
    required String company,
    required String email,
    required String phone,
  }) async {
    final lead = Lead(
      id: const Uuid().v4(),
      name: name,
      company: company,
      email: email,
      phone: phone,
      source: 'Mobile App',
      status: LeadStatus.newLead,
      priority: PriorityLevel.medium,
      assignedTo: 'Maya Chen',
      estimatedValue: 75000,
      createdAt: DateTime.now(),
      nextFollowUp: DateTime.now().add(const Duration(days: 2)),
      notes: const ['Created from mobile CRM.'],
    );
    await saveLead(lead);
  }
}

final customerQueryProvider = StateProvider<String>((ref) => '');
final favoritesOnlyProvider = StateProvider<bool>((ref) => false);

final customersProvider = FutureProvider<List<Customer>>((ref) {
  return ref.watch(crmUseCasesProvider).customers(
        query: ref.watch(customerQueryProvider),
        favoritesOnly: ref.watch(favoritesOnlyProvider),
      );
});

final dealsControllerProvider = AsyncNotifierProvider<DealsController, List<Deal>>(
  DealsController.new,
);

class DealsController extends AsyncNotifier<List<Deal>> {
  @override
  Future<List<Deal>> build() => ref.watch(crmUseCasesProvider).deals();

  Future<void> moveDeal(String id, DealStage stage) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(crmUseCasesProvider).moveDeal(id, stage));
  }
}

final tasksProvider = FutureProvider<List<TaskItem>>((ref) => ref.watch(crmUseCasesProvider).tasks());
final meetingsProvider = FutureProvider<List<Meeting>>((ref) => ref.watch(crmUseCasesProvider).meetings());
final activitiesProvider = FutureProvider<List<ActivityItem>>((ref) => ref.watch(crmUseCasesProvider).activities());
final notificationsProvider = FutureProvider<List<CrmNotification>>(
  (ref) => ref.watch(crmUseCasesProvider).notifications(),
);
