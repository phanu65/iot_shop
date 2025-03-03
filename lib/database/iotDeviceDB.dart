import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:account/model/iotDevice.dart';


class IoTDeviceDB {
  String dbName;

  IoTDeviceDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);
    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<int> insertDatabase(IoTDevice device) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('iot_devices');

    Future<int> keyID = store.add(db, {
      'name': device.name,
      'price': device.price,
      'date': device.date?.toIso8601String()
    });
    db.close();
    return keyID;
  }

  Future<List<IoTDevice>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('iot_devices');
    var snapshot = await store.find(db, finder: Finder(sortOrders: [SortOrder('date', false)]));

    List<IoTDevice> devices = [];
    for (var record in snapshot) {
      IoTDevice device = IoTDevice(
          keyID: record.key,
          name: record['name'].toString(),
          price: double.parse(record['price'].toString()),
          date: DateTime.parse(record['date'].toString()));
      devices.add(device);
    }
    db.close();
    return devices;
  }

  void deleteData(IoTDevice device) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('iot_devices');
    store.delete(db, finder: Finder(filter: Filter.equals(Field.key, device.keyID)));
    db.close();
  }

  void updateData(IoTDevice device) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('iot_devices');
    store.update(
        db,
        {
          'name': device.name,
          'price': device.price,
          'date': device.date?.toIso8601String()
        },
        finder: Finder(filter: Filter.equals(Field.key, device.keyID))
    );
    db.close();
  }
}
