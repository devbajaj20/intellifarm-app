class CropStage {
  final String name;
  final int startDay;
  final int endDay;

  CropStage({
    required this.name,
    required this.startDay,
    required this.endDay,
  });

  factory CropStage.fromJson(Map<String, dynamic> json) {
    return CropStage(
      name: json['name'] ?? '',
      startDay: (json['startDay'] ?? 0) as int,
      endDay: (json['endDay'] ?? 0) as int,
    );
  }
}
