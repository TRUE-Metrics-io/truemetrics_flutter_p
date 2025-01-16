package io.truemetrics.truemetrics_flutter_sdk

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.truemetrics.truemetricssdk.ErrorCode
import io.truemetrics.truemetricssdk.StatusListener
import io.truemetrics.truemetricssdk.TruemetricsSDK
import io.truemetrics.truemetricssdk.config.Config
import io.truemetrics.truemetricssdk.engine.state.State
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/** TruemetricsFlutterSdkPlugin */
class TruemetricsFlutterSdkPlugin: FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    companion object {
        private const val TAG = "TruemetricsFlutterSdkPlugin"
    }

    private lateinit var channel : MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")

        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "truemetrics_flutter_sdk")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "truemetrics_flutter/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events

                // Set up SDK listener when stream is listened to
                setupSdkListener()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null

                // Clean up SDK listener when stream is cancelled
                cleanupSdkListener()
            }
        })
    }

    private fun setupSdkListener() {
        Log.d(TAG, "setupSdkListener")
        TruemetricsSDK.setStatusListener(object : StatusListener {
            override fun onStateChange(state: State) {
                Log.d(TAG, "onStateChange state=$state")
                CoroutineScope(Dispatchers.Main).launch {
                    eventSink?.success(
                        mapOf(
                            "type" to "stateChange",
                            "state" to state.toString()
                        )
                    )
                }
            }

            override fun onError(errorCode: ErrorCode, message: String?) {
                Log.d(TAG, "onError errorCode=$errorCode message=$message")
                CoroutineScope(Dispatchers.Main).launch {
                    eventSink?.success(mapOf(
                        "type" to "error",
                        "errorCode" to errorCode.toString(),
                        "message" to message
                    ))
                }
            }

            override fun askPermissions(permissions: List<String>) {
                Log.d(TAG, "askPermissions permissions=$permissions")
                CoroutineScope(Dispatchers.Main).launch {
                    eventSink?.success(mapOf(
                        "type" to "permissions",
                        "permissions" to permissions
                    ))
                }
            }
        })
    }

    private fun cleanupSdkListener() {
        Log.d(TAG, "cleanupSdkListener")
        TruemetricsSDK.setStatusListener(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            "initialize" -> {
                context ?: run {
                    result.error(
                        "INITIALIZATION_ERROR",
                        "Failed to initialize TruemetricsSDK, context is null",
                        null
                    )
                    result
                }

                try {
                    val configMap = call.argument<Map<String, Any>>("config")
                        ?: throw IllegalArgumentException("Config map is required")

                    val config = Config(
                        apiKey = configMap["apiKey"] as? String ?: throw IllegalArgumentException("API key is required"),
                        debug = configMap["debug"] as? Boolean ?: false,
                    )

                    val initResult = TruemetricsSDK.initialize(context!!, config)
                    result.success(initResult)
                } catch (e: Exception) {
                    result.error(
                        "INITIALIZATION_ERROR",
                        e.message ?: "Failed to initialize TruemetricsSDK",
                        e.toString()
                    )
                }
            }
            "deinitialize" -> TruemetricsSDK.deinitialize()
            "startRecording" -> TruemetricsSDK.startRecording()
            "stopRecording" -> TruemetricsSDK.stopRecording()
            "isInitialized" -> {
                val initialized = TruemetricsSDK.isInitialized()
                result.success(initialized)
            }
            "logMetadata" -> {
                try {
                    @Suppress("UNCHECKED_CAST")
                    val params = call.arguments as? Map<String, String>
                        ?: throw IllegalArgumentException("Metadata parameters must be Map<String, String>")

                    TruemetricsSDK.logMetadata(params)
                    result.success(null)
                } catch (e: Exception) {
                    result.error(
                        "METADATA_ERROR",
                        e.message ?: "Failed to log metadata",
                        e.toString()
                    )
                }
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
        context = null
        channel.setMethodCallHandler(null)
        eventSink = null
    }
}
