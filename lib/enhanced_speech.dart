// screens/enhanced_speech_screen.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class EnhancedSpeechScreen extends StatefulWidget {
  const EnhancedSpeechScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedSpeechScreen> createState() => _EnhancedSpeechScreenState();
}

class _EnhancedSpeechScreenState extends State<EnhancedSpeechScreen>
    with TickerProviderStateMixin {
  SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Speech Recognition'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isListening)
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                width: _isListening ? 120 : 80,
                height: _isListening ? 120 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
            if (_isListening)
              AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                width: _isListening ? 140 : 80,
                height: _isListening ? 140 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.2),
                ),
              ),
            FloatingActionButton(
              onPressed: _listen,
              backgroundColor: Colors.orange,
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
        child: Column(
          children: [
            if (_confidence < 1.0)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _text,
                    style: const TextStyle(
                      fontSize: 24.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            _animationController.stop();
          }
        },
        onError: (val) {
          print('onError: $val');
          setState(() => _isListening = false);
          _animationController.stop();
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _animationController.repeat();
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _animationController.stop();
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
