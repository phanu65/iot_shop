import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:account/model/iotDevice.dart';
import 'package:account/provider/iotDeviceProvider.dart';

class EditIoTDeviceScreen extends StatefulWidget {
  final IoTDevice device;
  
  const EditIoTDeviceScreen({super.key, required this.device});

  @override
  State<EditIoTDeviceScreen> createState() => _EditIoTDeviceScreenState();
}

class _EditIoTDeviceScreenState extends State<EditIoTDeviceScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  String? selectedCategory;
  String? selectedImage;

  final Map<String, String> categoryImages = {
    "Sensor": "assets/images/sensor.png",
    "Microcontroller": "assets/images/microcontroller.png",
    "Module": "assets/images/module.png",
    "Accessory": "assets/images/accessory.png",
  };

  @override
  void initState() {
    super.initState();
    nameController.text = widget.device.name;
    priceController.text = widget.device.price.toString();
    quantityController.text = widget.device.quantity.toString();
    selectedCategory = widget.device.category;
    selectedImage = widget.device.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('แก้ไขข้อมูลอุปกรณ์ IoT', style: GoogleFonts.prompt()),
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
                  ? Text("ยังไม่ได้เลือกรูปภาพ", style: GoogleFonts.prompt())
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    var provider = Provider.of<IoTDeviceProvider>(context, listen: false);
                    
                    IoTDevice updatedDevice = IoTDevice(
                      keyID: widget.device.keyID,
                      name: nameController.text,
                      price: double.parse(priceController.text),
                      quantity: int.parse(quantityController.text),
                      category: selectedCategory,
                      imagePath: selectedImage,
                      date: widget.device.date,
                    );

                    provider.updateDevice(updatedDevice);
                    Navigator.pop(context);
                  }
                },
                child: Text('บันทึกการแก้ไข', style: GoogleFonts.prompt()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}