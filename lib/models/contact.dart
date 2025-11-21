class Contact {
  final String id;
  final String name;
  final String taskTitle;
  final String frequency; // "Daily", "Weekly", "Monthly", "Yearly", "None"
  final int colorIndex;

  Contact({
    required this.id,
    required this.name,
    required this.taskTitle,
    required this.frequency,
    required this.colorIndex,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'taskTitle': taskTitle,
      'frequency': frequency,
      'colorIndex': colorIndex,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      taskTitle: json['taskTitle'],
      frequency: json['frequency'],
      colorIndex: json['colorIndex'],
    );
  }
}
