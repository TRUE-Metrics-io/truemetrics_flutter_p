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
import io.truemetrics.truemetricssdk.engine.configuration.domain.model.Configuration
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
    private var configObserverJob: Job? = null
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

        configObserverJob?.cancel()
        configObserverJob = scope.launch {
            try {
                TruemetricsSdk.getInstance().getActiveConfigFlow()?.collectLatest { config ->
                    Log.d(TAG, "Config changed")
                    eventSink?.success(mapOf(
                        "type" to "configChange",
                        "config" to serializeConfig(config)
                    ))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error observing config flow", e)
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
                    "state" to "INITIALIZED",
                    "deviceId" to status.deviceId
                ))
            }
            is Status.DelayedStart -> {
                eventSink?.success(mapOf(
                    "type" to "stateChange",
                    "state" to "DELAYED_START",
                    "deviceId" to status.deviceId,
                    "delayMs" to status.delayMs
                ))
            }
            is Status.RecordingInProgress -> {
                eventSink?.success(mapOf(
                    "type" to "stateChange",
                    "state" to "RECORDING_IN_PROGRESS",
                    "deviceId" to status.deviceId
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
            is Status.ReadingsDatabaseFull -> {
                eventSink?.success(mapOf(
                    "type" to "stateChange",
                    "state" to "READINGS_DATABASE_FULL"
                ))
            }
        }
    }

    private fun cleanupSdkListener() {
        Log.d(TAG, "cleanupSdkListener")
        statusObserverJob?.cancel()
        statusObserverJob = null
        configObserverJob?.cancel()
        configObserverJob = null
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
                    val deviceId = TruemetricsSdk.getInstance().getDeviceId()
                    result.success(deviceId ?: "")
                } catch (e: Exception) {
                    result.error("GET_DEVICE_ID_ERROR", e.message, e.toString())
                }
            }
            "isRecordingInProgress" -> {
                try {
                    val recording = TruemetricsSdk.getInstance().isRecordingInProgress()
                    result.success(recording)
                } catch (e: Exception) {
                    result.error("IS_RECORDING_IN_PROGRESS_ERROR", e.message, e.toString())
                }
            }
            "isRecordingStopped" -> {
                try {
                    val stopped = TruemetricsSdk.getInstance().isRecordingStopped()
                    result.success(stopped)
                } catch (e: Exception) {
                    result.error("IS_RECORDING_STOPPED_ERROR", e.message, e.toString())
                }
            }
            "getRecordingStartTime" -> {
                try {
                    val startTime = TruemetricsSdk.getInstance().getRecordingStartTime()
                    result.success(startTime)
                } catch (e: Exception) {
                    result.error("GET_RECORDING_START_TIME_ERROR", e.message, e.toString())
                }
            }
            "setAllSensorsEnabled" -> {
                try {
                    val enabled = call.argument<Boolean>("enabled")
                        ?: throw IllegalArgumentException("enabled is required")
                    TruemetricsSdk.getInstance().setAllSensorsEnabled(enabled)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("SET_ALL_SENSORS_ENABLED_ERROR", e.message, e.toString())
                }
            }
            "getAllSensorsEnabled" -> {
                try {
                    val enabled = TruemetricsSdk.getInstance().getAllSensorsEnabled()
                    result.success(enabled)
                } catch (e: Exception) {
                    result.error("GET_ALL_SENSORS_ENABLED_ERROR", e.message, e.toString())
                }
            }
            "getUploadStatistics" -> {
                try {
                    val stats = TruemetricsSdk.getInstance().getUploadStatistics()
                    if (stats != null) {
                        val map = hashMapOf<String, Any?>(
                            "successfulUploadsCount" to stats.successfulUploadsCount,
                            "lastSuccessfulUploadTimestamp" to stats.lastSuccessfulUploadTimestamp
                        )
                        result.success(map)
                    } else {
                        result.success(null)
                    }
                } catch (e: Exception) {
                    result.error("GET_UPLOAD_STATISTICS_ERROR", e.message, e.toString())
                }
            }
            "getSensorStatistics" -> {
                try {
                    val stats = TruemetricsSdk.getInstance().getSensorStatistics()
                    if (stats != null) {
                        val serialized = stats.map { sensor ->
                            hashMapOf<String, Any>(
                                "sensorName" to sensor.sensorName.name,
                                "configuredFrequencyHz" to sensor.configuredFrequencyHz.toDouble(),
                                "actualFrequencyHz" to sensor.actualFrequencyHz.toDouble(),
                                "quality" to sensor.quality.name
                            )
                        }
                        result.success(serialized)
                    } else {
                        result.success(null)
                    }
                } catch (e: Exception) {
                    result.error("GET_SENSOR_STATISTICS_ERROR", e.message, e.toString())
                }
            }
            "createMetadataTemplate" -> {
                try {
                    val templateName = call.argument<String>("templateName")
                        ?: throw IllegalArgumentException("templateName is required")
                    @Suppress("UNCHECKED_CAST")
                    val templateData = call.argument<Map<String, String>>("templateData")
                        ?: throw IllegalArgumentException("templateData is required")
                    TruemetricsSdk.getInstance().createMetadataTemplate(templateName, templateData)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("METADATA_TEMPLATE_ERROR", e.message, e.toString())
                }
            }
            "getMetadataTemplate" -> {
                try {
                    val templateName = call.argument<String>("templateName")
                        ?: throw IllegalArgumentException("templateName is required")
                    val template = TruemetricsSdk.getInstance().getMetadataTemplate(templateName)
                    result.success(template)
                } catch (e: Exception) {
                    result.error("METADATA_TEMPLATE_ERROR", e.message, e.toString())
                }
            }
            "getMetadataTemplateNames" -> {
                try {
                    val names = TruemetricsSdk.getInstance().getMetadataTemplateNames()
                    result.success(names.toList())
                } catch (e: Exception) {
                    result.error("METADATA_TEMPLATE_ERROR", e.message, e.toString())
                }
            }
            "removeMetadataTemplate" -> {
                try {
                    val templateName = call.argument<String>("templateName")
                        ?: throw IllegalArgumentException("templateName is required")
                    val removed = TruemetricsSdk.getInstance().removeMetadataTemplate(templateName)
                    result.success(removed)
                } catch (e: Exception) {
                    result.error("METADATA_TEMPLATE_ERROR", e.message, e.toString())
                }
            }
            "createMetadataFromTemplate" -> {
                try {
                    val tag = call.argument<String>("tag")
                        ?: throw IllegalArgumentException("tag is required")
                    val templateName = call.argument<String>("templateName")
                        ?: throw IllegalArgumentException("templateName is required")
                    val created = TruemetricsSdk.getInstance().createMetadataFromTemplate(tag, templateName)
                    result.success(created)
                } catch (e: Exception) {
                    result.error("METADATA_ERROR", e.message, e.toString())
                }
            }
            "appendToMetadataTag" -> {
                try {
                    val tag = call.argument<String>("tag")
                        ?: throw IllegalArgumentException("tag is required")
                    @Suppress("UNCHECKED_CAST")
                    val metadata = call.argument<Map<String, String>>("metadata")
                        ?: throw IllegalArgumentException("metadata is required")
                    TruemetricsSdk.getInstance().appendToMetadataTag(tag, metadata)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("METADATA_ERROR", e.message, e.toString())
                }
            }
            "appendSingleToMetadataTag" -> {
                try {
                    val tag = call.argument<String>("tag")
                        ?: throw IllegalArgumentException("tag is required")
                    val key = call.argument<String>("key")
                        ?: throw IllegalArgumentException("key is required")
                    val value = call.argument<String>("value")
                        ?: throw IllegalArgumentException("value is required")
                    TruemetricsSdk.getInstance().appendToMetadataTag(tag, key, value)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("METADATA_ERROR", e.message, e.toString())
                }
            }
            "getMetadataByTag" -> {
                try {
                    val tag = call.argument<String>("tag")
                        ?: throw IllegalArgumentException("tag is required")
                    val metadata = TruemetricsSdk.getInstance().getMetadataByTag(tag)
                    result.success(metadata)
                } catch (e: Exception) {
                    result.error("METADATA_ERROR", e.message, e.toString())
                }
            }
            "getMetadataTags" -> {
                try {
                    val tags = TruemetricsSdk.getInstance().getMetadataTags()
                    result.success(tags.toList())
                } catch (e: Exception) {
                    result.error("METADATA_ERROR", e.message, e.toString())
                }
            }
            "logMetadataByTag" -> {
                try {
                    val tag = call.argument<String>("tag")
                        ?: throw IllegalArgumentException("tag is required")
                    val logged = TruemetricsSdk.getInstance().logMetadataByTag(tag)
                    result.success(logged)
                } catch (e: Exception) {
                    result.error("METADATA_ERROR", e.message, e.toString())
                }
            }
            "removeMetadataTag" -> {
                try {
                    val tag = call.argument<String>("tag")
                        ?: throw IllegalArgumentException("tag is required")
                    val removed = TruemetricsSdk.getInstance().removeMetadataTag(tag)
                    result.success(removed)
                } catch (e: Exception) {
                    result.error("METADATA_ERROR", e.message, e.toString())
                }
            }
            "removeFromMetadataTag" -> {
                try {
                    val tag = call.argument<String>("tag")
                        ?: throw IllegalArgumentException("tag is required")
                    val key = call.argument<String>("key")
                        ?: throw IllegalArgumentException("key is required")
                    val removed = TruemetricsSdk.getInstance().removeFromMetadataTag(tag, key)
                    result.success(removed)
                } catch (e: Exception) {
                    result.error("METADATA_ERROR", e.message, e.toString())
                }
            }
            "clearAllMetadata" -> {
                try {
                    TruemetricsSdk.getInstance().clearAllMetadata()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("METADATA_ERROR", e.message, e.toString())
                }
            }
            "getActiveConfig" -> {
                try {
                    val config = TruemetricsSdk.getInstance().getActiveConfig()
                    if (config != null) {
                        result.success(serializeConfig(config))
                    } else {
                        result.success(null)
                    }
                } catch (e: Exception) {
                    result.error("GET_ACTIVE_CONFIG_ERROR", e.message, e.toString())
                }
            }
            "getSensorInfo" -> {
                try {
                    val sensorInfoList = TruemetricsSdk.getInstance().sensorInfo.value
                    val serialized = sensorInfoList.map { info ->
                        mapOf(
                            "sensorName" to info.sensorName.name,
                            "sensorStatus" to info.sensorStatus.name,
                            "frequency" to info.frequency.toDouble(),
                            "missingPermissions" to info.missingPermissions.toList()
                        )
                    }
                    result.success(serialized)
                } catch (e: Exception) {
                    result.error("GET_SENSOR_INFO_ERROR", e.message, e.toString())
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun serializeConfig(config: Configuration): Map<String, Any?> {
        return mapOf(
            "uploadMode" to config.uploadMode.name,
            "fusedLocationPollFreq" to config.fusedLocationPollFreq.toDouble(),
            "accelerometerPollFreq" to config.accelerometerPollFreq.toDouble(),
            "gyroscopePollFreq" to config.gyroscopePollFreq.toDouble(),
            "magnetometerPollFreq" to config.magnetometerPollFreq.toDouble(),
            "barometerPollFreq" to config.barometerPollFreq.toDouble(),
            "gnssPollFreq" to config.gnssPollFreq.toDouble(),
            "rawLocationPollFreq" to config.rawLocationPollFreq.toDouble(),
            "wifiPollFreq" to config.wifiPollFreq.toDouble(),
            "batteryPollFreq" to config.batteryPollFreq.toDouble(),
            "stepCounterPollFreq" to config.stepCounterPollFreq.toDouble(),
            "motionModePollFreq" to config.motionModePollFreq.toDouble(),
            "mobileDataSignalPollFreq" to config.mobileDataSignalPollFreq.toDouble(),
            "fopPollFreq" to config.fopPollFreq.toDouble(),
            "endpoint" to config.endpoint,
            "trafficLimitReached" to config.trafficLimitReached.name,
            "updateConfigPeriodSec" to config.updateConfigPeriodSec,
            "bufferLengthMinutes" to config.bufferLengthMinutes,
            "uploadPeriodSeconds" to config.uploadPeriodSeconds,
            "useWorkManager" to config.useWorkManager,
            "payloadLimitKb" to config.payloadLimitKb
        )
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
