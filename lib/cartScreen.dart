import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:account/provider/iotDeviceProvider.dart';
import 'package:account/model/iotDevice.dart';
import 'package:account/provider/orderHistoryProvider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D55CC),
        title: Text('ตะกร้าสินค้า', style: GoogleFonts.prompt(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<IoTDeviceProvider>(
        builder: (context, provider, child) {
          if (provider.cart.isEmpty) {
            return Center(
              child: Text(
                'ไม่มีสินค้าในตะกร้า',
                style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7A73D1)),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: provider.cart.length,
                  itemBuilder: (context, index) {
                    IoTDevice item = provider.cart[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      color: Color(0xFFB5A8D5),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        title: Text(
                          item.name,
                          style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Text(
                          '฿${item.price.toStringAsFixed(2)} x ${item.quantity}',
                          style: GoogleFonts.prompt(fontSize: 16, color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.white),
                              onPressed: () => provider.decreaseQuantity(item),
                            ),
                            Text(
                              '${item.quantity}',
                              style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () => provider.increaseQuantity(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'ยอดรวม: ฿${provider.getTotalPrice().toStringAsFixed(2)}',
                      style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF211C84)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _showPaymentDialog(context, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF211C84),
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('ยืนยันการสั่งซื้อ', style: GoogleFonts.prompt(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, IoTDeviceProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('การชำระเงิน', style: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: Color(0xFF211C84))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('กรุณาชำระเงินโดยสแกน QR Code ด้านล่าง', style: GoogleFonts.prompt()),
              const SizedBox(height: 10),
              Image.asset('assets/qr_code_example.jpg', width: 200, height: 200),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏦 ธนาคาร: กรุงเทพ', style: GoogleFonts.prompt()),
                  Text('📌 หมายเลขบัญชี: 123-456-7890', style: GoogleFonts.prompt()),
                  Text('💰 จำนวนเงิน: ฿${provider.getTotalPrice().toStringAsFixed(2)}', style: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: GoogleFonts.prompt(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<OrderHistoryProvider>(context, listen: false).addOrder(provider.cart);
                provider.checkout();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ชำระเงินสำเร็จ! รายการถูกบันทึก', style: GoogleFonts.prompt())),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('ยืนยันการชำระเงิน', style: GoogleFonts.prompt(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}