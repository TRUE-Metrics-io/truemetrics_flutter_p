enum TruemetricsState {
  /// SDK is not initialized.
  /// From here, SDK can transition to INITIALIZED state.
  uninitialized,

  /// SDK is initialized and ready to record sensor data.
  /// From here, SDK can transition to RECORDING_IN_PROGRESS or UNINITIALIZED states.
  initialized,

  /// SDK initialization is delayed and will start automatically after the specified delay.
  delayedStart,

  /// Recording sensor data is in progress.
  /// From here, SDK can transition to RECORDING_STOPPED or UNINITIALIZED states.
  recordingInProgress,

  /// SDK is initialized but recording has been stopped.
  /// From here, SDK can transition to RECORDING_IN_PROGRESS or UNINITIALIZED states.
  recordingStopped,

  /// Traffic limit has been reached.
  trafficLimitReached;

  String toNativeString() {
    switch (this) {
      case TruemetricsState.uninitialized:
        return 'UNINITIALIZED';
      case TruemetricsState.initialized:
        return 'INITIALIZED';
      case TruemetricsState.delayedStart:
        return 'DELAYED_START';
      case TruemetricsState.recordingInProgress:
        return 'RECORDING_IN_PROGRESS';
      case TruemetricsState.recordingStopped:
        return 'RECORDING_STOPPED';
      case TruemetricsState.trafficLimitReached:
        return 'TRAFFIC_LIMIT_REACHED';
    }
  }

  static TruemetricsState fromNativeString(String nativeState) {
    switch (nativeState) {
      case 'UNINITIALIZED':
        return TruemetricsState.uninitialized;
      case 'INITIALIZED':
        return TruemetricsState.initialized;
      case 'DELAYED_START':
        return TruemetricsState.delayedStart;
      case 'RECORDING_IN_PROGRESS':
        return TruemetricsState.recordingInProgress;
      case 'RECORDING_STOPPED':
        return TruemetricsState.recordingStopped;
      case 'TRAFFIC_LIMIT_REACHED':
        return TruemetricsState.trafficLimitReached;
      default:
        throw ArgumentError('Unknown state: $nativeState');
    }
  }
}