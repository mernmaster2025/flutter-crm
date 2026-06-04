enum LeadStatus { newLead, contacted, qualified, proposal, converted, lost }

enum PriorityLevel { low, medium, high, urgent }

enum DealStage { discovery, qualified, proposal, negotiation, won, lost }

enum TaskStatus { todo, inProgress, blocked, done }

enum ActivityType { call, email, meeting, note, sms, whatsapp }

enum CustomerSegment { enterprise, midMarket, smallBusiness, startup }

enum UserRole { admin, salesManager, salesRep, support }

enum CommunicationChannel { email, sms, whatsapp, bulk }

enum ExportFormat { pdf, excel }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'company': company,
        'email': email,
        'phone': phone,
        'source': source,
        'status': status.name,
        'priority': priority.name,
        'assignedTo': assignedTo,
        'estimatedValue': estimatedValue,
        'createdAt': createdAt.toIso8601String(),
        'nextFollowUp': nextFollowUp.toIso8601String(),
        'notes': notes,
      };

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: json['id'] as String,
        name: json['name'] as String,
        company: json['company'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        source: json['source'] as String,
        status: LeadStatus.values.byName(json['status'] as String),
        priority: PriorityLevel.values.byName(json['priority'] as String),
        assignedTo: json['assignedTo'] as String,
        estimatedValue: _doubleFromJson(json['estimatedValue']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        nextFollowUp: DateTime.parse(json['nextFollowUp'] as String),
        notes: _stringList(json['notes']),
      );
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

  Customer copyWith({
    String? id,
    String? name,
    String? company,
    String? email,
    String? phone,
    String? location,
    CustomerSegment? segment,
    String? owner,
    double? revenue,
    bool? isFavorite,
    List<String>? tags,
    List<String>? history,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      segment: segment ?? this.segment,
      owner: owner ?? this.owner,
      revenue: revenue ?? this.revenue,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'company': company,
        'email': email,
        'phone': phone,
        'location': location,
        'segment': segment.name,
        'owner': owner,
        'revenue': revenue,
        'isFavorite': isFavorite,
        'tags': tags,
        'history': history,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        name: json['name'] as String,
        company: json['company'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        location: json['location'] as String,
        segment: CustomerSegment.values.byName(json['segment'] as String),
        owner: json['owner'] as String,
        revenue: _doubleFromJson(json['revenue']),
        isFavorite: json['isFavorite'] as bool,
        tags: _stringList(json['tags']),
        history: _stringList(json['history']),
      );
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

  Deal copyWith({
    String? id,
    String? title,
    String? customerId,
    String? customerName,
    DealStage? stage,
    double? value,
    double? probability,
    DateTime? closeDate,
    String? owner,
  }) {
    return Deal(
      id: id ?? this.id,
      title: title ?? this.title,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      stage: stage ?? this.stage,
      value: value ?? this.value,
      probability: probability ?? this.probability,
      closeDate: closeDate ?? this.closeDate,
      owner: owner ?? this.owner,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'customerId': customerId,
        'customerName': customerName,
        'stage': stage.name,
        'value': value,
        'probability': probability,
        'closeDate': closeDate.toIso8601String(),
        'owner': owner,
      };

  factory Deal.fromJson(Map<String, dynamic> json) => Deal(
        id: json['id'] as String,
        title: json['title'] as String,
        customerId: json['customerId'] as String,
        customerName: json['customerName'] as String,
        stage: DealStage.values.byName(json['stage'] as String),
        value: _doubleFromJson(json['value']),
        probability: _doubleFromJson(json['probability']),
        closeDate: DateTime.parse(json['closeDate'] as String),
        owner: json['owner'] as String,
      );
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

  TaskItem copyWith({
    String? id,
    String? title,
    String? assignee,
    String? category,
    PriorityLevel? priority,
    TaskStatus? status,
    DateTime? dueAt,
    bool? isRecurring,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      assignee: assignee ?? this.assignee,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'assignee': assignee,
        'category': category,
        'priority': priority.name,
        'status': status.name,
        'dueAt': dueAt.toIso8601String(),
        'isRecurring': isRecurring,
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
        id: json['id'] as String,
        title: json['title'] as String,
        assignee: json['assignee'] as String,
        category: json['category'] as String,
        priority: PriorityLevel.values.byName(json['priority'] as String),
        status: TaskStatus.values.byName(json['status'] as String),
        dueAt: DateTime.parse(json['dueAt'] as String),
        isRecurring: json['isRecurring'] as bool,
      );
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

  Meeting copyWith({
    String? id,
    String? title,
    String? customerName,
    DateTime? startsAt,
    int? durationMinutes,
    String? videoLink,
    String? notes,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      customerName: customerName ?? this.customerName,
      startsAt: startsAt ?? this.startsAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      videoLink: videoLink ?? this.videoLink,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'customerName': customerName,
        'startsAt': startsAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'videoLink': videoLink,
        'notes': notes,
      };

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
        id: json['id'] as String,
        title: json['title'] as String,
        customerName: json['customerName'] as String,
        startsAt: DateTime.parse(json['startsAt'] as String),
        durationMinutes: json['durationMinutes'] as int,
        videoLink: json['videoLink'] as String,
        notes: json['notes'] as String,
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'actor': actor,
        'occurredAt': occurredAt.toIso8601String(),
      };

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
        id: json['id'] as String,
        type: ActivityType.values.byName(json['type'] as String),
        title: json['title'] as String,
        description: json['description'] as String,
        actor: json['actor'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
      );
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

  CrmNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return CrmNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  factory CrmNotification.fromJson(Map<String, dynamic> json) => CrmNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool,
      );
}

class CommunicationRecord {
  const CommunicationRecord({
    required this.id,
    required this.channel,
    required this.recipient,
    required this.subject,
    required this.message,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final CommunicationChannel channel;
  final String recipient;
  final String subject;
  final String message;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'channel': channel.name,
        'recipient': recipient,
        'subject': subject,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  factory CommunicationRecord.fromJson(Map<String, dynamic> json) => CommunicationRecord(
        id: json['id'] as String,
        channel: CommunicationChannel.values.byName(json['channel'] as String),
        recipient: json['recipient'] as String,
        subject: json['subject'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: json['status'] as String,
      );
}

class ExportRecord {
  const ExportRecord({
    required this.id,
    required this.reportName,
    required this.format,
    required this.path,
    required this.createdAt,
  });

  final String id;
  final String reportName;
  final ExportFormat format;
  final String path;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'reportName': reportName,
        'format': format.name,
        'path': path,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ExportRecord.fromJson(Map<String, dynamic> json) => ExportRecord(
        id: json['id'] as String,
        reportName: json['reportName'] as String,
        format: ExportFormat.values.byName(json['format'] as String),
        path: json['path'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
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

List<String> _stringList(Object? value) {
  if (value is List) return value.map((item) => item.toString()).toList();
  return const [];
}

double _doubleFromJson(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
