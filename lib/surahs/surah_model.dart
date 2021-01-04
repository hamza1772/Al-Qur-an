class SurahModel {
  final List<Map<String, dynamic>> verses;
  final String name;
  final String number;

  SurahModel({this.verses, this.name, this.number});

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return new SurahModel(
      name: json['name'] as String,
      verses: json['verse'] as List<Map<String, dynamic>>,
      number: json['index'] as String,
    );
  }
}
