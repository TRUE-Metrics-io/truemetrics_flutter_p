/// Standardized delivery/pickup event metadata.
class StandardMetadata {
  /// Timestamp when the event happened.
  final String eventTime;

  /// Name of the event, e.g. "pickup_successful", "delivery_successful".
  final String eventType;

  /// External identifier of the delivery, e.g. parcel ID.
  final String deliveryId;

  /// Identifier of the tour.
  final String tourId;

  /// Latitude where the courier is routed to (normally a coordinate on the street).
  final String waypointLatitude;

  /// Longitude where the courier is routed to (normally a coordinate on the street).
  final String waypointLongitude;

  /// Latitude where the courier is sent (building/destination).
  final String referenceLatitude;

  /// Longitude where the courier is sent (building/destination).
  final String referenceLongitude;

  /// Raw address string, if already normalised available.
  final String address;

  /// Additional optional metadata key-value pairs.
  final Map<String, String> extra;

  const StandardMetadata({
    required this.eventTime,
    required this.eventType,
    required this.deliveryId,
    required this.tourId,
    required this.waypointLatitude,
    required this.waypointLongitude,
    required this.referenceLatitude,
    required this.referenceLongitude,
    required this.address,
    this.extra = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'eventTime': eventTime,
      'eventType': eventType,
      'deliveryId': deliveryId,
      'tourId': tourId,
      'waypointLatitude': waypointLatitude,
      'waypointLongitude': waypointLongitude,
      'referenceLatitude': referenceLatitude,
      'referenceLongitude': referenceLongitude,
      'address': address,
      'extra': extra,
    };
  }
}