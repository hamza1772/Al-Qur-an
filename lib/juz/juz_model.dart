class JuzModel {
  final String startSurah;
  final String endSurah;
  final String number;
  final String startVerse;
  final String endVerse;

  JuzModel(
      {this.startSurah,
      this.endSurah,
      this.startVerse,
      this.endVerse,
      this.number});

  factory JuzModel.fromJson(Map<String, dynamic> json) {
    return new JuzModel(
      startVerse: json['start']['verse'] as String,
      endVerse: json['end']['verse'] as String,
      startSurah: json['start']['name'] as String,
      endSurah: json['end']['name'] as String,
      number: json['index'] as String,
    );
  }
}
