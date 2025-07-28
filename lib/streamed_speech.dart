// screens/streaming_speech_screen.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class StreamingSpeechScreen extends StatefulWidget {
  const StreamingSpeechScreen({Key? key}) : super(key: key);

  @override
  State<StreamingSpeechScreen> createState() => _StreamingSpeechScreenState();
}

class _StreamingSpeechScreenState extends State<StreamingSpeechScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  List<String> _speechHistory = [];

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: onSpeechResult,
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: "en_US",
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });

    if (result.finalResult && _wordsSpoken.isNotEmpty) {
      setState(() {
        _speechHistory.insert(0, _wordsSpoken);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        title: const Text(
          'Streaming Speech Recognition',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _speechHistory.clear();
                _wordsSpoken = "";
                _confidenceLevel = 0;
              });
            },
            icon: const Icon(Icons.clear_all, color: Colors.white),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Column(
              children: [
                Text(
                  'Speech Recognition ${_speechEnabled ? 'Available' : 'Not Available'}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: _speechEnabled ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _speechToText.isListening
                                ? Icons.mic
                                : Icons.mic_off,
                            color: _speechToText.isListening
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _speechToText.isListening
                                ? 'Listening...'
                                : 'Current Speech:',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _speechToText.isListening
                            ? _wordsSpoken.isEmpty
                                ? 'Speak now...'
                                : _wordsSpoken
                            : _speechEnabled
                                ? 'Tap the microphone to start listening...'
                                : 'Speech not available',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_confidenceLevel > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Speech History (${_speechHistory.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _speechHistory.isEmpty
                      ? const Center(
                          child: Text(
                            'No speech history yet.\nStart speaking to see results here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _speechHistory.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(_speechHistory[index]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _speechHistory.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        backgroundColor: Colors.red,
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }
}
