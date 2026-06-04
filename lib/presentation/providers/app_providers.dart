import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/crm_local_data_source.dart';
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

final crmLocalDataSourceProvider = Provider<CrmLocalDataSource>((ref) {
  throw UnimplementedError('CrmLocalDataSource must be overridden at bootstrap.');
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
    localDataSource: ref.watch(crmLocalDataSourceProvider),
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
    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> deleteLead(String id) async {
    await ref.read(crmUseCasesProvider).removeLead(id);
    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> addNote(Lead lead, String note) {
    return saveLead(lead.copyWith(notes: [...lead.notes, note]));
  }

  Future<void> updateStatus(Lead lead, LeadStatus status) {
    return saveLead(lead.copyWith(status: status));
  }

  Future<void> createDemoLead({
    required String name,
    required String company,
    required String email,
    required String phone,
    LeadStatus status = LeadStatus.newLead,
    PriorityLevel priority = PriorityLevel.medium,
  }) async {
    final lead = Lead(
      id: const Uuid().v4(),
      name: name,
      company: company,
      email: email,
      phone: phone,
      source: 'Mobile App',
      status: status,
      priority: priority,
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

final customersControllerProvider = AsyncNotifierProvider<CustomersController, List<Customer>>(
  CustomersController.new,
);

final customersProvider = customersControllerProvider;

class CustomersController extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() {
    return ref.watch(crmUseCasesProvider).customers(
          query: ref.watch(customerQueryProvider),
          favoritesOnly: ref.watch(favoritesOnlyProvider),
        );
  }

  Future<void> saveCustomer(Customer customer) async {
    await ref.read(crmUseCasesProvider).upsertCustomer(customer);
    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> deleteCustomer(String id) async {
    await ref.read(crmUseCasesProvider).removeCustomer(id);
    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> toggleFavorite(Customer customer) async {
    await ref.read(crmUseCasesProvider).toggleFavorite(customer);
    ref.invalidateSelf();
  }

  Future<void> addHistory(Customer customer, String note) async {
    await ref.read(crmUseCasesProvider).addCustomerNote(customer, note);
    ref.invalidate(activitiesProvider);
    ref.invalidateSelf();
  }

  Future<void> createDemoCustomer({
    required String name,
    required String company,
    required String email,
    required String phone,
    CustomerSegment segment = CustomerSegment.midMarket,
  }) {
    return saveCustomer(
      Customer(
        id: const Uuid().v4(),
        name: name,
        company: company,
        email: email,
        phone: phone,
        location: 'Remote',
        segment: segment,
        owner: 'Maya Chen',
        revenue: 0,
        isFavorite: false,
        tags: const ['New'],
        history: const ['Created from mobile CRM.'],
      ),
    );
  }
}

final dealsControllerProvider = AsyncNotifierProvider<DealsController, List<Deal>>(
  DealsController.new,
);

class DealsController extends AsyncNotifier<List<Deal>> {
  @override
  Future<List<Deal>> build() => ref.watch(crmUseCasesProvider).deals();

  Future<void> moveDeal(String id, DealStage stage) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(crmUseCasesProvider).moveDeal(id, stage));
    ref.invalidate(dashboardProvider);
  }

  Future<void> saveDeal(Deal deal) async {
    await ref.read(crmUseCasesProvider).upsertDeal(deal);
    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> deleteDeal(String id) async {
    await ref.read(crmUseCasesProvider).removeDeal(id);
    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> createDemoDeal(String title, String customerName, double value) {
    return saveDeal(
      Deal(
        id: const Uuid().v4(),
        title: title,
        customerId: 'manual',
        customerName: customerName,
        stage: DealStage.discovery,
        value: value,
        probability: 0.35,
        closeDate: DateTime.now().add(const Duration(days: 30)),
        owner: 'Maya Chen',
      ),
    );
  }
}

final tasksControllerProvider = AsyncNotifierProvider<TasksController, List<TaskItem>>(
  TasksController.new,
);

final tasksProvider = tasksControllerProvider;

class TasksController extends AsyncNotifier<List<TaskItem>> {
  @override
  Future<List<TaskItem>> build() => ref.watch(crmUseCasesProvider).tasks();

  Future<void> saveTask(TaskItem task) async {
    await ref.read(crmUseCasesProvider).upsertTask(task);
    ref.invalidate(dashboardProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidateSelf();
  }

  Future<void> toggleDone(TaskItem task) {
    final nextStatus = task.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done;
    return saveTask(task.copyWith(status: nextStatus));
  }

  Future<void> deleteTask(String id) async {
    await ref.read(crmUseCasesProvider).removeTask(id);
    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> createDemoTask(String title) {
    return saveTask(
      TaskItem(
        id: const Uuid().v4(),
        title: title,
        assignee: 'Maya Chen',
        category: 'Follow-up',
        priority: PriorityLevel.medium,
        status: TaskStatus.todo,
        dueAt: DateTime.now().add(const Duration(days: 1)),
        isRecurring: false,
      ),
    );
  }
}

final meetingsControllerProvider = AsyncNotifierProvider<MeetingsController, List<Meeting>>(
  MeetingsController.new,
);

final meetingsProvider = meetingsControllerProvider;

class MeetingsController extends AsyncNotifier<List<Meeting>> {
  @override
  Future<List<Meeting>> build() => ref.watch(crmUseCasesProvider).meetings();

  Future<void> saveMeeting(Meeting meeting) async {
    await ref.read(crmUseCasesProvider).upsertMeeting(meeting);
    ref.invalidate(dashboardProvider);
    ref.invalidate(activitiesProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidateSelf();
  }

  Future<void> deleteMeeting(String id) async {
    await ref.read(crmUseCasesProvider).removeMeeting(id);
    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> createDemoMeeting(String title, String customerName) {
    return saveMeeting(
      Meeting(
        id: const Uuid().v4(),
        title: title,
        customerName: customerName,
        startsAt: DateTime.now().add(const Duration(days: 1, hours: 2)),
        durationMinutes: 45,
        videoLink: 'https://meet.example.com/${const Uuid().v4()}',
        notes: 'Created from mobile CRM.',
      ),
    );
  }
}

final activitiesControllerProvider = AsyncNotifierProvider<ActivitiesController, List<ActivityItem>>(
  ActivitiesController.new,
);

final activitiesProvider = activitiesControllerProvider;

class ActivitiesController extends AsyncNotifier<List<ActivityItem>> {
  @override
  Future<List<ActivityItem>> build() => ref.watch(crmUseCasesProvider).activities();

  Future<void> saveActivity(ActivityItem activity) async {
    await ref.read(crmUseCasesProvider).upsertActivity(activity);
    ref.invalidate(dashboardProvider);
    ref.invalidateSelf();
  }

  Future<void> deleteActivity(String id) async {
    await ref.read(crmUseCasesProvider).removeActivity(id);
    ref.invalidateSelf();
  }

  Future<void> createLog(ActivityType type, String title, String description) {
    return saveActivity(
      ActivityItem(
        id: const Uuid().v4(),
        type: type,
        title: title,
        description: description,
        actor: 'Maya Chen',
        occurredAt: DateTime.now(),
      ),
    );
  }
}

final notificationsControllerProvider = AsyncNotifierProvider<NotificationsController, List<CrmNotification>>(
  NotificationsController.new,
);

final notificationsProvider = notificationsControllerProvider;

class NotificationsController extends AsyncNotifier<List<CrmNotification>> {
  @override
  Future<List<CrmNotification>> build() => ref.watch(crmUseCasesProvider).notifications();

  Future<void> saveNotification(CrmNotification notification) async {
    await ref.read(crmUseCasesProvider).upsertNotification(notification);
    ref.invalidateSelf();
  }

  Future<void> markRead(String id, bool isRead) async {
    await ref.read(crmUseCasesProvider).markNotificationRead(id, isRead);
    ref.invalidateSelf();
  }

  Future<void> deleteNotification(String id) async {
    await ref.read(crmUseCasesProvider).removeNotification(id);
    ref.invalidateSelf();
  }

  Future<void> createReminder(String title, String body) {
    return saveNotification(
      CrmNotification(
        id: const Uuid().v4(),
        title: title,
        body: body,
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );
  }
}

final communicationsControllerProvider = AsyncNotifierProvider<CommunicationsController, List<CommunicationRecord>>(
  CommunicationsController.new,
);

class CommunicationsController extends AsyncNotifier<List<CommunicationRecord>> {
  @override
  Future<List<CommunicationRecord>> build() => ref.watch(crmUseCasesProvider).communications();

  Future<void> createCommunication(CommunicationChannel channel, String recipient, String subject, String message) async {
    await ref.read(crmUseCasesProvider).upsertCommunication(
          CommunicationRecord(
            id: const Uuid().v4(),
            channel: channel,
            recipient: recipient,
            subject: subject,
            message: message,
            createdAt: DateTime.now(),
            status: 'Queued locally',
          ),
        );
    ref.invalidate(activitiesProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidateSelf();
  }
}

final exportsControllerProvider = AsyncNotifierProvider<ExportsController, List<ExportRecord>>(
  ExportsController.new,
);

class ExportsController extends AsyncNotifier<List<ExportRecord>> {
  @override
  Future<List<ExportRecord>> build() => ref.watch(crmUseCasesProvider).exports();

  Future<void> generateExport(String reportName, ExportFormat format) async {
    final extension = format == ExportFormat.pdf ? 'pdf' : 'xlsx';
    await ref.read(crmUseCasesProvider).upsertExport(
          ExportRecord(
            id: const Uuid().v4(),
            reportName: reportName,
            format: format,
            path: 'local_exports/${reportName.toLowerCase().replaceAll(' ', '_')}.$extension',
            createdAt: DateTime.now(),
          ),
        );
    ref.invalidate(activitiesProvider);
    ref.invalidateSelf();
  }
}
