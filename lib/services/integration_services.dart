class NotificationService {
  Future<void> initialize() async {
    // Firebase Messaging is configured from the native runners in a real build.
  }

  Future<void> scheduleReminder(String title) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }
}

class CommunicationService {
  Future<void> sendEmailTemplate(String recipient, String templateId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> sendSms(String recipient, String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> openWhatsapp(String recipient) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}

class ExportService {
  Future<String> exportPdf(String reportId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 'reports/$reportId.pdf';
  }

  Future<String> exportExcel(String reportId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 'reports/$reportId.xlsx';
  }
}

class CalendarService {
  Future<void> createMeetingEvent(String title, DateTime startsAt) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
