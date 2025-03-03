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
        backgroundColor: Colors.white,
        title: Text(
          'ประวัติคำสั่งซื้อ',
          style: GoogleFonts.prompt(color: Color(0xFF211C84), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF211C84)),
      ),
      body: Consumer<OrderHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.orders.isEmpty) {
            return Center(
              child: Text(
                'ยังไม่มีคำสั่งซื้อ',
                style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7A73D1)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                color: Colors.white,
                child: ExpansionTile(
                  title: Text(
                    'คำสั่งซื้อ: ${order.orderId}',
                    style: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: Color(0xFF211C84)),
                  ),
                  subtitle: Text(
                    'วันที่: ${DateFormat('dd/MM/yyyy HH:mm').format(order.date)}\nยอดรวม: ฿${order.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.prompt(color: Color(0xFF4D55CC)),
                  ),
                  children: order.items.map((item) {
                    return ListTile(
                      title: Text(
                        item.name,
                        style: GoogleFonts.prompt(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF211C84)),
                      ),
                      subtitle: Text(
                        'จำนวน: ${item.quantity} | ราคา: ฿${item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.prompt(color: Color(0xFF4D55CC)),
                      ),
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
