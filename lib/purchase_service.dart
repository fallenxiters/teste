import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'alert_helpers.dart';  // Para exibir alertas
import 'websocket_service.dart';  // Para utilizar o WebSocket

class PurchaseService {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final WebSocketService? webSocketService;
  final int coins;
  final BuildContext context;
  final Function(int) onCoinsUpdated;
  final Function() onFunctionPurchased;
  final Function() showInterstitialAd;

  PurchaseService({
    required this.webSocketService,
    required this.coins,
    required this.context,
    required this.onCoinsUpdated,
    required this.onFunctionPurchased,
    required this.showInterstitialAd,
  });

  Future<void> purchaseFunctionWithCoins(String title, int cost, Function saveAntiGravacaoState) async {
    String? userKey = await storage.read(key: 'user_key');

    if (userKey == null) {
      showErrorSheet(context, 'Erro: Chave do usuário não encontrada.');
      return;
    }

    if (coins >= cost) {
      final data = {
        'action': 'buy_function',
        'user_key': userKey,
        'function_name': title,
      };

      webSocketService?.sendMessage(jsonEncode(data));

      webSocketService?.onMessage.listen((message) {
        final response = jsonDecode(message);

        if (response['message'] == 'function_bought') {
          onCoinsUpdated(response['coinsRemaining']);
          onFunctionPurchased();  // Lógica que executa ao comprar a função
          saveAntiGravacaoState();
          showSuccessSheet(context, '${response['functionName']} comprado com sucesso!');
          showInterstitialAd();
        } else if (response['message'] == 'not_enough_coins') {
          showErrorSheet(context, 'Moedas insuficientes! Você precisa de ${response['coinsRequired']} moedas.');
        } else if (response['message'].contains('erro')) {
          showErrorSheet(context, 'Erro: ${response['message']}');
        }
      });
    } else {
      await showErrorSheet(context, 'Moedas insuficientes!');
    }
  }
}
