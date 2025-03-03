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

  // ลบอุปกรณ์จากรายการ devices โดยไม่ต้องโหลดข้อมูลใหม่ทั้งหมด
  devices.removeWhere((item) => item.keyID == device.keyID);

  // ลบอุปกรณ์จากตะกร้าสินค้า (ถ้ามี)
  cart.removeWhere((item) => item.keyID == device.keyID);

  notifyListeners();
}

// อัปเดตข้อมูลอุปกรณ์
Future<void> updateDevice(IoTDevice device) async {
  var db = IoTDeviceDB(dbName: 'iot_devices.db');
  db.updateData(device);

  // อัปเดตข้อมูลอุปกรณ์ในรายการ devices โดยไม่ต้องโหลดข้อมูลใหม่ทั้งหมด
  int index = devices.indexWhere((item) => item.keyID == device.keyID);
  if (index != -1) {
    devices[index] = device;
  }

  // อัปเดตข้อมูลอุปกรณ์ในตะกร้าสินค้า (ถ้ามี)
  int cartIndex = cart.indexWhere((item) => item.keyID == device.keyID);
  if (cartIndex != -1) {
    cart[cartIndex] = device.copyWith(quantity: cart[cartIndex].quantity);
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
  List<IoTDevice> searchDevices(String query) {
    return devices
        .where((device) => device.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // กรองอุปกรณ์ตามราคา
  List<IoTDevice> filterDevicesByPrice(double minPrice, double maxPrice) {
    return devices
        .where((device) => device.price >= minPrice && device.price <= maxPrice)
        .toList();
  }

  // ฟังก์ชันการจัดการตะกร้าสินค้า

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
}