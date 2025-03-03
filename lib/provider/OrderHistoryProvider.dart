import 'package:flutter/foundation.dart';
import 'package:account/model/iotDevice.dart';

class Order {
  final List<IoTDevice> items;
  final double totalPrice;
  final DateTime date;
  final String orderId;

  Order({required this.items, required this.totalPrice, required this.date, required this.orderId});
}

class OrderHistoryProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  void addOrder(List<IoTDevice> cartItems) {
    final totalPrice = cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch}"; // สร้างรหัสคำสั่งซื้อ
    _orders.add(Order(
      items: List.from(cartItems),
      totalPrice: totalPrice,
      date: DateTime.now(),
      orderId: orderId,
    ));
    notifyListeners();
  }
}