import 'dart:convert';

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

QuranJuzModel signUpResponseFromJson(String str) =>
    QuranJuzModel.fromJson(json.decode(str));

String signUpResponseToJson(QuranJuzModel data) => json.encode(data.toJson());

class QuranJuzModel {
  QuranJuzModel({
    this.code,
    this.status,
    this.data,
  });

  int code;
  String status;
  Data data;

  factory QuranJuzModel.fromJson(Map<String, dynamic> json) => QuranJuzModel(
        code: json["code"],
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    this.surahs,
    this.edition,
  });

  List<Surah> surahs;
  Edition edition;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        surahs: List<Surah>.from(json["surahs"].map((x) => Surah.fromJson(x))),
        edition: Edition.fromJson(json["edition"]),
      );

  Map<String, dynamic> toJson() => {
        "surahs": List<dynamic>.from(surahs.map((x) => x.toJson())),
        "edition": edition.toJson(),
      };
}

class Edition {
  Edition({
    this.identifier,
    this.language,
    this.name,
    this.englishName,
    this.format,
    this.type,
  });

  String identifier;
  String language;
  String name;
  String englishName;
  String format;
  String type;

  factory Edition.fromJson(Map<String, dynamic> json) => Edition(
        identifier: json["identifier"],
        language: json["language"],
        name: json["name"],
        englishName: json["englishName"],
        format: json["format"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "language": language,
        "name": name,
        "englishName": englishName,
        "format": format,
        "type": type,
      };
}

class Surah {
  Surah({
    this.number,
    this.name,
    this.englishName,
    this.englishNameTranslation,
    this.revelationType,
    this.ayahs,
  });

  int number;
  String name;
  String englishName;
  String englishNameTranslation;
  RevelationType revelationType;
  List<Ayah> ayahs;

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
        number: json["number"],
        name: json["name"],
        englishName: json["englishName"],
        englishNameTranslation: json["englishNameTranslation"],
        revelationType: revelationTypeValues.map[json["revelationType"]],
        ayahs: List<Ayah>.from(json["ayahs"].map((x) => Ayah.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "englishName": englishName,
        "englishNameTranslation": englishNameTranslation,
        "revelationType": revelationTypeValues.reverse[revelationType],
        "ayahs": List<dynamic>.from(ayahs.map((x) => x.toJson())),
      };
}

class Ayah {
  Ayah({
    this.number,
    this.text,
    this.numberInSurah,
    this.juz,
    this.manzil,
    this.page,
    this.ruku,
    this.hizbQuarter,
    this.sajda,
  });

  int number;
  String text;
  int numberInSurah;
  dynamic juz;
  int manzil;
  int page;
  int ruku;
  int hizbQuarter;
  dynamic sajda;

  factory Ayah.fromJson(Map<String, dynamic> json) => Ayah(
        number: json["number"],
        text: json["text"],
        numberInSurah: json["numberInSurah"],
        juz: json["juz"],
        manzil: json["manzil"],
        page: json["page"],
        ruku: json["ruku"],
        hizbQuarter: json["hizbQuarter"],
        sajda: json["sajda"],
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "text": text,
        "numberInSurah": numberInSurah,
        "juz": juz,
        "manzil": manzil,
        "page": page,
        "ruku": ruku,
        "hizbQuarter": hizbQuarter,
        "sajda": sajda,
      };
}

class SajdaClass {
  SajdaClass({
    this.id,
    this.recommended,
    this.obligatory,
  });

  int id;
  bool recommended;
  bool obligatory;

  factory SajdaClass.fromJson(Map<String, dynamic> json) => SajdaClass(
        id: json["id"],
        recommended: json["recommended"],
        obligatory: json["obligatory"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "recommended": recommended,
        "obligatory": obligatory,
      };
}

enum RevelationType { MECCAN, MEDINAN }

final revelationTypeValues = EnumValues(
    {"Meccan": RevelationType.MECCAN, "Medinan": RevelationType.MEDINAN});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
