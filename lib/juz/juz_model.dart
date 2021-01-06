class JuzModel {
  final String startSurah;
  final String endSurah;
  final String startSurahNum;
  final String endSurahNum;
  final String juzNum;
  final String startVerse;
  final String endVerse;

  JuzModel(
      {this.startSurah,
      this.endSurah,
      this.startSurahNum,
      this.endSurahNum,
      this.startVerse,
      this.endVerse,
      this.juzNum});

  factory JuzModel.fromJson(Map<String, dynamic> json) {
    return new JuzModel(
      startVerse: json['start']['verse'] as String,
      endVerse: json['end']['verse'] as String,
      startSurah: json['start']['name'] as String,
      endSurah: json['end']['name'] as String,
      startSurahNum: json['start']['index'] as String,
      endSurahNum: json['end']['index'] as String,
      juzNum: json['index'] as String,
    );
  }
}
