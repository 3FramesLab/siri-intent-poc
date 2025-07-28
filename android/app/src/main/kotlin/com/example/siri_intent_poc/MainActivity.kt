package com.example.siri_intent_poc
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val CHANNEL = "driven_speech_to_text"
    private var speechRecognizer: SpeechRecognizer? = null
    private var resultCallback: MethodChannel.Result? = null
    private val handler = Handler(Looper.getMainLooper())
    private var silenceRunnable: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    startSpeechRecognition(call, result)
                }
                "stopListening" -> {
                    stopListening()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startSpeechRecognition(call: MethodCall, result: MethodChannel.Result) {
        resultCallback = result

        if (speechRecognizer == null) {
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
            speechRecognizer?.setRecognitionListener(object : RecognitionListener {
                override fun onReadyForSpeech(params: Bundle?) {
                    startSilenceTimeout()
                }

                override fun onBeginningOfSpeech() {
                    cancelSilenceTimeout()
                }

                override fun onEndOfSpeech() {
                    // Will be auto-stopped by Android. Do nothing.
                }

                override fun onResults(results: Bundle?) {
                    cancelSilenceTimeout()
                    val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    resultCallback?.success(matches?.firstOrNull() ?: "")
                }

                override fun onError(error: Int) {
                    cancelSilenceTimeout()
                    resultCallback?.success("") // You can pass "Error: $error" if needed
                }

                override fun onRmsChanged(rmsdB: Float) {}
                override fun onBufferReceived(buffer: ByteArray?) {}
                override fun onPartialResults(partialResults: Bundle?) {}
                override fun onEvent(eventType: Int, params: Bundle?) {}
            })
        }

        val locale = call.argument<String>("locale")
        val localeObj = if (locale != null) Locale.forLanguageTag(locale) else Locale.getDefault()

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, localeObj.toLanguageTag())
        }

        speechRecognizer?.startListening(intent)
    }

    private fun stopListening() {
        cancelSilenceTimeout()
        speechRecognizer?.stopListening()
    }

    private fun startSilenceTimeout() {
        silenceRunnable = Runnable {
            speechRecognizer?.stopListening()
            resultCallback?.success("") // return empty string if silence
        }
        handler.postDelayed(silenceRunnable!!, 3000) // 3 seconds timeout
    }

    private fun cancelSilenceTimeout() {
        silenceRunnable?.let {
            handler.removeCallbacks(it)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        speechRecognizer?.destroy()
        speechRecognizer = null
    }
}
