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
  final TextEditingController descriptionController = TextEditingController();
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
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('เพิ่มอุปกรณ์ IoT', style: GoogleFonts.prompt()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'ชื่ออุปกรณ์ IoT', labelStyle: GoogleFonts.prompt()),
                autofocus: true,
                controller: nameController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนชื่ออุปกรณ์";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'ประเภทอุปกรณ์', labelStyle: GoogleFonts.prompt()),
                value: selectedCategory,
                items: categoryImages.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: GoogleFonts.prompt()),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedCategory = value;
                    selectedImage = categoryImages[value];
                  });
                },
              ),
              const SizedBox(height: 16),
              selectedImage == null
                  ? Text("กรุณาเลือกประเภทอุปกรณ์เพื่อแสดงรูปภาพ", style: GoogleFonts.prompt())
                  : Image.asset(selectedImage!, height: 150),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'ราคา', labelStyle: GoogleFonts.prompt()),
                keyboardType: TextInputType.number,
                controller: priceController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนราคา";
                  }
                  try {
                    double price = double.parse(value);
                    if (price <= 0) {
                      return "กรุณาป้อนราคาที่มากกว่า 0";
                    }
                  } catch (e) {
                    return "กรุณาป้อนเป็นตัวเลขเท่านั้น";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'จำนวน', labelStyle: GoogleFonts.prompt()),
                keyboardType: TextInputType.number,
                controller: quantityController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนจำนวน";
                  }
                  try {
                    int quantity = int.parse(value);
                    if (quantity <= 0) {
                      return "กรุณาป้อนจำนวนที่มากกว่า 0";
                    }
                  } catch (e) {
                    return "กรุณาป้อนเป็นตัวเลขเท่านั้น";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'รายละเอียดสินค้า', labelStyle: GoogleFonts.prompt()),
                maxLines: 3,
                controller: descriptionController,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate() && selectedCategory != null) {
                    final provider = Provider.of<IoTDeviceProvider>(context, listen: false);
                    IoTDevice device = IoTDevice(
                      name: nameController.text,
                      price: double.parse(priceController.text),
                      date: DateTime.now(),
                      quantity: int.parse(quantityController.text),
                      category: selectedCategory!,
                      imagePath: selectedImage!,
                    );
                    provider.addDevice(device);
                    Navigator.pop(context);
                  }
                },
                child: Text('เพิ่มอุปกรณ์', style: GoogleFonts.prompt()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}