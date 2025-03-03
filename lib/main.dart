import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'editIoTDeviceScreen.dart';
import 'addIoTDeviceScreen.dart';
import 'package:account/model/iotDevice.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => IoTDeviceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            return IoTDeviceProvider();
          })
        ],
        child: MaterialApp(
          title: 'IoT Device Store',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'อุปกรณ์ IoT'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    IoTDeviceProvider provider =
        Provider.of<IoTDeviceProvider>(context, listen: false);
    provider.initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const CartScreen();
                }));
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AddIoTDeviceScreen();
                }));
              },
            ),
          ],
        ),
        body: Consumer(
          builder: (context, IoTDeviceProvider provider, Widget? child) {
            int itemCount = provider.devices.length;
            if (itemCount == 0) {
              return const Center(
                child: Text(
                  'ไม่มีอุปกรณ์ IoT',
                  style: TextStyle(fontSize: 20),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, int index) {
                    IoTDevice data = provider.devices[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: ListTile(
                          title: Text(data.name),
                          subtitle: Text(
                              'ราคา: \$${data.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14)),
                          leading: CircleAvatar(
                            child: FittedBox(
                              child: Text(data.price.toString()),
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 10,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  provider.addToCart(data);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('เพิ่ม ${data.name} ลงในตะกร้า'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return EditIoTDeviceScreen(device: data);
                                  }));
                                },
                              ),
                            ],
                          )),
                    );
                  });
            }
          },
        ));
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตะกร้าสินค้า'),
      ),
      body: Consumer<IoTDeviceProvider>(
        builder: (context, provider, child) {
          if (provider.cart.isEmpty) {
            return const Center(
              child: Text('ไม่มีสินค้าในตะกร้า'),
            );
          }
          return ListView.builder(
            itemCount: provider.cart.length,
            itemBuilder: (context, index) {
              var item = provider.cart[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('ราคา: \$${item.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () {
                        provider.decreaseQuantity(item);
                      },
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        provider.increaseQuantity(item);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class IoTDeviceProvider with ChangeNotifier {
  void initData() {
    // Initialize your data here
  }
  List<IoTDevice> devices = [];
  List<IoTDevice> cart = [];

  void addToCart(IoTDevice device) {
    int index = cart.indexWhere((item) => item.name == device.name);
    if (index != -1) {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    } else {
      cart.add(device.copyWith(quantity: 1));
    }
    notifyListeners();
  }

  void increaseQuantity(IoTDevice device) {
    int index = cart.indexWhere((item) => item.name == device.name);
    if (index != -1) {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    }
    notifyListeners();
  }

  void decreaseQuantity(IoTDevice device) {
    int index = cart.indexWhere((item) => item.name == device.name);
    if (index != -1) {
      if (cart[index].quantity > 1) {
        cart[index] = cart[index].copyWith(quantity: cart[index].quantity - 1);
      } else {
        cart.removeAt(index);
      }
    }
    notifyListeners();
  }

  double getTotalPrice() {
    return cart.fold(0, (total, current) => total + (current.price * current.quantity));
  }
  
  void checkout() {
    cart.clear();
    notifyListeners();
  }
}
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ชำระเงิน'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<IoTDeviceProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ยอดรวม: \$${provider.getTotalPrice().toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    const Text('เลือกวิธีการชำระเงิน:', style: TextStyle(fontSize: 18)),
                    ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: const Text('บัตรเครดิต / เดบิต'),
                      onTap: () {
                        // โค้ดการทำงานเมื่อเลือกชำระด้วยบัตรเครดิต
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet),
                      title: const Text('กระเป๋าเงินออนไลน์'),
                      onTap: () {
                        // โค้ดการทำงานเมื่อเลือกกระเป๋าเงินออนไลน์
                      },
                    ),
                       ListTile(
                      leading: const Icon(Icons.qr_code),
                      title: const Text('QR Code / PromptPay'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return QRPaymentScreen(amount: provider.getTotalPrice());
                        }));
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        provider.checkout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MyHomePage(title: 'อุปกรณ์ IoT')),
                          (Route<dynamic> route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('การชำระเงินเสร็จสมบูรณ์')),
                        );
                      },
                      child: const Text('ยืนยันการชำระเงิน'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class QRPaymentScreen extends StatefulWidget {
  final double amount;
  const QRPaymentScreen({super.key, required this.amount});

  @override
  _QRPaymentScreenState createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<QRPaymentScreen> {
  late Timer _timer;
  String qrData = '';
  String expiryTime = '';

  @override
  void initState() {
    super.initState();
    _generateQRData();
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _generateQRData();
    });
  }

  void _generateQRData() {
    setState(() {
      DateTime now = DateTime.now();
      DateTime expiry = now.add(const Duration(minutes: 2));
      String timestamp = now.millisecondsSinceEpoch.toString();
      qrData = 'promptpay://pay?amount=${widget.amount}&timestamp=$timestamp';
      expiryTime = '${expiry.hour}:${expiry.minute.toString().padLeft(2, '0')} น.';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ชำระเงินด้วย QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 10),
            Text('QR Code หมดอายุเวลา: $expiryTime',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 20),
            const Text('สแกน QR Code เพื่อชำระเงิน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage(title: 'อุปกรณ์ IoT')),
                  (Route<dynamic> route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('การชำระเงินเสร็จสมบูรณ์')),
                );
              },
              child: const Text('เสร็จสิ้น'),
            ),
          ],
        ),
      ),
    );
  }
}