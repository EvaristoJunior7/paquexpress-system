class PackageModel {
  final int id;
  final String trackingNumber;
  final String address;
  final String customerName;
  final String status;
  final double latitude;    // AGREGAR
  final double longitude;   // AGREGAR

  PackageModel({
    required this.id,
    required this.trackingNumber,
    required this.address,
    required this.customerName,
    required this.status,
    required this.latitude,    // AGREGAR
    required this.longitude,   // AGREGAR
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json["id"],
      trackingNumber: json["tracking_number"],
      address: json["address"],
      customerName: json["customer_name"],
      status: json["status"],
      latitude: json["latitude"]?.toDouble() ?? 0.0,    // AGREGAR
      longitude: json["longitude"]?.toDouble() ?? 0.0,  // AGREGAR
    );
  }
}