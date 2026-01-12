import 'package:flutter/material.dart';
import 'service/exchangeService.dart';
import 'service/notificationService.dart';
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
  bool notificacoesAtivas = false;
  TimeOfDay horarioSelecionado = const TimeOfDay(hour: 20, minute: 30);

  @override
  void initState() {
    super.initState();
    carregarCotacao();
    verificarNotificacoes();
  }

  Future<void> verificarNotificacoes() async {
    final hasNotifications =
        await NotificationService.hasScheduledNotifications();
    setState(() {
      notificacoesAtivas = hasNotifications;
    });
  }

  Future<void> carregarCotacao() async {
    print('[app]: CARREGANDO COTACAO...');
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

      print('[app]: COTACAO ATUALIZADA');
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> selecionarHorario() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horarioSelecionado,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        horarioSelecionado = picked;
      });
    }
  }

  Future<void> ativarNotificacoes() async {
    await NotificationService.scheduleDailyNotification(
      id: 1,
      title: 'Cotação EUR → BRL',
      body: 'Confira a cotação atualizada do Euro!',
      hour: horarioSelecionado.hour,
      minute: horarioSelecionado.minute,
    );

    setState(() {
      notificacoesAtivas = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notificações ativadas para ${horarioSelecionado.hour.toString().padLeft(2, '0')}:${horarioSelecionado.minute.toString().padLeft(2, '0')}',
          ),
        ),
      );
    }
  }

  Future<void> desativarNotificacoes() async {
    await NotificationService.cancelAllNotifications();
    setState(() {
      notificacoesAtivas = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Notificações desativadas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotação EUR → BRL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loading ? null : carregarCotacao,
            tooltip: 'Atualizar cotação',
          ),
        ],
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: carregarCotacao,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
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
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Menor valor: ${cotacao!.lowestValue?.toStringAsFixed(2)} BRL em 07/12/2025',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 20),
                    const Text(
                      'Notificações Diárias',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Horário:'),
                                TextButton.icon(
                                  onPressed: selecionarHorario,
                                  icon: const Icon(Icons.access_time),
                                  label: Text(
                                    '${horarioSelecionado.hour.toString().padLeft(2, '0')}:${horarioSelecionado.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: notificacoesAtivas
                                    ? desativarNotificacoes
                                    : ativarNotificacoes,
                                icon: Icon(
                                  notificacoesAtivas
                                      ? Icons.notifications_off
                                      : Icons.notifications_active,
                                ),
                                label: Text(
                                  notificacoesAtivas
                                      ? 'Desativar Notificações'
                                      : 'Ativar Notificações',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  backgroundColor: notificacoesAtivas
                                      ? Colors.red
                                      : Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            if (notificacoesAtivas) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Notificações ativas às ${horarioSelecionado.hour.toString().padLeft(2, '0')}:${horarioSelecionado.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
