package io.truemetrics.truemetrics_flutter_sdk

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.truemetrics.truemetricssdk.TruemetricsSdk
import io.truemetrics.truemetricssdk.config.SdkConfiguration
import io.truemetrics.truemetricssdk.engine.state.Status
import io.truemetrics.truemetricssdk.engine.ErrorCode
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.flow.collectLatest

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
    private var statusObserverJob: Job? = null
    private val supervisorJob = SupervisorJob()
    private val scope = CoroutineScope(Dispatchers.Main + supervisorJob)

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
        statusObserverJob?.cancel()
        statusObserverJob = scope.launch {
            try {
                TruemetricsSdk.getInstance().observeSdkStatus().collectLatest { status ->
                    Log.d(TAG, "Status changed: $status")
                    handleStatusChange(status)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error observing SDK status", e)
            }
        }
    }

    private fun handleStatusChange(status: Status) {
        when (status) {
            is Status.Uninitialized -> {
                eventSink?.success(mapOf(
                    "type" to "stateChange",
                    "state" to "UNINITIALIZED"
                ))
            }
            is Status.Initialized -> {
                eventSink?.success(mapOf(
                    "type" to "stateChange",
                    "state" to "INITIALIZED"
                ))
            }
            is Status.DelayedStart -> {
                eventSink?.success(mapOf(
                    "type" to "stateChange",
                    "state" to "DELAYED_START"
                ))
            }
            is Status.RecordingInProgress -> {
                eventSink?.success(mapOf(
                    "type" to "stateChange",
                    "state" to "RECORDING_IN_PROGRESS"
                ))
            }
            is Status.RecordingStopped -> {
                eventSink?.success(mapOf(
                    "type" to "stateChange",
                    "state" to "RECORDING_STOPPED"
                ))
            }
            is Status.Error -> {
                eventSink?.success(mapOf(
                    "type" to "error",
                    "errorCode" to status.errorCode.toString(),
                    "message" to status.message
                ))
            }
            is Status.AskForPermissions -> {
                eventSink?.success(mapOf(
                    "type" to "permissions",
                    "permissions" to status.permissions.toList()
                ))
            }
            is Status.TrafficLimitReached -> {
                eventSink?.success(mapOf(
                    "type" to "stateChange",
                    "state" to "TRAFFIC_LIMIT_REACHED"
                ))
            }
        }
    }

    private fun cleanupSdkListener() {
        Log.d(TAG, "cleanupSdkListener")
        statusObserverJob?.cancel()
        statusObserverJob = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            "initialize" -> {
                context ?: run {
                    result.error(
                        "INITIALIZATION_ERROR",
                        "Failed to initialize TruemetricsSdk, context is null",
                        null
                    )
                    return
                }

                try {
                    val configMap = call.argument<Map<String, Any>>("config")
                        ?: throw IllegalArgumentException("Config map is required")

                    val apiKey = configMap["apiKey"] as? String
                        ?: throw IllegalArgumentException("API key is required")

                    val configBuilder = SdkConfiguration.Builder(apiKey)

                    // Handle delayAutoStartRecording if provided
                    val delayMs = configMap["delayAutoStartRecording"] as? Number
                    if (delayMs != null) {
                        configBuilder.delayAutoStartRecording(delayMs.toLong())
                    }

                    val config = configBuilder.build()
                    TruemetricsSdk.init(context!!, config)

                    // Return empty string as device ID (not available in public API)
                    result.success("")
                } catch (e: Exception) {
                    result.error(
                        "INITIALIZATION_ERROR",
                        e.message ?: "Failed to initialize TruemetricsSdk",
                        e.toString()
                    )
                }
            }
            "deinitialize" -> {
                try {
                    TruemetricsSdk.getInstance().deinitialize()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("DEINITIALIZE_ERROR", e.message, e.toString())
                }
            }
            "startRecording" -> {
                try {
                    TruemetricsSdk.getInstance().startRecording()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("START_RECORDING_ERROR", e.message, e.toString())
                }
            }
            "stopRecording" -> {
                try {
                    TruemetricsSdk.getInstance().stopRecording()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("STOP_RECORDING_ERROR", e.message, e.toString())
                }
            }
            "isInitialized" -> {
                try {
                    val status = TruemetricsSdk.getInstance().sdkStatus.value
                    val initialized = status !is Status.Uninitialized
                    result.success(initialized)
                } catch (e: Exception) {
                    // SDK not initialized yet
                    result.success(false)
                }
            }
            "logMetadata" -> {
                try {
                    @Suppress("UNCHECKED_CAST")
                    val params = call.arguments as? Map<String, String>
                        ?: throw IllegalArgumentException("Metadata parameters must be Map<String, String>")

                    TruemetricsSdk.getInstance().logMetadata(params)
                    result.success(null)
                } catch (e: Exception) {
                    result.error(
                        "METADATA_ERROR",
                        e.message ?: "Failed to log metadata",
                        e.toString()
                    )
                }
            }
            "getDeviceId" -> {
                try {
                    val deviceId = TruemetricsSdk.getInstance().deviceIdFlow.value
                    result.success(deviceId ?: "")
                } catch (e: Exception) {
                    result.error("GET_DEVICE_ID_ERROR", e.message, e.toString())
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
        cleanupSdkListener()
        supervisorJob.cancel()
        context = null
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }
}
