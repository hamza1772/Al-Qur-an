class SurahModel {
  final int surah_number;
  final String text;
  final String translation;

  SurahModel({this.surah_number, this.text, this.translation});

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return new SurahModel(
      surah_number: json['surah_number'] as int,
      text: json['text'] as String,
      translation: json['translation'] as String,
    );
  }
}
