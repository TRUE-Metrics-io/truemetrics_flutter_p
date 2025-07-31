import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:truemetrics_flutter_sdk/truemetrics_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:truemetrics_flutter_sdk/truemetrics_state.dart';

void main() {
  runApp(const TruemetricsApp());
}

class TruemetricsApp extends StatelessWidget {
  const TruemetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truemetrics API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _truemetricsPlugin = TruemetricsFlutterSdk();
  final _apiKeyController = TextEditingController(text: "");
  final _metadataKeyController = TextEditingController();
  final _metadataValueController = TextEditingController();

  TruemetricsState _sdkState = TruemetricsState.uninitialized;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _truemetricsPlugin.setStatusListener(
      onStateChange: (state) {
        print('State changed: $state');
        setState(() {
          _sdkState = state;
        });
      },
      onError: (errorCode, message) {
        print('Error: $errorCode - $message');
        _showError(errorCode, message);
      },
      onPermissionsRequired: (permissions) async {
        print('Need permissions: $permissions');
        if (permissions.contains('android.permission.ACCESS_FINE_LOCATION') ||
            permissions.contains('android.permission.ACCESS_COARSE_LOCATION')) {
          await _handleLocationPermission();
        }
      },
    );
  }

  Future<void> _initializeSdk() async {
    if (_apiKeyController.text.isEmpty) {
      _showError('INPUT_ERROR', 'API key cannot be empty');
      return;
    }

    final config = TruemetricsConfig(config: {
      'apiKey': _apiKeyController.text,
      'debug': true // Set to false for production builds
    });
    final isInit = await _truemetricsPlugin.isInitialized();
    if(isInit == false || isInit == null) {
      try {
        await _truemetricsPlugin.initialize(config);
      } catch (e) {
        print('Failed to initialize SDK: $e');
        _showError('INITIALIZATION_ERROR', e.toString());
      }
    }else{
      _sdkState = TruemetricsState.initialized;
    }
  }

  Future<void> _deinitializeSdk() async {
    try {
      await _truemetricsPlugin.deInitialize();
      setState(() {
        _sdkState = TruemetricsState.uninitialized;
      });
    } catch (e) {
      print('Failed to deinitialize SDK: $e');
      _showError('DEINITIALIZATION_ERROR', e.toString());
    }
  }

  Future<void> _logMetadata() async {
    if (_metadataKeyController.text.isEmpty || _metadataValueController.text.isEmpty) {
      _showError('METADATA_ERROR', 'Key and value cannot be empty');
      return;
    }

    try {
      await _truemetricsPlugin.logMetadata({
        _metadataKeyController.text: _metadataValueController.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Metadata logged successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Clear inputs after successful logging
      _metadataKeyController.clear();
      _metadataValueController.clear();
    } catch (e) {
      _showError('METADATA_ERROR', e.toString());
    }
  }

  void _showError(String code, String? message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error [$code]: ${message ?? 'Unknown error'}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleLocationPermission() async {
    // Request location permission
    final status = await Permission.location.request();

    if (status.isDenied) {
      _showError('PERMISSION_ERROR', 'Location permission is required for the SDK to function properly');
    }

    if (status.isPermanentlyDenied) {
      // Show dialog explaining that they need to enable permissions in settings
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
              'Location permission is required for the SDK to function properly. '
                  'Please enable it in the app settings.'
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truemetrics API Demo'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_sdkState == TruemetricsState.uninitialized) ...[
                TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeSdk,
                  child: const Text('Initialize SDK'),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recording Status:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      _sdkState == TruemetricsState.recordingInProgress ? 'Recording' : 'Not Recording',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _sdkState == TruemetricsState.recordingInProgress ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_sdkState == TruemetricsState.recordingInProgress) {
                      await _truemetricsPlugin.stopRecording();
                    } else {
                      await _truemetricsPlugin.startRecording();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sdkState == TruemetricsState.recordingInProgress ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _sdkState == TruemetricsState.recordingInProgress ? 'Stop Recording' : 'Start Recording',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _metadataKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Key',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _metadataValueController,
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _logMetadata,
                  child: const Text('Log Metadata'),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _deinitializeSdk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Deinitialize SDK'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _metadataKeyController.dispose();
    _metadataValueController.dispose();
    _truemetricsPlugin.deInitialize();
    super.dispose();
  }
}