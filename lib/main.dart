import 'package:flutter/material.dart';

import 'api_client.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DvGravuresApp());
}

class DvGravuresApp extends StatefulWidget {
  const DvGravuresApp({super.key});

  @override
  State<DvGravuresApp> createState() => _DvGravuresAppState();
}

class _DvGravuresAppState extends State<DvGravuresApp> {
  final ApiClient _api = ApiClient();
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _api.loadToken();
    var loggedIn = false;
    if (_api.hasToken) {
      try {
        await _api.me();
        loggedIn = true;
      } catch (_) {
        await _api.logout();
      }
    }
    if (!mounted) return;
    setState(() {
      _loggedIn = loggedIn;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _api.logout();
    if (mounted) setState(() => _loggedIn = false);
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DV Gravures',
      debugShowCheckedModeBanner: false,
      theme: buildDvTheme(),
      home: _loading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _loggedIn
              ? HomeScreen(api: _api, onLogout: _logout)
              : LoginScreen(
                  api: _api,
                  onLoggedIn: () => setState(() => _loggedIn = true),
                ),
    );
  }
}
