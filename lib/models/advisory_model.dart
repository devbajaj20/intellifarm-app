class Advisory {
  final String id;
  final String title;
  final String crop;
  final String description;
  final String image;
  final String date;
  final bool isCritical;

  Advisory({
    required this.id,
    required this.title,
    required this.crop,
    required this.description,
    required this.image,
    required this.date,
    this.isCritical = false,
  });

  /// 🔽 FIRESTORE → APP
  factory Advisory.fromJson(
      String id,
      Map<String, dynamic> json,
      ) {
    return Advisory(
      id: id,
      title: json['title'] ?? '',
      crop: json['crop'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      date: json['date'] ?? '',
      isCritical: json['isCritical'] ?? false,
    );
  }

  /// 🔼 APP → FIRESTORE (optional but good)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'crop': crop,
      'description': description,
      'image': image,
      'date': date,
      'isCritical': isCritical,
    };
  }
}
