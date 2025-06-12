// main.dart - Integration with your Flutter app
import 'package:flutter/material.dart';
import 'package:siri_intent_poc/comdata%20copy.dart';
import 'package:siri_intent_poc/comdata.dart';
import 'package:siri_intent_poc/siri_setup_screen.dart';
import 'siri_intent_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleSiriIntent();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleSiriIntent() async {
    final String? route = await SiriIntentService.handleIncomingIntent();
    if (route != null && route.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushNamed(route);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleSiriIntent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Siri Shortcuts Demo',
      home: HomeScreen(),
      routes: {
        '/setup': (context) => SiriSetupScreen(),
        '/comdata': (context) => ComdataScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siri Shortcuts Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/setup'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text('Voice-Controlled App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings_voice),
              label: const Text('🎤 Set Up Siri Shortcuts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () => Navigator.pushNamed(context, '/setup'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/comdata'),
              child: const Text('Go to Comdata'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              child: const Text('Go to Notifications'),
            ),
            ElevatedButton(
              onPressed: () async =>
                  SiriIntentService.requestSiriAuthorization(),
              child: const Text('Authorize Siri'),
            ),
          ],
        ),
      ),
    );
  }
}
