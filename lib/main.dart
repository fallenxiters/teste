import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dashboard_section.dart'; // Importa o arquivo para o DashboardSection
import 'login_screen.dart'; // Importa o arquivo para o DashboardSection

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
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900]?.withOpacity(0.6),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<String> _titles = ['Dashboard', 'Funções', 'Utilitários'];
  int _coins = 100; // Exemplo de quantidade de moedas

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = const DashboardSection(); 
        break;
      case 1:
        currentScreen = Center(child: Text('Funções', style: GoogleFonts.poppins(fontSize: 24, color: Colors.white)));
        break;
      case 2:
        currentScreen = Center(child: Text('Utilitários', style: GoogleFonts.poppins(fontSize: 24, color: Colors.white)));
        break;
      default:
        currentScreen = const DashboardSection();
    }

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_titles[_selectedIndex], style: GoogleFonts.poppins()),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.amber), // Ícone da moeda
                      const SizedBox(width: 4),
                      Text(
                        '$_coins', // Quantidade de moedas
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
      body: currentScreen,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.apps),
                label: 'Funções',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.build),
                label: 'Utilitários',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
