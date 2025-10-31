class Warehouse {
  final int warehouseId;
  final String warehouseName;
  final String location;

  Warehouse({
    required this.warehouseId,
    required this.warehouseName,
    required this.location,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
        warehouseId: json['warehouseId'] ?? 0,
        warehouseName: json['warehouseName'] ?? '',
        location: json['location'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'warehouseId': warehouseId,
        'warehouseName': warehouseName,
        'location': location,
      };
}