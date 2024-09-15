import 'dart:ui' as ui; // Importação corrigida
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'websocket_service.dart';
import 'dashboard_section.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900]?.withOpacity(0.6),
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String keyValue;
  const MyHomePage({super.key, required this.keyValue});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<String> _titles = ['Dashboard', 'Funções', 'Utilitários'];
  int? _coins;
  String? key;
  String? seller;
  String? expiryDate;
  bool canClaimMission = false;
  int missionTimeRemaining = 0;

  late WebSocketService webSocketService;
  final storage = FlutterSecureStorage();

  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  bool _isKeyLoaded = false;
  bool _isSellerLoaded = false;
  bool _isExpiryDateLoaded = false;
  bool _areCoinsLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeWebSocketService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _initializeWebSocketService() async {
    String? savedKey = await storage.read(key: 'user_key');
    print('Chave salva: $savedKey'); // Log para verificar se a chave foi carregada

    if (savedKey != null) {
      setState(() {
        key = savedKey;
      });

      webSocketService = WebSocketService(
        keyValue: savedKey,
        onCoinsUpdated: (coins) {
          setState(() {
            _coins = coins;
            _areCoinsLoaded = true;
            _checkIfLoadingComplete();
          });
        },
        onError: (error) {
          _handleError(error);
          _checkIfLoadingComplete();
        },
        onUserDataUpdated: (key, seller, expiryDate) {
          setState(() {
            this.key = key;
            this.seller = seller;
            this.expiryDate = expiryDate;
            _isKeyLoaded = true;
            _isSellerLoaded = true;
            _isExpiryDateLoaded = true;
            _checkIfLoadingComplete();
          });
        },
        onMissionUpdate: (canClaim, timeRemaining) {
          setState(() {
            canClaimMission = canClaim;
            missionTimeRemaining = timeRemaining;
          });
          _checkIfLoadingComplete();
        },
      );
      webSocketService.connect();
    } else {
      // Redireciona para a tela de login se a chave não estiver salva
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _checkIfLoadingComplete() {
    // Verifica se todas as condições de carregamento estão completas
    print('Verificação de carregamento: $_isKeyLoaded $_isSellerLoaded $_isExpiryDateLoaded $_areCoinsLoaded');
    if (_isKeyLoaded && _isSellerLoaded && _isExpiryDateLoaded && _areCoinsLoaded) {
      setState(() {
        // Estado de carregamento completo; animação é opcional
        _animationController.forward();
      });
    }
  }

  void _handleError(String message) {
    print('Erro WebSocket: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro: $message'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    webSocketService.close();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _refreshMissionStatus();
    }
  }

  void _refreshMissionStatus() {
    webSocketService.connect();
  }

  Future<void> _onRefresh() async {
    webSocketService.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_titles[_selectedIndex], style: GoogleFonts.poppins()),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${_coins ?? 0}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              backgroundColor: Colors.grey[900]?.withOpacity(0.6),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.6),
              ),
              child: Text(
                'Meu App',
                style: GoogleFonts.poppins(fontSize: 24, color: Colors.white),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
            _buildDrawerItem(Icons.apps, 'Funções', 1),
            _buildDrawerItem(Icons.build, 'Utilitários', 2),
          ],
        ),
      ),
      body: SlideTransition(
        position: _offsetAnimation,
        child: _buildCurrentScreen(),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return DashboardSection(
          onRefresh: _onRefresh,
          keyValue: key ?? 'N/A',
          seller: seller ?? 'N/A',
          expiryDate: expiryDate ?? 'N/A',
          webSocketService: webSocketService,
        );
      case 1:
        return Center(child: Text('Funções', style: GoogleFonts.poppins(fontSize: 24, color: Colors.white)));
      case 2:
        return Center(child: Text('Utilitários', style: GoogleFonts.poppins(fontSize: 24, color: Colors.white)));
      default:
        return DashboardSection(
          onRefresh: _onRefresh,
          keyValue: key ?? 'N/A',
          seller: seller ?? 'N/A',
          expiryDate: expiryDate ?? 'N/A',
          webSocketService: webSocketService,
        );
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Colors.amber : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? Colors.amber : Colors.white,
          fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _selectedIndex == index,
      selectedTileColor: Colors.grey[800],
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}
