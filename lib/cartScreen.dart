import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account/provider/iotDeviceProvider.dart';
import 'package:account/model/iotDevice.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:account/provider/orderHistoryProvider.dart';

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
              child:
                  Text('ไม่มีสินค้าในตะกร้า', style: TextStyle(fontSize: 18)),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: provider.cart.length,
                  itemBuilder: (context, index) {
                    IoTDevice item = provider.cart[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                          'ราคา: ฿${item.price.toStringAsFixed(2)} x ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => provider.decreaseQuantity(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => provider.increaseQuantity(item),
                          ),
                        ],
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
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _showPaymentDialog(context, provider),
                      child: const Text('ยืนยันการสั่งซื้อ'),
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
          title: const Text('การชำระเงิน'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('กรุณาชำระเงินโดยสแกน QR Code ด้านล่าง'),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('โอนเงินเข้าบัญชีธนาคาร'),
                  const SizedBox(height: 10),
                  const Text('🏦 ธนาคาร: กรุงเทพ'),
                  const Text('📌 หมายเลขบัญชี: 123-456-7890'),
                  Text(
                      '💰 จำนวนเงิน: ฿${provider.getTotalPrice().toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            Consumer<OrderHistoryProvider>(
              builder: (context, orderProvider, child) {
                return ElevatedButton(
                  onPressed: () {
                    // ลดจำนวนสินค้าตามที่ซื้อ
                    for (var item in provider.cart) {
                      item.quantity -= item.quantity;
                      provider.updateDevice(item);
                    }

                    // บันทึกคำสั่งซื้อ
                    orderProvider.addOrder(provider.cart);
                    provider.checkout();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'ชำระเงินสำเร็จ! รายการถูกบันทึก และจำนวนสินค้าลดลง')),
                    );
                  },
                  child: const Text('ยืนยันการชำระเงิน'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
