import 'package:flutter/material.dart';
import 'service/exchangeService.dart';
import 'model/exchangeModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExchangeService _service = ExchangeService();
  ExchangeModel? cotacao;
  double? menorValor; // Armazenar o menor valor separadamente
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    carregarCotacao();
  }

  Future<void> carregarCotacao() async {
    try {
      final result = await _service.getEurToBrl();

      setState(() {
        // Atualizar menor valor se necessário
        if (menorValor == null || result.brl < menorValor!) {
          menorValor = result.brl;
        }

        // Criar cotação com o menor valor
        cotacao = result.copyWith(lowestValue: menorValor);
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cotação EUR → BRL')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error != null
            ? Text(error!, style: const TextStyle(color: Colors.red))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '1 EUR = ${cotacao!.brl.toStringAsFixed(2)} BRL',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data: ${cotacao!.dataFormatada}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Menor valor: ${cotacao!.lowestValue?.toStringAsFixed(2)} BRL em 07/12/2025',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => loading = true);
          carregarCotacao();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
