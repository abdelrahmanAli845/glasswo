class AppSettings {
  double qualityBonus;   // حافز الجودة
  double productionBonus; // حافز الإنتاج
  double commitmentBonus; // حافز الالتزام

  AppSettings({
    required this.qualityBonus,
    required this.productionBonus,
    required this.commitmentBonus,
  });

  Map<String, dynamic> toMap() {
    return {
      'qualityBonus': qualityBonus,
      'productionBonus': productionBonus,
      'commitmentBonus': commitmentBonus,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      qualityBonus: (map['qualityBonus'] ?? 25).toDouble(),
      productionBonus: (map['productionBonus'] ?? 25).toDouble(),
      commitmentBonus: (map['commitmentBonus'] ?? 25).toDouble(),
    );
  }
}