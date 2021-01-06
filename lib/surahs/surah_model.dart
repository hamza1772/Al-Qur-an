class SurahModel {
  final int surah_number;
  final int verse_number;
  final String text;
  final String translation;

  SurahModel(
      {this.surah_number, this.verse_number, this.text, this.translation});

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return new SurahModel(
      surah_number: json['surah_number'] as int,
      verse_number: json['verse_number'] as int,
      text: json['text'] as String,
      translation: json['translation'] as String,
    );
  }
}
