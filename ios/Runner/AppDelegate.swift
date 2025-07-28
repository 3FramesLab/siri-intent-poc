// ios/Runner/AppDelegate.swift - Enhanced with automatic setup
import UIKit
import Flutter
import Speech

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var speechRecognizer = SFSpeechRecognizer()
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  private var resultCallback: FlutterResult?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
          let channel = FlutterMethodChannel(name: "driven_speech_to_text", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { call, result in
      if call.method == "startListening" {
        self.resultCallback = result
        self.startListening()
      } else if call.method == "stopListening" {
        self.stopListening()
        result(nil)
      }
    }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
      private func startListening() {
    SFSpeechRecognizer.requestAuthorization { authStatus in
      guard authStatus == .authorized else {
        self.resultCallback?("Permission Denied")
        return
      }

      self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
      let inputNode = self.audioEngine.inputNode

      guard let recognitionRequest = self.recognitionRequest else { return }
      recognitionRequest.shouldReportPartialResults = false

      self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
        if let result = result {
          self.resultCallback?(result.bestTranscription.formattedString)
        } else if let error = error {
          self.resultCallback?("Error: \(error.localizedDescription)")
        }
      }

      let recordingFormat = inputNode.outputFormat(forBus: 0)
      inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
        self.recognitionRequest?.append(buffer)
      }

      self.audioEngine.prepare()
      try? self.audioEngine.start()
    }
  }

  private func stopListening() {
    audioEngine.stop()
    recognitionRequest?.endAudio()
    recognitionTask?.cancel()
  }
    
   
}
