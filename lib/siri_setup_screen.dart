import 'package:flutter/material.dart';
import 'package:siri_intent_poc/siri_intent_service.dart';

class SiriSetupScreen extends StatefulWidget {
  @override
  _SiriSetupScreenState createState() => _SiriSetupScreenState();
}

class _SiriSetupScreenState extends State<SiriSetupScreen> {
  bool _siriAvailable = false;
  bool _siriAuthorized = false;
  bool _isLoading = false;
  // List<Map<String, dynamic>> _existingShortcuts = [];
  List<dynamic> _existingShortcuts = [];
  String _statusMessage = "Checking Siri availability...";

  @override
  void initState() {
    super.initState();
    _checkSiriStatus();
  }

  Future<void> _checkSiriStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Checking Siri status...";
    });

    final status = await SiriIntentService.checkSiriStatus();
    final shortcuts = await SiriIntentService.getVoiceShortcuts();

    setState(() {
      _siriAvailable = status['available'] ?? false;
      _siriAuthorized = status['authorized'] ?? false;
      _existingShortcuts = shortcuts;
      _isLoading = false;

      if (!_siriAvailable) {
        _statusMessage = "Siri is not available on this device";
      } else if (!_siriAuthorized) {
        _statusMessage = "Siri access not authorized";
      } else {
        _statusMessage =
            "Siri is ready! ${_existingShortcuts.length} shortcuts configured";
      }
    });
  }

  Future<void> _setupSiriAutomatically() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Setting up Siri...";
    });

    // Step 1: Request Siri authorization
    if (!_siriAuthorized) {
      setState(() => _statusMessage = "Requesting Siri permission...");
      final authorized = await SiriIntentService.requestSiriAuthorization();

      if (!authorized) {
        setState(() {
          _statusMessage = "Siri permission denied. Please enable in Settings.";
          _isLoading = false;
        });
        return;
      }
    }

    // Step 2: Donate shortcuts
    setState(() => _statusMessage = "Creating shortcuts...");
    await SiriIntentService.donateShortcuts();

    // Step 3: Present Add to Siri sheets
    setState(() => _statusMessage = "Adding voice commands...");

    bool comdataAdded =
        await SiriIntentService.presentAddToSiriSheet('open_comdata');
    if (comdataAdded) {
      await Future.delayed(const Duration(seconds: 1)); // Wait between sheets
      await SiriIntentService.presentAddToSiriSheet('open_notifications');
    }

    // Step 4: Refresh status
    await _checkSiriStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Siri Setup'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _siriAuthorized ? Colors.green[50] : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _siriAuthorized ? Icons.check_circle : Icons.warning,
                      size: 48,
                      color: _siriAuthorized ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 12),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Available Shortcuts
            const Text(
              'Available Voice Commands:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildShortcutCard(
              '📊 Open Comdata',
              '"Hey Siri, Open Comdata"',
              'open_comdata',
              Icons.data_usage,
              Colors.blue,
            ),

            const SizedBox(height: 8),

            _buildShortcutCard(
              '🔔 Open Notifications',
              '"Hey Siri, Open Notifications"',
              'open_notifications',
              Icons.notifications,
              Colors.orange,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (!_siriAuthorized) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _setupSiriAutomatically,
                child: const Text(
                  '🚀 Set Up Siri Automatically',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _setupSiriAutomatically,
                child: const Text(
                  '🔄 Update Siri Shortcuts',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Manual Setup Button
            OutlinedButton(
              onPressed: () async {
                final opened = await SiriIntentService.openAppSettings();
                if (!opened) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please go to Settings > Siri & Search manually'),
                    ),
                  );
                }
              },
              child: const Text('⚙️ Open Settings Manually'),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 How it works:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Tap "Set Up Siri Automatically"',
                      style: TextStyle(fontSize: 12)),
                  const Text('2. Allow Siri access when prompted',
                      style: TextStyle(fontSize: 12)),
                  const Text('3. Record your voice phrases',
                      style: TextStyle(fontSize: 12)),
                  const Text('4. Start using voice commands!',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),

            const Spacer(),

            // Test Navigation
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/comdata'),
                    child: const Text('Test Comdata'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notifications'),
                    child: const Text('Test Notifications'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutCard(String title, String phrase, String identifier,
      IconData icon, Color color) {
    final isConfigured =
        _existingShortcuts.any((s) => s['identifier'] == identifier);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle:
            Text(phrase, style: const TextStyle(fontStyle: FontStyle.italic)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isConfigured)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () async {
                await SiriIntentService.presentAddToSiriSheet(identifier);
                _checkSiriStatus();
              },
            ),
          ],
        ),
      ),
    );
  }
}
