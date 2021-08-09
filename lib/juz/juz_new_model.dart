import 'dart:convert';

JuzNewModel juzNewModelFromJson(String str) {
  var decoded = json.decode(str);
  print("decode type: ${decoded.runtimeType}");
  return JuzNewModel.fromJson(decoded);
}

String juzNewModelToJson(JuzNewModel data) => json.encode(data.toJson());

class JuzNewModel {
  JuzNewModel({
    this.code,
    this.status,
    this.data,
  });

  int code;
  String status;
  Data data;

  factory JuzNewModel.fromJson(Map<String, dynamic> json) {
    return JuzNewModel(
    code: json["code"],
    status: json["status"],
    data: Data.fromJson(json["data"]),
  );
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "status": status,
    "data": data.toJson(),
  };
}

class Data {
  Data({
    this.number,
    this.ayahs,
    this.surahs,
    this.edition,
  });

  int number;
  List<NewAyah> ayahs;
  Map<String, NewSurah> surahs;
  Edition edition;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    number: json["number"],
    ayahs: List<NewAyah>.from(json["ayahs"].map((x) => NewAyah.fromJson(x))),
    surahs: Map.from(json["surahs"]).map((k, v) => MapEntry<String, NewSurah>(k, NewSurah.fromJson(v))),
    edition: Edition.fromJson(json["edition"]),
  );

  Map<String, dynamic> toJson() => {
    "number": number,
    "ayahs": List<dynamic>.from(ayahs.map((x) => x.toJson())),
    "surahs": Map.from(surahs).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
    "edition": edition.toJson(),
  };
}

class NewAyah {
  NewAyah({
    this.number,
    this.audio,
    this.audioSecondary,
    this.text,
    this.surah,
    this.numberInSurah,
    this.juz,
    this.manzil,
    this.page,
    this.ruku,
    this.hizbQuarter,
    this.sajda,
  });

  int number;
  String audio;
  List<String> audioSecondary;
  String text;
  NewSurah surah;
  int numberInSurah;
  int juz;
  int manzil;
  int page;
  int ruku;
  int hizbQuarter;
  bool sajda;

  factory NewAyah.fromJson(Map<String, dynamic> json) => NewAyah(
    number: json["number"],
    audio: json["audio"],
    audioSecondary: List<String>.from(json["audioSecondary"].map((x) => x)),
    text: json["text"],
    surah: NewSurah.fromJson(json["surah"]),
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
    "audio": audio,
    "audioSecondary": List<dynamic>.from(audioSecondary.map((x) => x)),
    "text": text,
    "surah": surah.toJson(),
    "numberInSurah": numberInSurah,
    "juz": juz,
    "manzil": manzil,
    "page": page,
    "ruku": ruku,
    "hizbQuarter": hizbQuarter,
    "sajda": sajda,
  };
}

class NewSurah {
  NewSurah({
    this.number,
    this.name,
    this.englishName,
    this.englishNameTranslation,
    this.revelationType,
    this.numberOfAyahs,
  });

  int number;
  String name;
  String englishName;
  String englishNameTranslation;
  RevelationType revelationType;
  int numberOfAyahs;

  factory NewSurah.fromJson(Map<String, dynamic> json) => NewSurah(
    number: json["number"],
    name: json["name"],
    englishName: json["englishName"],
    englishNameTranslation: json["englishNameTranslation"],
    revelationType: revelationTypeValues.map[json["revelationType"]],
    numberOfAyahs: json["numberOfAyahs"],
  );

  Map<String, dynamic> toJson() => {
    "number": number,
    "name": name,
    "englishName": englishName,
    "englishNameTranslation": englishNameTranslation,
    "revelationType": revelationTypeValues.reverse[revelationType],
    "numberOfAyahs": numberOfAyahs,
  };
}

enum RevelationType { MECCAN, MEDINAN }

final revelationTypeValues = EnumValues({
  "Meccan": RevelationType.MECCAN,
  "Medinan": RevelationType.MEDINAN
});

class Edition {
  Edition({
    this.identifier,
    this.language,
    this.name,
    this.englishName,
    this.format,
    this.type,
    this.direction,
  });

  String identifier;
  String language;
  String name;
  String englishName;
  String format;
  String type;
  dynamic direction;

  factory Edition.fromJson(Map<String, dynamic> json) => Edition(
    identifier: json["identifier"],
    language: json["language"],
    name: json["name"],
    englishName: json["englishName"],
    format: json["format"],
    type: json["type"],
    direction: json["direction"],
  );

  Map<String, dynamic> toJson() => {
    "identifier": identifier,
    "language": language,
    "name": name,
    "englishName": englishName,
    "format": format,
    "type": type,
    "direction": direction,
  };
}

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
