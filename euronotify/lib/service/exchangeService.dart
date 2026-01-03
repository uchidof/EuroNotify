import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeService {
  static const _url =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/eur.json';

  Future<double> getEurToBrl() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['eur']['brl'] as num).toDouble();
    } else {
      throw Exception('Erro ao buscar cotação');
    }
  }
}
