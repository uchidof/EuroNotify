class ExchangeModel {
  final String date;
  final double brl;

  ExchangeModel({required this.date, required this.brl});

  factory ExchangeModel.fromJson(Map<String, dynamic> json) {
    return ExchangeModel(
      date: json['date'],
      brl: (json['eur']['brl'] as num).toDouble(),
    );
  }
}
