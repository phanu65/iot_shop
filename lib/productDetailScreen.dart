import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:account/model/iotDevice.dart';
import 'package:account/provider/iotDeviceProvider.dart';
import 'editIoTDeviceScreen.dart';

class ProductDetailScreen extends StatelessWidget {
  final IoTDevice device;

  const ProductDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          device.name,
          style: GoogleFonts.prompt(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4D55CC),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product-${device.keyID}',
              child: Image.asset(
                device.imagePath ?? 'assets/placeholder.png',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: GoogleFonts.prompt(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF211C84))),
                  const SizedBox(height: 8),
                  Text('฿${device.price.toStringAsFixed(2)}', style: GoogleFonts.prompt(fontSize: 20, color: Colors.red)),
                  const SizedBox(height: 8),
                  Consumer<IoTDeviceProvider>(
                    builder: (context, provider, child) {
                      final updatedDevice = provider.devices.firstWhere(
                        (d) => d.keyID == device.keyID,
                        orElse: () => device,
                      );
                      return Text(
                        'จำนวนที่เหลือ: ${updatedDevice.quantity}',
                        style: GoogleFonts.prompt(fontSize: 18, color: Color(0xFF7A73D1)),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final provider = Provider.of<IoTDeviceProvider>(context, listen: false);
                  final updatedDevice = provider.devices.firstWhere(
                    (d) => d.keyID == device.keyID,
                    orElse: () => device,
                  );

                  if (updatedDevice.quantity > 0) {
                    provider.addToCart(device);
                    provider.decreaseStockQuantity(device.keyID!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'เพิ่ม ${device.name} ลงตะกร้าแล้ว!',
                          style: GoogleFonts.prompt(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '⚠️ สินค้า ${device.name} หมดแล้ว!',
                          style: GoogleFonts.prompt(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF211C84),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('เพิ่มลงตะกร้า', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditIoTDeviceScreen(device: device),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A73D1)),
              child: const Text('แก้ไข', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('ยืนยันการลบ', style: GoogleFonts.prompt(fontWeight: FontWeight.bold)),
                      content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบ "${device.name}"?', style: GoogleFonts.prompt()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('ยกเลิก', style: GoogleFonts.prompt(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<IoTDeviceProvider>(context, listen: false).deleteDevice(device);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ลบ "${device.name}" แล้ว!', style: GoogleFonts.prompt()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          child: Text('ลบ', style: GoogleFonts.prompt(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('ลบ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
