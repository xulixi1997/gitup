class Task {
  final String id;
  final String? contactId;
  final String
  contactName; // Store name in case contact is deleted or for easy access
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final String frequency; // "Daily", "Weekly", "Monthly", "Yearly", "None"
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    this.contactId,
    required this.contactName,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    required this.frequency,
    required this.createdAt,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? contactId,
    String? contactName,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    String? frequency,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'contactName': contactName,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'frequency': frequency,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      contactId: json['contactId'],
      contactName: json['contactName'] ?? '',
      title: json['title'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      frequency: json['frequency'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}
