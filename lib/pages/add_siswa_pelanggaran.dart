import 'package:flutter/material.dart';
import 'package:siswa_app/pages/display_siswa.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:siswa_app/pages/paired_devices.dart'; // Import the new page
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class AddSiswaPelanggaranPage extends StatefulWidget {
  final int? siswaId;
  final String? nisn;

  AddSiswaPelanggaranPage({this.siswaId, this.nisn})
      : assert(siswaId != null || nisn != null, 'Either siswaId or nisn must be provided.');

  @override
  _AddSiswaPelanggaranPageState createState() => _AddSiswaPelanggaranPageState();
}

class _AddSiswaPelanggaranPageState extends State<AddSiswaPelanggaranPage> {
  final _catatanController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedPelanggaran;
  List<Map<String, dynamic>> _pelanggaranList = [];
  String? siswaNama;
  String? siswaNoOrtu;
  String? siswaNISN;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    fetchPelanggaran();
    fetchSiswaData();
    loadLastSelectedPelanggaran();
  }

  Future<void> fetchPelanggaran() async {
    try {
      final response = await Supabase.instance.client.from('pelanggaran').select();
      setState(() {
        _pelanggaranList = List<Map<String, dynamic>>.from(response as List<dynamic>);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch pelanggaran: $e')),
      );
    }
  }

  Future<void> fetchSiswaData() async {
    try {
      if (widget.siswaId != null) {
        final response = await Supabase.instance.client.from('siswa').select('nama, no_ortu, nisn').eq('id', widget.siswaId as Object).single();
        setState(() {
          siswaNama = response['nama'];
          siswaNoOrtu = response['no_ortu'];
          siswaNISN = response['nisn'];
        });
      } else if (widget.nisn != null) {
        final response = await Supabase.instance.client.from('siswa').select('id, nama, no_ortu, nisn').eq('nisn', widget.nisn as Object).single();
        setState(() {
          siswaNama = response['nama'];
          siswaNoOrtu = response['no_ortu'];
          siswaNISN = response['nisn'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch siswa data: $e')),
      );
    }
  }

  Future<void> addPelanggaran() async {
    if (_formKey.currentState!.validate()) {
      try {
        final siswaId = widget.siswaId ??
            (await Supabase.instance.client.from('siswa').select('id').eq('nisn', widget.nisn as Object).single())['id'];

        await Supabase.instance.client.from('siswa_pelanggaran').insert({
          'siswa_id': siswaId,
          'pelanggaran_id': _selectedPelanggaran,
        });

        saveLastSelectedPelanggaran(_selectedPelanggaran!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pelanggaran added successfully'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 50),
          ),
        );

        await printPelanggaran(siswaNama!, _selectedPelanggaran!);
        Navigator.popAndPushNamed(context, '/to_siswa');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add pelanggaran: $e'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 50),
          ),
        );
      }
    }
  }

  Future<void> printPelanggaran(String namaSiswa, String pelanggaranId) async {
    // Check if the device is connected before attempting to print
    if (await bluetooth.isConnected == true) {
      final pelanggaran = _pelanggaranList.firstWhere((element) => element['id'].toString() == pelanggaranId)['nama'];
      final today = DateTime.now();
      final formattedDate = '${today.day}-${today.month}-${today.year}';
      bluetooth.printCustom("==== Pelanggaran Siswa ====", 0, 0);
      bluetooth.printCustom("Tanggal: $formattedDate", 0, 0);
      bluetooth.printCustom("NISN: $siswaNISN", 0, 0);
      bluetooth.printCustom("Nama: $namaSiswa", 0, 0);
      bluetooth.printCustom("Pelanggaran: $pelanggaran", 0, 0);
      bluetooth.printCustom("Catatan: $_catatanController.text", 0, 0);
      bluetooth.printNewLine();
      bluetooth.paperCut();
    } else {
      // Attempt to reconnect if the device is disconnected
      if (_connectedDevice != null) {
        await bluetooth.connect(_connectedDevice!);
        await printPelanggaran(namaSiswa, pelanggaranId); // Retry printing after reconnecting
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printer is not connected')),
        );
      }
    }
  }

  Future<void> _navigateToPairedDevices() async {
    final BluetoothDevice? selectedDevice = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PairedDevicesPage(),
      ),
    );
    if (selectedDevice != null) {
      setState(() {
        _connectedDevice = selectedDevice;
      });
    }
  }

  Future<void> saveLastSelectedPelanggaran(String pelanggaranId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSelectedPelanggaran', pelanggaranId);
  }

  Future<void> loadLastSelectedPelanggaran() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPelanggaran = prefs.getString('lastSelectedPelanggaran');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Pelanggaran'),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: _navigateToPairedDevices,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.nisn != null) Text('NISN: ${widget.nisn}'),
              if (siswaNama != null) Text('Nama: $siswaNama'),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedPelanggaran,
                items: _pelanggaranList.map((pelanggaran) {
                  return DropdownMenuItem<String>(
                    value: pelanggaran['id'].toString(),
                    child: Text(pelanggaran['nama']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPelanggaran = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pelanggaran',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a pelanggaran';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _catatanController,
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(onPressed: addPelanggaran, child: Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
}
