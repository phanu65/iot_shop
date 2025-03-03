import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:account/provider/iotDeviceProvider.dart';
import 'package:account/model/iotDevice.dart';

class EditIoTDeviceScreen extends StatefulWidget {
  final IoTDevice device;

  const EditIoTDeviceScreen({super.key, required this.device});

  @override
  State<EditIoTDeviceScreen> createState() => _EditIoTDeviceScreenState();
}

class _EditIoTDeviceScreenState extends State<EditIoTDeviceScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.device.name;
    priceController.text = widget.device.price.toString();
    quantityController.text = widget.device.quantity.toString();
    selectedCategory = widget.device.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'แก้ไขอุปกรณ์ IoT',
          style: GoogleFonts.prompt(color: Color(0xFF211C84), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF211C84)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _buildInputField(nameController, 'ชื่ออุปกรณ์ IoT', Icons.devices),
              const SizedBox(height: 16),
              _buildInputField(priceController, 'ราคา', Icons.attach_money, isNumber: true),
              const SizedBox(height: 16),
              _buildInputField(quantityController, 'จำนวน', Icons.numbers, isNumber: true),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('ยืนยันการแก้ไข', style: GoogleFonts.prompt(fontWeight: FontWeight.bold)),
                          content: Text('คุณแน่ใจหรือไม่ว่าต้องการบันทึกการแก้ไขนี้?', style: GoogleFonts.prompt()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('ยกเลิก', style: GoogleFonts.prompt(color: Colors.red)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                var provider = Provider.of<IoTDeviceProvider>(context, listen: false);
                                IoTDevice updatedDevice = IoTDevice(
                                  keyID: widget.device.keyID,
                                  name: nameController.text,
                                  price: double.parse(priceController.text),
                                  quantity: int.parse(quantityController.text),
                                  category: selectedCategory,
                                  imagePath: widget.device.imagePath,
                                );
                                provider.updateDevice(updatedDevice);
                                Navigator.of(context).pop(); // ปิด dialog
                                Navigator.of(context).pop(); // กลับหน้าก่อนหน้า
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: Text('ยืนยัน', style: GoogleFonts.prompt(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF211C84),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('บันทึกการแก้ไข', style: GoogleFonts.prompt(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.prompt(color: Color(0xFF211C84)),
        prefixIcon: Icon(icon, color: Color(0xFF4D55CC)),
        filled: true,
        fillColor: Color(0xFFB5A8D5).withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => value == null || value.isEmpty ? "กรุณาป้อน${label}" : null,
    );
  }
}