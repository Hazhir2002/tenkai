class Program {
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;

  const Program({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}
