import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:account/provider/iotDeviceProvider.dart';
import 'package:account/model/iotDevice.dart';

class AddIoTDeviceScreen extends StatefulWidget {
  const AddIoTDeviceScreen({super.key});

  @override
  State<AddIoTDeviceScreen> createState() => _AddIoTDeviceScreenState();
}

class _AddIoTDeviceScreenState extends State<AddIoTDeviceScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  String? selectedCategory;
  String? selectedImage;

  final Map<String, String> categoryImages = {
    "Sensor": "assets/images/sensor.png",
    "Microcontroller": "assets/images/microcontroller.png",
    "Module": "assets/images/module.png",
    "Accessory": "assets/images/accessory.png",
  };

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณากรอก$label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D55CC),
        title: Text('เพิ่มอุปกรณ์ IoT', style: GoogleFonts.prompt(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _buildInputField(nameController, 'ชื่ออุปกรณ์ IoT', Icons.devices),
              const SizedBox(height: 16),
              _buildDropdownField(),
              if (selectedCategory == null) ...[
                const SizedBox(height: 8),
                // Text('กรุณาเลือกประเภทอุปกรณ์', style: GoogleFonts.prompt(color: Colors.red, fontSize: 14)),
              ],
              const SizedBox(height: 16),
              _buildInputField(priceController, 'ราคา', Icons.attach_money, isNumber: true),
              const SizedBox(height: 16),
              _buildInputField(quantityController, 'จำนวน', Icons.numbers, isNumber: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate() && selectedCategory != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('ยืนยันการเพิ่มอุปกรณ์', style: GoogleFonts.prompt(fontWeight: FontWeight.bold)),
                          content: Text('คุณต้องการเพิ่มอุปกรณ์นี้ใช่หรือไม่?', style: GoogleFonts.prompt()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('ยกเลิก', style: GoogleFonts.prompt(color: Colors.red)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final provider = Provider.of<IoTDeviceProvider>(context, listen: false);
                                IoTDevice device = IoTDevice(
                                  name: nameController.text,
                                  price: double.parse(priceController.text),
                                  quantity: int.parse(quantityController.text),
                                  category: selectedCategory!,
                                  imagePath: selectedImage ?? '',
                                );
                                provider.addDevice(device);
                                Navigator.of(context).pop();
                                Navigator.pop(context);
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
                child: Text('เพิ่มอุปกรณ์', style: GoogleFonts.prompt(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'ประเภทอุปกรณ์',
        labelStyle: GoogleFonts.prompt(color: Color(0xFF211C84)),
        prefixIcon: Icon(Icons.category, color: Color(0xFF4D55CC)),
        filled: true,
        fillColor: Color(0xFFB5A8D5).withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      value: selectedCategory,
      items: categoryImages.keys.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category, style: GoogleFonts.prompt(color: Color(0xFF4D55CC))),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
          selectedImage = categoryImages[value] ?? '';
        });
      },
    );
  }
}