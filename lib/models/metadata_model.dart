class MetadataModel {
  final List<String> categories;
  final List<String> nutrientLevels;
  final List<String> phLevels;
  final List<String> soilTypes;

  MetadataModel({
    required this.categories,
    required this.nutrientLevels,
    required this.phLevels,
    required this.soilTypes,
  });

  factory MetadataModel.fromJson(Map<String, dynamic> json) {
    return MetadataModel(
      categories: List<String>.from(json["categories"]),
      nutrientLevels: List<String>.from(json["nutrient_levels"]),
      phLevels: List<String>.from(json["ph_levels"]),
      soilTypes: List<String>.from(json["soil_types"]),
    );
  }
}
