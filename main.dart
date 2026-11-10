import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const TalkToAIApp());

class TalkToAIApp extends StatelessWidget {
  const TalkToAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talk to AI',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF1A237E), 
        scaffoldBackgroundColor: const Color(0xFF0A121D), 
      ),
      home: const LoginScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}

// 1. LOGIN & SIGN UP SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  Future<void> handleAuth() async {
    setState(() { _isLoading = true; });
    
    String endpoint = _isSignUp ? 'signUp' : 'signInWithPassword';
    final url = Uri.parse('https://supabase.co');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'apiKey': 'sb_publishable_eNG9TS9-5eEUam78K_IoPw_VRE2wfsf', // Ufunguo wako umewekwa hapa kikamilifu
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(errorData['msg'] ?? 'Authentication failed.');
      }
    } catch (e) {
      _showSnackBar('Network error. Please try again.');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A121D),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.blur_on_rounded, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  _isSignUp ? 'Create your Account' : 'Welcome to Talk to AI',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading) const CircularProgressIndicator(color: Colors.white),
                if (!_isLoading)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: handleAuth,
                      child: Text(
                        _isSignUp ? 'SIGN UP' : 'LOGIN',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    setState(() { _isSignUp = !_isSignUp; });
                  },
                  child: Text(
                    _isSignUp ? 'Already have an account? Login' : "Don't have an account? Sign Up",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2. CHAT SCREEN
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _aiResponse = "Welcome to Talk to AI Pro!\nYou have 15 Free Messages.";
  bool _isLoading = false;
  
  int _freeMessagesLeft = 15; 
  bool _isPremiumUser = false; 

  Future<void> sendMessageToAI(String message) async {
    if (!_isPremiumUser && _freeMessagesLeft <= 0) {
      _showAdScreen();
      return;
    }

    setState(() { _isLoading = true; });

    final url = Uri.parse('https://supabase.co');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer sb_publishable_eNG9TS9-5eEUam78K_IoPw_VRE2wfsf', // Ufunguo wako umewekwa hapa pia
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() { 
          _aiResponse = data['response']; 
          if (!_isPremiumUser) {
            _freeMessagesLeft--; 
          }
        });
      } else {
        setState(() { _aiResponse = "Error: Failed to get response."; });
      }
    } catch (e) {
      setState(() { _aiResponse = "Error: Connection failed."; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showAdScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdScreen()),
    );
    
    if (result == true) {
      setState(() {
        _freeMessagesLeft = 5;
        _aiResponse = "Thank you for watching! You have unlocked 5 more Free Messages. 🚀";
      });
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A237E),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isPremiumUser ? 'Talk to AI Pro 👑' : 'Free Messages: $_freeMessagesLeft',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        actions: [
          if (!_isPremiumUser)
            TextButton.icon(
              onPressed: () async {
                final proActivated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PremiumPaywallScreen()),
                );
                if (proActivated == true) {
                  setState(() { _isPremiumUser = true; });
                }
              },
              icon: const Icon(Icons.star, color: Colors.amber),
              label: const Text('Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _aiResponse,
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
                ),
              ),
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(color: Colors.white),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
            child: Row(
              children: [
                Expanded(
