class ExchangeModel {
  final String date;
  final double brl;
  final double? lowestValue = 6.16;

  ExchangeModel({required this.date, required this.brl});

  factory ExchangeModel.fromJson(Map<String, dynamic> json) {
    return ExchangeModel(
      date: json['date'],
      brl: (json['eur']['brl'] as num).toDouble(),
    );
  }

  // Método para criar uma cópia com menor valor atualizado
  ExchangeModel copyWith({String? date, double? brl, double? lowestValue}) {
    return ExchangeModel(date: date ?? this.date, brl: brl ?? this.brl);
  }

  // Método para converter para JSON (útil para salvar)
  Map<String, dynamic> toJson() {
    return {'date': date, 'brl': brl, 'lowestValue': lowestValue};
  }

  // Método para formatar a data
  String get dataFormatada {
    final partes = date.split('-');
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }
}
