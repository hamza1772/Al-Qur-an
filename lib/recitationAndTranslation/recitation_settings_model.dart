class RecitationSettingsModel {
  int code;
  String status;
  List<LanguageData> data;

  RecitationSettingsModel({this.code, this.status, this.data});

  RecitationSettingsModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    status = json['status'];
    if (json['data'] != null) {
      data = new List<LanguageData>();
      json['data'].forEach((v) {
        data.add(new LanguageData.fromJson(v));
      });
    }
  }
}

class LanguageData {
  String identifier;
  String language;
  String name;
  String englishName;
  String format;
  String type;
  String direction;

  LanguageData(
      {this.identifier,
      this.language,
      this.name,
      this.englishName,
      this.format,
      this.type,
      this.direction});

  LanguageData.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    language = json['language'];
    name = json['name'];
    englishName = json['englishName'];
    format = json['format'];
    type = json['type'];
    direction = json['direction'];
  }
}
