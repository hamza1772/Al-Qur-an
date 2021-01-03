class SurahsModel {
  final String type;
  final int ayyahs;
  final String name;
  final String nameAr;
  final String number;

  SurahsModel({this.type, this.ayyahs, this.name, this.nameAr, this.number});

  factory SurahsModel.fromJson(Map<String, dynamic> json) {
    return new SurahsModel(
      name: json['title'] as String,
      ayyahs: json['count'] as int,
      type: json['type'] as String,
      nameAr: json['titleAr'] as String,
      number: json['index'] as String,
    );
  }
}
