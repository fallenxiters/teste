import 'package:flutter/material.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SectionTitle(title: 'Seus Dados'),
          _buildUserDataSection(),
          const SizedBox(height: 20),
          const SectionTitle(title: 'Missões Diárias'),
          _buildMissionsSection(),
        ],
      ),
    );
  }

  Widget _buildUserDataSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: const [
          ListTile(
            title: Text('Key', style: TextStyle(color: Colors.white)),
            trailing: Text('123456789', style: TextStyle(color: Colors.grey)),
          ),
          Divider(height: 1, color: Colors.grey),
          ListTile(
            title: Text('Vendedor', style: TextStyle(color: Colors.white)),
            trailing: Text('ABC Corp', style: TextStyle(color: Colors.grey)),
          ),
          Divider(height: 1, color: Colors.grey),
          ListTile(
            title: Text('Validade', style: TextStyle(color: Colors.white)),
            trailing: Text('31/12/2024', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsSection() {
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
            progress: 1,
            total: 1,
          ),
          const Divider(height: 1, color: Colors.grey),
          MissionTile(
            title: 'Ativar Funções',
            description: 'Ative funções 10 vezes.',
            reward: 15,
            progress: 5,
            total: 10,
          ),
          const Divider(height: 1, color: Colors.grey),
          MissionTile(
            title: 'Login Contínuo',
            description: 'Faça login por 7 dias consecutivos.',
            reward: 20,
            progress: 3,
            total: 7,
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
  final int progress;
  final int total;

  const MissionTile({
    required this.title,
    required this.description,
    required this.reward,
    required this.progress,
    required this.total,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isComplete = progress >= total;
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
              Text(
                description,
                style: const TextStyle(color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: LinearProgressIndicator(
                  value: progress / total,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
              ),
              Text(
                '$progress/$total',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
trailing: isComplete
    ? ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        child: const Text(
          'Resgatar',
          style: TextStyle(color: Colors.white),
        ),
      )
    : Text(
        '+$reward Moedas',
        style: const TextStyle(color: Colors.amber),
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
