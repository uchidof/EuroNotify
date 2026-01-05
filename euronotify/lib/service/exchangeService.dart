import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/exchangeModel.dart';

class ExchangeService {
  static const _url =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/eur.json';

  Future<ExchangeModel> getEurToBrl() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ExchangeModel.fromJson(json);
    } else {
      throw Exception('Erro ao buscar cotação');
    }
  }
}
