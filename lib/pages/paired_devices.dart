import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PairedDevicesPage extends StatefulWidget {
  @override
  _PairedDevicesPageState createState() => _PairedDevicesPageState();
}

class _PairedDevicesPageState extends State<PairedDevicesPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _getPairedDevices();
  }

  Future<void> _getPairedDevices() async {
    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get paired devices: $e')),
      );
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;
    
    setState(() {
      _isConnecting = true;
    });

    try {
      bool isConnected = await bluetooth.isConnected == true;
      if (isConnected) {
        await bluetooth.disconnect();
      }
      
      await bluetooth.connect(device);
      Navigator.pop(context, device); // Return the selected device to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to device: $e')),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paired Devices'),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_devices[index].name ?? 'Unknown device'),
            subtitle: Text(_devices[index].address ?? 'No address'),
            onTap: () => _connectToDevice(_devices[index]),
          );
        },
      ),
    );
  }
}
