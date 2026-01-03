import 'package:flutter/material.dart';
import 'service/exchangeService.dart';

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

  double? eurToBrl;
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
        eurToBrl = result;
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
      appBar: AppBar(title: const Text('Teste EUR → BRL')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error != null
            ? Text(error!, style: const TextStyle(color: Colors.red))
            : Text(
                '1 EUR = ${eurToBrl!.toStringAsFixed(2)} BRL',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
