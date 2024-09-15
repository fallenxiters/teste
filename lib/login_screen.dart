import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _keyController = TextEditingController();
  bool _isLoading = false;
  final storage = FlutterSecureStorage();
  String udid = "";

  @override
  void initState() {
    super.initState();
    _getOrCreateUDID();
  }

  Future<void> _getOrCreateUDID() async {
    String? storedUdid = await storage.read(key: 'device_udid');
    if (storedUdid == null) {
      storedUdid = Uuid().v4();
      await storage.write(key: 'device_udid', value: storedUdid);
    }
    setState(() {
      udid = storedUdid!;
    });
  }

  Future<void> _login() async {
    String key = _keyController.text.trim();
    String token = "tXqLZmcrIw1GwYatWl1EJjCRHVNHRoW4augNMEF5oxxH8e1Tm7akuqPpdM33CLltimwcintn6lE3/b0RvthH";

    if (key.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final response = await _loginUser(key, udid, token);

      setState(() {
        _isLoading = false;
      });

      if (response['message'] == 'success') {
        // Salva a chave após o login bem-sucedido
        await storage.write(key: 'user_key', value: key);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Login bem-sucedido!', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Key: ${response['key']}'),
                Text('Vendedor: ${response['seller']}'),
                Text('Expira em: ${response['expirydate']}'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Navega para a HomePage após o login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
              keyValue: key, // Passa a chave do usuário para MyHomePage
            ),
          ),
        );
      } else {
        _showUserFriendlyMessage(response['message']);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira a chave de acesso')),
      );
    }
  }

  void _showUserFriendlyMessage(String message) {
    String userFriendlyMessage;
    switch (message) {
      case 'missing parameters':
        userFriendlyMessage = 'Alguns parâmetros estão ausentes. Por favor, tente novamente.';
        break;
      case 'invalid token':
        userFriendlyMessage = 'Token inválido. Verifique sua conexão e tente novamente.';
        break;
      case 'disabled key':
        userFriendlyMessage = 'Sua chave foi desativada. Entre em contato com o suporte.';
        break;
      case 'invalid package':
        userFriendlyMessage = 'O pacote da chave não é compatível. Verifique suas credenciais.';
        break;
      case 'expired key':
        userFriendlyMessage = 'Sua chave expirou. Renove sua assinatura para continuar.';
        break;
      case 'cheating key':
        userFriendlyMessage = 'A chave não é válida para este dispositivo. O uso compartilhado não é permitido.';
        break;
      case 'invalid key':
        userFriendlyMessage = 'Chave incorreta. Verifique e tente novamente.';
        break;
      default:
        userFriendlyMessage = 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userFriendlyMessage),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<Map<String, dynamic>> _loginUser(String key, String udid, String token) async {
    try {
      final url = Uri.parse('https://mikeregedit.glitch.me/api/loginsystem');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': key, 'udid': udid, 'token': token}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'],
          'key': jsonResponse['key'],
          'seller': jsonResponse['seller'],
          'expirydate': jsonResponse['expirydate'],
        };
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Faça login',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Insira sua chave de acesso para continuar',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _keyController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[850],
                          hintText: 'Digite sua key',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Login', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Copyright © MIKE IOS 2024',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
