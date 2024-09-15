import 'package:flutter/material.dart';
import 'dart:async';
import 'websocket_service.dart';

class DashboardSection extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final String keyValue;
  final String seller;
  final String expiryDate;
  final WebSocketService webSocketService;

  const DashboardSection({
    super.key,
    required this.onRefresh,
    required this.keyValue,
    required this.seller,
    required this.expiryDate,
    required this.webSocketService,
  });

  @override
  _DashboardSectionState createState() => _DashboardSectionState();
}

class _DashboardSectionState extends State<DashboardSection> {
  bool canClaim = false;
  int timeRemaining = 0;
  Timer? _timer;

  String? _keyValue;
  String? _seller;
  String? _expiryDate;
  bool _isUserDataLoading = true;
  bool _isMissionLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebSocketService();
  }

  void _initializeWebSocketService() {
    widget.webSocketService.onMissionUpdate = updateMission;
    widget.webSocketService.onUserDataUpdated = updateUserData;
    widget.webSocketService.connect();
  }

  void updateMission(bool canClaim, int timeRemaining) {
    setState(() {
      this.canClaim = canClaim;
      this.timeRemaining = timeRemaining;
      _isMissionLoading = false; // Carregamento de missões completo
    });
    _startMissionTimer();
  }

  void updateUserData(String key, String seller, String expiryDate) {
    setState(() {
      _keyValue = key;
      _seller = seller;
      _expiryDate = expiryDate;
      _isUserDataLoading = false; // Carregamento de dados do usuário completo
    });
  }

  void _startMissionTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          canClaim = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.webSocketService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SectionTitle(title: 'Seus Dados'),
            _buildUserDataSection(),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Missões Diárias'),
            _buildMissionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDataSection() {
    if (_isUserDataLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text('Key', style: TextStyle(color: Colors.white)),
            trailing: Text(
              _keyValue ?? 'N/A',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          ListTile(
            title: const Text('Vendedor', style: TextStyle(color: Colors.white)),
            trailing: Text(
              _seller ?? 'N/A',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          ListTile(
            title: const Text('Validade', style: TextStyle(color: Colors.white)),
            trailing: Text(
              _expiryDate ?? 'N/A',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsSection() {
    if (_isMissionLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          MissionTile(
            title: 'Resgatar Moedas Diariamente',
            description: 'Faça login e resgate suas moedas a cada 24 horas.',
            reward: 10,
            canClaim: canClaim,
            timeRemaining: timeRemaining,
            onClaim: () {
              if (canClaim) {
                widget.webSocketService.claimMission(widget.keyValue, 1);
              }
            },
          ),
        ],
      ),
    );
  }
}

class MissionTile extends StatelessWidget {
  final String title;
  final String description;
  final int reward;
  final bool canClaim;
  final int timeRemaining;
  final VoidCallback onClaim;

  const MissionTile({
    required this.title,
    required this.description,
    required this.reward,
    required this.canClaim,
    required this.timeRemaining,
    required this.onClaim,
    super.key,
  });

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                'Recompensa: $reward moedas',
                style: const TextStyle(color: Colors.amber),
              ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: canClaim ? onClaim : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canClaim ? Colors.green : Colors.red,
            ),
            child: canClaim
                ? const Text('Resgatar', style: TextStyle(color: Colors.white))
                : timeRemaining > 0
                    ? Text(
                        _formatTime(timeRemaining),
                        style: const TextStyle(color: Colors.white),
                      )
                    : const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
