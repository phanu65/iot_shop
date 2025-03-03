import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:account/provider/orderHistoryProvider.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ประวัติคำสั่งซื้อ', style: GoogleFonts.prompt()),
      ),
      body: Consumer<OrderHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.orders.isEmpty) {
            return Center(
              child: Text('ยังไม่มีคำสั่งซื้อ', style: GoogleFonts.prompt(fontSize: 18)),
            );
          }
          return ListView.builder(
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ExpansionTile(
                  title: Text('คำสั่งซื้อ: ${order.orderId}', style: GoogleFonts.prompt(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'วันที่: ${DateFormat('dd/MM/yyyy HH:mm').format(order.date)}\nยอดรวม: ฿${order.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.prompt(),
                  ),
                  children: order.items.map((item) {
                    return ListTile(
                      title: Text(item.name, style: GoogleFonts.prompt()),
                      subtitle: Text('จำนวน: ${item.quantity} | ราคา: ฿${item.price.toStringAsFixed(2)}',
                          style: GoogleFonts.prompt()),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}