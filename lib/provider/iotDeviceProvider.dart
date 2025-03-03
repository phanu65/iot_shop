import 'package:flutter/foundation.dart';
import 'package:account/database/iotDeviceDB.dart';
import 'package:account/model/iotDevice.dart';

class IoTDeviceProvider with ChangeNotifier {
  List<IoTDevice> devices = [];
  List<IoTDevice> cart = [];

  List<IoTDevice> getDevices() {
    return devices;
  }

  void initData() async {
    var db = IoTDeviceDB(dbName: 'iot_devices.db');
    devices = await db.loadAllData();
    notifyListeners();
  }

  void addDevice(IoTDevice device) async {
    var db = IoTDeviceDB(dbName: 'iot_devices.db');
    await db.insertDatabase(device);
    devices = await db.loadAllData();
    notifyListeners();
  }

   Future<void> deleteDevice(IoTDevice device) async {
    var db = IoTDeviceDB(dbName: 'iot_devices.db');
    db.deleteData(device);
    devices = await db.loadAllData();
    notifyListeners();
  }

  Future<void> updateDevice(IoTDevice device) async {
    var db = IoTDeviceDB(dbName: 'iot_devices.db');
    db.updateData(device);
    devices = await db.loadAllData();
    notifyListeners();
  }
  
  
  IoTDevice? getDeviceById(int id) {
    return devices.firstWhere((device) => device.keyID == id, orElse: () => IoTDevice(keyID: -1, name: 'ไม่พบอุปกรณ์', price: 0.0, date: DateTime.now()));
  }
  
  List<IoTDevice> searchDevices(String query) {
    return devices.where((device) => device.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
  
  List<IoTDevice> filterDevicesByPrice(double minPrice, double maxPrice) {
    return devices.where((device) => device.price >= minPrice && device.price <= maxPrice).toList();
  }
  
  // ฟังก์ชันสำหรับการซื้อขาย
  void addToCart(IoTDevice device) {
    cart.add(device);
    notifyListeners();
  }
  
  void removeFromCart(IoTDevice device) {
    cart.remove(device);
    notifyListeners();
  }
  
  double getTotalPrice() {
    return cart.fold(0, (total, current) => total + current.price);
  }
  
  void checkout() {
    cart.clear();
    notifyListeners();
  }

}
