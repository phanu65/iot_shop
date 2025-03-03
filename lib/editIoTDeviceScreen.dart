import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account/model/iotDevice.dart';
import 'package:account/provider/iotDeviceProvider.dart';

class EditIoTDeviceScreen extends StatefulWidget {
  IoTDevice device;
  
  EditIoTDeviceScreen({super.key, required this.device});

  @override
  State<EditIoTDeviceScreen> createState() => _EditIoTDeviceScreenState();
}

class _EditIoTDeviceScreenState extends State<EditIoTDeviceScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = widget.device.name;
    priceController.text = widget.device.price.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit IoT Device'),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'ชื่ออุปกรณ์ IoT'),
              autofocus: true,
              controller: nameController,
              validator: (String? value) {
                if(value!.isEmpty){
                  return "กรุณาป้อนชื่ออุปกรณ์";
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'ราคา'),
              keyboardType: TextInputType.number,
              controller: priceController,
              validator: (String? value) {
                try{
                  double price = double.parse(value!);
                  if(price <= 0){
                    return "กรุณาป้อนราคาที่มากกว่า 0";
                  }
                } catch(e){
                  return "กรุณาป้อนเป็นตัวเลขเท่านั้น";
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if(formKey.currentState!.validate()){
                  var provider = Provider.of<IoTDeviceProvider>(context, listen: false);
                  
                  IoTDevice device = IoTDevice(
                    keyID: widget.device.keyID,
                    name: nameController.text,
                    price: double.parse(priceController.text),
                    date: widget.device.date
                  );

                  provider.updateDevice(device);

                  Navigator.pop(context);
                }
              },
              child: const Text('แก้ไขข้อมูล'),
            ),
        ],),
      ),
    );
  }
}
