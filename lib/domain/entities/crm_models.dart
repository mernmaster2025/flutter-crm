enum LeadStatus { newLead, contacted, qualified, proposal, converted, lost }

enum PriorityLevel { low, medium, high, urgent }

enum DealStage { discovery, qualified, proposal, negotiation, won, lost }

enum TaskStatus { todo, inProgress, blocked, done }

enum ActivityType { call, email, meeting, note, sms, whatsapp }

enum CustomerSegment { enterprise, midMarket, smallBusiness, startup }

enum UserRole { admin, salesManager, salesRep, support }

extension EnumLabel on Enum {
  String get label {
    final words = name
        .replaceAllMapped(RegExp('([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ');
    return words.map((word) => '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.team,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String avatarUrl;
  final String team;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'avatarUrl': avatarUrl,
        'team': team,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: UserRole.values.byName(json['role'] as String),
        avatarUrl: json['avatarUrl'] as String? ?? '',
        team: json['team'] as String? ?? 'Sales',
      );
}

class Lead {
  const Lead({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.source,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.estimatedValue,
    required this.createdAt,
    required this.nextFollowUp,
    required this.notes,
  });

  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final String source;
  final LeadStatus status;
  final PriorityLevel priority;
  final String assignedTo;
  final double estimatedValue;
  final DateTime createdAt;
  final DateTime nextFollowUp;
  final List<String> notes;

  Lead copyWith({
    String? id,
    String? name,
    String? company,
    String? email,
    String? phone,
    String? source,
    LeadStatus? status,
    PriorityLevel? priority,
    String? assignedTo,
    double? estimatedValue,
    DateTime? createdAt,
    DateTime? nextFollowUp,
    List<String>? notes,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      source: source ?? this.source,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      createdAt: createdAt ?? this.createdAt,
      nextFollowUp: nextFollowUp ?? this.nextFollowUp,
      notes: notes ?? this.notes,
    );
  }
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.location,
    required this.segment,
    required this.owner,
    required this.revenue,
    required this.isFavorite,
    required this.tags,
    required this.history,
  });

  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final String location;
  final CustomerSegment segment;
  final String owner;
  final double revenue;
  final bool isFavorite;
  final List<String> tags;
  final List<String> history;
}

class Deal {
  const Deal({
    required this.id,
    required this.title,
    required this.customerId,
    required this.customerName,
    required this.stage,
    required this.value,
    required this.probability,
    required this.closeDate,
    required this.owner,
  });

  final String id;
  final String title;
  final String customerId;
  final String customerName;
  final DealStage stage;
  final double value;
  final double probability;
  final DateTime closeDate;
  final String owner;

  Deal copyWith({DealStage? stage}) {
    return Deal(
      id: id,
      title: title,
      customerId: customerId,
      customerName: customerName,
      stage: stage ?? this.stage,
      value: value,
      probability: probability,
      closeDate: closeDate,
      owner: owner,
    );
  }
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.assignee,
    required this.category,
    required this.priority,
    required this.status,
    required this.dueAt,
    required this.isRecurring,
  });

  final String id;
  final String title;
  final String assignee;
  final String category;
  final PriorityLevel priority;
  final TaskStatus status;
  final DateTime dueAt;
  final bool isRecurring;
}

class Meeting {
  const Meeting({
    required this.id,
    required this.title,
    required this.customerName,
    required this.startsAt,
    required this.durationMinutes,
    required this.videoLink,
    required this.notes,
  });

  final String id;
  final String title;
  final String customerName;
  final DateTime startsAt;
  final int durationMinutes;
  final String videoLink;
  final String notes;
}

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actor,
    required this.occurredAt,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final String actor;
  final DateTime occurredAt;
}

class CrmNotification {
  const CrmNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
}

class RevenuePoint {
  const RevenuePoint({
    required this.label,
    required this.revenue,
    required this.leads,
    required this.conversionRate,
  });

  final String label;
  final double revenue;
  final int leads;
  final double conversionRate;
}

class DashboardMetrics {
  const DashboardMetrics({
    required this.revenue,
    required this.totalLeads,
    required this.activeCustomers,
    required this.openPipeline,
    required this.tasksDueToday,
    required this.upcomingMeetings,
    required this.conversionRate,
    required this.monthlyGrowth,
  });

  final double revenue;
  final int totalLeads;
  final int activeCustomers;
  final double openPipeline;
  final int tasksDueToday;
  final int upcomingMeetings;
  final double conversionRate;
  final double monthlyGrowth;
}
