import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account/provider/iotDeviceProvider.dart';
import 'package:account/model/iotDevice.dart';

class AddIoTDeviceScreen extends StatefulWidget {
  const AddIoTDeviceScreen({super.key});

  @override
  State<AddIoTDeviceScreen> createState() => _AddIoTDeviceScreenState();
}

class _AddIoTDeviceScreenState extends State<AddIoTDeviceScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('เพิ่มอุปกรณ์ IoT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ชื่ออุปกรณ์ IoT'),
                autofocus: true,
                controller: nameController,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return "กรุณาป้อนชื่ออุปกรณ์";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ราคา'),
                keyboardType: TextInputType.number,
                controller: priceController,
                validator: (String? value) {
                  try {
                    double price = double.parse(value!);
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
                decoration: const InputDecoration(labelText: 'จำนวน'),
                keyboardType: TextInputType.number,
                controller: quantityController,
                validator: (String? value) {
                  try {
                    int quantity = int.parse(value!);
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
                    // ใช้ context.read<IoTDeviceProvider>() ใน BuildContext ที่ถูกต้อ
                    final provider =
                        Provider.of<IoTDeviceProvider>(context, listen: false);
                    IoTDevice device = IoTDevice(
                      name: nameController.text,
                      price: double.parse(priceController.text),
                      date: DateTime.now(),
                      quantity: int.parse(quantityController.text),
                    );
                    provider.addDevice(device);
                    Navigator.pop(context);
                  }
                },
                child: const Text('เพิ่มอุปกรณ์'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
