class IoTDevice {
  int? keyID;
  String name;
  double price;
  DateTime? date;
  int quantity;
  String? category;
  String? imagePath;

  IoTDevice({
    this.keyID,
    required this.name,
    required this.price,
    this.date,
    this.quantity = 1,
    this.category,
    this.imagePath,
  });

  IoTDevice copyWith({
    int? keyID,
    String? name,
    double? price,
    DateTime? date,
    int? quantity,
    String? category,
    String? imagePath,
  }) {
    return IoTDevice(
      keyID: keyID ?? this.keyID,
      name: name ?? this.name,
      price: price ?? this.price,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}