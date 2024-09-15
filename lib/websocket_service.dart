import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketService {
  WebSocketChannel? _channel;
  final String keyValue;
  final Function(int) onCoinsUpdated;
  final Function(String) onError;
  Function(String, String, String)? onUserDataUpdated;
  Function(bool, int)? onMissionUpdate;

  WebSocketService({
    required this.keyValue,
    required this.onCoinsUpdated,
    required this.onError,
    this.onUserDataUpdated,
    this.onMissionUpdate,
  });

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://mikeregedit.glitch.me'));
      if (_channel != null) {
        _channel!.sink.add(jsonEncode({'key': keyValue}));
      }

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);

          if (data['message'] == 'success' || data['message'] == 'update') {
            int coins = data['coins'] ?? 0;
            onCoinsUpdated(coins);

            String key = data['key'] ?? '';
            String seller = data['seller'] ?? '';
            String expirydate = data['expirydate'] ?? '';
            if (onUserDataUpdated != null) {
              onUserDataUpdated!(key, seller, expirydate);
            }

            if (data.containsKey('canClaim') && onMissionUpdate != null) {
              onMissionUpdate!(data['canClaim'], data['timeRemaining']);
            }
          } else if (data['message'] == 'mission_update' && onMissionUpdate != null) {
            onMissionUpdate!(
              data['canClaim'] ?? false,
              data['timeRemaining'] ?? 0,
            );
          } else if (data['message'] == 'mission_claimed' && onMissionUpdate != null) {
            onMissionUpdate!(false, 86400); // 86400 segundos = 24 horas
          } else {
            onError('Mensagem de erro recebida: ${data['message']}');
          }
        },
        onError: (error) {
          onError('Erro no WebSocket: $error');
          reconnect();
        },
        onDone: () {
          reconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      onError('Erro ao conectar com o WebSocket: $e');
      reconnect();
    }
  }

  void claimMission(String key, int missionId) {
    if (key.isNotEmpty) {
      _channel?.sink.add(jsonEncode({'action': 'claim_mission', 'user_key': key, 'mission_id': missionId}));
    } else {
      onError('Chave do usuário está vazia. Não é possível resgatar a missão.');
    }
  }

  void reconnect() {
    close();
    Future.delayed(const Duration(seconds: 2), () {
      connect();
    });
  }

  void close() {
    if (_channel != null) {
      _channel!.sink.close();
    }
  }
}
