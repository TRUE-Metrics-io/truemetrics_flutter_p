enum TruemetricsState {
  /// SDK is not initialized.
  /// From here, SDK can transition to INITIALIZED state.
  uninitialized,

  /// SDK is initialized and ready to record sensor data.
  /// From here, SDK can transition to RECORDING_IN_PROGRESS or UNINITIALIZED states.
  initialized,

  /// Recording sensor data is in progress.
  /// From here, SDK can transition to RECORDING_STOPPED or UNINITIALIZED states.
  recordingInProgress,

  /// SDK is initialized but recording has been stopped.
  /// From here, SDK can transition to RECORDING_IN_PROGRESS or UNINITIALIZED states.
  recordingStopped;

  String toNativeString() {
    switch (this) {
      case TruemetricsState.uninitialized:
        return 'UNINITIALIZED';
      case TruemetricsState.initialized:
        return 'INITIALIZED';
      case TruemetricsState.recordingInProgress:
        return 'RECORDING_IN_PROGRESS';
      case TruemetricsState.recordingStopped:
        return 'RECORDING_STOPPED';
    }
  }

  static TruemetricsState fromNativeString(String nativeState) {
    switch (nativeState) {
      case 'UNINITIALIZED':
        return TruemetricsState.uninitialized;
      case 'INITIALIZED':
        return TruemetricsState.initialized;
      case 'RECORDING_IN_PROGRESS':
        return TruemetricsState.recordingInProgress;
      case 'RECORDING_STOPPED':
        return TruemetricsState.recordingStopped;
      default:
        throw ArgumentError('Unknown state: $nativeState');
    }
  }
}