import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'editIoTDeviceScreen.dart';
import 'addIoTDeviceScreen.dart';
import 'cartScreen.dart';
import 'orderHistoryScreen.dart';
import 'package:account/model/iotDevice.dart';
import 'package:account/provider/iotDeviceProvider.dart';
import 'package:account/provider/orderHistoryProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => IoTDeviceProvider()),
        ChangeNotifierProvider(create: (context) => OrderHistoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Device Store',
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF211C84)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'อุปกรณ์ IoT'),
    );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IoTDeviceProvider>(context, listen: false).initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4D55CC),
        title: Text(widget.title, style: GoogleFonts.prompt(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddIoTDeviceScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<IoTDeviceProvider>(
        builder: (context, provider, child) {
          if (provider.devices.isEmpty) {
            return Center(
              child: Text('ไม่มีอุปกรณ์ IoT', style: GoogleFonts.prompt(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7A73D1))),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // แสดง 2 คอลัมน์
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8, // ปรับอัตราส่วนให้เหมาะสม
            ),
            itemCount: provider.devices.length,
            itemBuilder: (context, index) {
              IoTDevice data = provider.devices[index];
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Color(0xFFB5A8D5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: data.imagePath != null && data.imagePath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.asset(data.imagePath!, width: double.infinity, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.devices, size: 70, color: Colors.grey),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.name, style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('฿${data.price.toStringAsFixed(2)}', style: GoogleFonts.prompt(fontSize: 16, color: Colors.white)),
                          Text('จำนวน: ${data.quantity} ชิ้น', style: GoogleFonts.prompt(fontSize: 14, color: Colors.white)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart, color: Colors.green, size: 30),
                        onPressed: () {
                        if (data.quantity > 0) {
                          Provider.of<IoTDeviceProvider>(context, listen: false).addToCart(data);
                          data.quantity -= 1;
                          provider.updateDevice(data);
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('เพิ่มลงตะกร้าแล้ว!', style: GoogleFonts.prompt())),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('⚠️ สินค้า ${data.name} หมดแล้ว!', style: GoogleFonts.prompt())),
                          );
                        }
                        },
                      ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 30),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditIoTDeviceScreen(device: data),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                          onPressed: () {
                            provider.deleteDevice(data);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ลบอุปกรณ์แล้ว!', style: GoogleFonts.prompt())),
                            );
                          },
                        ),
                      ],
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