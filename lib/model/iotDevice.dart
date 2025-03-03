class IoTDevice {
  int? keyID;
  String name;
  double price;
  DateTime? date;
  int quantity;

  IoTDevice({this.keyID, required this.name, required this.price, this.date, this.quantity = 1});

  IoTDevice copyWith({int? keyID, String? name, double? price, DateTime? date, int? quantity}) {
    return IoTDevice(
      keyID: keyID ?? this.keyID,
      name: name ?? this.name,
      price: price ?? this.price,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
    );
  }
}