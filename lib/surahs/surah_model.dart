class SurahModel {
  final int surah_number;
  final int verse_number;
  final String text;
  String translation;
  String audio;
  String translationDirection;

  SurahModel(
      {this.surah_number,
      this.verse_number,
      this.text,
      this.translation,
      this.audio,
      this.translationDirection});

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return new SurahModel(
      surah_number: json['surah_number'] as int,
      verse_number: json['verse_number'] as int,
      text: json['text'] as String,
      translation: json['translation'] as String,
    );
  }
}

class SurahUrlModel {
  int code;
  String status;
  Map<String, dynamic> data;

  SurahUrlModel({this.code, this.status, this.data});

  factory SurahUrlModel.fromJson(Map<String, dynamic> json, String number) {
    Map<String, dynamic> data;

    json['data']['surahs'].forEach((element) {
      if (element["number"].toString() == number) {
        data = Map<String, dynamic>.from(element);
      }
    });

    return SurahUrlModel(data: data);
  }
}

class Data {
  List<Surahs> surahs;
  Edition edition;

  Data({this.surahs, this.edition});

  factory Data.fromJson(Map<String, dynamic> json) {
    List<Surahs> surahs;
    if (json['surahs'] != null) {
      surahs = new List<Surahs>();
      json['surahs'].forEach((v) {
        if (v.number == 1) {
          surahs.add(new Surahs.fromJson(v));
        }
      });
    }
    var edition =
        json['edition'] != null ? new Edition.fromJson(json['edition']) : null;
    return new Data(surahs: surahs, edition: edition);
  }
}

class Surahs {
  int number;
  String name;
  String englishName;
  String englishNameTranslation;
  String revelationType;
  List<Ayahs> ayahs;

  Surahs(
      {this.number,
      this.name,
      this.englishName,
      this.englishNameTranslation,
      this.revelationType,
      this.ayahs});

  factory Surahs.fromJson(Map<String, dynamic> json) {
    var number = json['number'];
    var name = json['name'];
    var englishName = json['englishName'];
    var englishNameTranslation = json['englishNameTranslation'];
    var revelationType = json['revelationType'];
    var ayahs = new List<Ayahs>();
    if (json['ayahs'] != null) {
      json['ayahs'].forEach((v) {
        ayahs.add(new Ayahs.fromJson(v));
      });
    }
    return Surahs(
        ayahs: ayahs,
        englishName: englishName,
        englishNameTranslation: englishNameTranslation,
        name: name,
        number: number,
        revelationType: revelationType);
  }
}

class Ayahs {
  int number;
  String audio;
  String text;
  int numberInSurah;
  int juz;
  int manzil;
  int page;
  int ruku;
  int hizbQuarter;
  bool sajda;

  Ayahs(
      {this.number,
      this.audio,
      this.text,
      this.numberInSurah,
      this.juz,
      this.manzil,
      this.page,
      this.ruku,
      this.hizbQuarter,
      this.sajda});

  Ayahs.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    audio = json['audio'];
    text = json['text'];
    numberInSurah = json['numberInSurah'];
    juz = json['juz'];
    manzil = json['manzil'];
    page = json['page'];
    ruku = json['ruku'];
    hizbQuarter = json['hizbQuarter'];
    sajda = json['sajda'];
  }
}

class Edition {
  String identifier;
  String language;
  String name;
  String englishName;
  String format;
  String type;

  Edition(
      {this.identifier,
      this.language,
      this.name,
      this.englishName,
      this.format,
      this.type});

  Edition.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    language = json['language'];
    name = json['name'];
    englishName = json['englishName'];
    format = json['format'];
    type = json['type'];
  }
}
