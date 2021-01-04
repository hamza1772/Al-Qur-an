class DuaModel {
  final String dua;
  final String translation;
  final String number;
  final String reference;

  DuaModel({this.dua, this.translation, this.reference, this.number});

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return new DuaModel(
      dua: json['dua'] as String,
      reference: json['reference'] as String,
      translation: json['translation'] as String,
      number: json['id'] as String,
    );
  }
}
