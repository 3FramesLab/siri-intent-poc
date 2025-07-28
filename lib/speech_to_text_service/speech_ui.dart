import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
// Import your SpeechService
import 'package:siri_intent_poc/speech_to_text_service/speech_to_text_service.dart';

class MicSpeechPage extends StatefulWidget {
  const MicSpeechPage({Key? key}) : super(key: key);

  @override
  State<MicSpeechPage> createState() => _MicSpeechPageState();
}

class _MicSpeechPageState extends State<MicSpeechPage>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _spokenText = '';
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await SpeechService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
        _spokenText = '';
      });

      final result = await SpeechService.startListening();
      log("Speech result: $result");
      setState(() {
        _spokenText = result ?? '';
        _isListening = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _animation.value : 1.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red : Colors.blue,
              ),
              padding: const EdgeInsets.all(24),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Recognition'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMicButton(),
          const SizedBox(height: 40),
          Text(
            _spokenText.isEmpty ? 'Tap mic and speak...' : _spokenText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
