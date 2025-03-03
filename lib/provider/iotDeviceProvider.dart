import 'package:flutter/foundation.dart';
import 'package:account/database/iotDeviceDB.dart';
import 'package:account/model/iotDevice.dart';

class IoTDeviceProvider with ChangeNotifier {
  List<IoTDevice> devices = [];
  List<IoTDevice> cart = [];

  // โหลดข้อมูลอุปกรณ์จากฐานข้อมูล
  Future<void> initData() async {
    var db = IoTDeviceDB(dbName: 'iot_devices.db');
    devices = await db.loadAllData();
    notifyListeners();
  }

  // เพิ่มอุปกรณ์ใหม่
  Future<void> addDevice(IoTDevice device) async {
    var db = IoTDeviceDB(dbName: 'iot_devices.db');
    await db.insertDatabase(device);
    devices = await db.loadAllData();
    notifyListeners();
  }

  // ลบอุปกรณ์
  Future<void> deleteDevice(IoTDevice device) async {
    var db = IoTDeviceDB(dbName: 'iot_devices.db');
    db.deleteData(device);

    devices.removeWhere((item) => item.keyID == device.keyID);
    cart.removeWhere((item) => item.keyID == device.keyID);

    notifyListeners();
  }

  // ลดจำนวนสินค้าในคลัง (Stock) และอัปเดตฐานข้อมูล
  Future<void> decreaseStockQuantity(int keyID) async {
    var db = IoTDeviceDB(dbName: 'iot_devices.db');
    int index = devices.indexWhere((device) => device.keyID == keyID);

    if (index != -1 && devices[index].quantity > 0) {
      devices[index] = devices[index].copyWith(quantity: devices[index].quantity - 1);
       db.updateData(devices[index]); // อัปเดตฐานข้อมูล
      notifyListeners();
    }
  }

  // อัปเดตข้อมูลอุปกรณ์
  Future<void> updateDevice(IoTDevice device) async {
    var db = IoTDeviceDB(dbName: 'iot_devices.db');
    db.updateData(device);

    int index = devices.indexWhere((item) => item.keyID == device.keyID);
    if (index != -1) {
      devices[index] = device.copyWith(name: device.name);
    }

    notifyListeners();
  }

  // ค้นหาอุปกรณ์โดย ID
  IoTDevice? getDeviceById(int id) {
    return devices.firstWhere(
      (device) => device.keyID == id,
      orElse: () => IoTDevice(
        keyID: -1,
        name: 'ไม่พบอุปกรณ์',
        price: 0.0,
        date: DateTime.now(),
      ),
    );
  }

  // ค้นหาอุปกรณ์โดยชื่อ
  IoTDevice? getDeviceByName(String name) {
    return devices.firstWhere(
      (device) => device.name == name,
      orElse: () => IoTDevice(
        keyID: -1,
        name: 'ไม่พบอุปกรณ์',
        price: 0.0,
        date: DateTime.now(),
      ),
    );
  }

  // เพิ่มสินค้าลงตะกร้า
  void addToCart(IoTDevice device) {
    int index = cart.indexWhere((item) => item.keyID == device.keyID);
    if (index != -1) {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    } else {
      cart.add(device.copyWith(quantity: 1));
    }
    notifyListeners();
  }

  // เพิ่มจำนวนสินค้าในตะกร้า
  void increaseQuantity(IoTDevice device) {
    int index = cart.indexWhere((item) => item.keyID == device.keyID);
    if (index != -1) {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    }
    notifyListeners();
  }

  // ลดจำนวนสินค้าในตะกร้า
  void decreaseQuantity(IoTDevice device) {
    int index = cart.indexWhere((item) => item.keyID == device.keyID);
    if (index != -1) {
      if (cart[index].quantity > 1) {
        cart[index] = cart[index].copyWith(quantity: cart[index].quantity - 1);
      } else {
        cart.removeAt(index);
      }
    }
    notifyListeners();
  }

  // คำนวณยอดรวม
  double getTotalPrice() {
    return cart.fold(0, (total, current) => total + (current.price * current.quantity));
  }

  // ชำระเงินและเคลียร์ตะกร้า
  void checkout() {
    cart.clear();
    notifyListeners();
  }

  void clearCart() {}
}
