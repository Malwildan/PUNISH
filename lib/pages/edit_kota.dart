import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siswa_app/pages/dashboard_siswa.dart';
import 'package:siswa_app/pages/display_kota.dart';
import 'package:siswa_app/pages/display_siswa.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class EditKota extends StatefulWidget {
  final int id; // Add id as a parameter to pass to EditSiswa

  const EditKota({super.key, required this.id});

  @override
  State<EditKota> createState() => _EditKotaState();
}

class _EditKotaState extends State<EditKota> {
  final _namaController = TextEditingController();
  final _birthController = TextEditingController();
  final _nisnController = TextEditingController();
  final _ortuController = TextEditingController();
  bool _isMale = true; // true = male

  DateTime? _selectedDate;
  String? _selectedCity;
  List<Map<String, dynamic>> _cities = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _fetchKotaData();
  }

  void _fetchCities() async {
    final response = await supabase.from('kota').select();
    if (response != null) {
      setState(() {
        _cities = List<Map<String, dynamic>>.from(response);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cities: ${response}')),
      );
    }
  }

  void _fetchKotaData() async {
    final response = await supabase.from('kota').select().eq('id', widget.id).single();
    if (response != null) {
      final data = response;
      setState(() {
        _namaController.text = data['nama_kota'];
        // _birthController.text = data['birth'];
        // _nisnController.text = data['nisn'];
        // _ortuController.text = data['no_ortu'];
        // _isMale = data['gender'] == 'male';
        // _selectedDate = DateTime.parse(data['birth']);
        // _selectedCity = _cities.firstWhere((city) => city['id'] == data['kota_id'])['nama_kota'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load kota data: ${response}')),
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _birthController.dispose();
    _nisnController.dispose();
    _ortuController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    try {
      final response = await supabase.from('kota').update({
        'nama': _namaController.text,
        // 'birth': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        // 'nisn': _nisnController.text,
        // 'kota_id': _cities.firstWhere((city) => city['nama_kota'] == _selectedCity)['id'],
        // 'gender': _isMale ? 'male' : 'female',
        // 'no_ortu': _ortuController.text,
      }).eq('id', widget.id);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $response')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kota updated successfully!')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DisplayKota()));
        //Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $error')),
      );
    }
  }

  void _presentDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _birthController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Format the date as needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Kota'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Kota'),
              ),
              // SizedBox(height: 20),
              // TextField(
              //   controller: _birthController,
              //   decoration: InputDecoration(labelText: 'Tanggal Lahir'),
              //   readOnly: true,
              //   onTap: _presentDatePicker,
              // ),
              // SizedBox(height: 20),
              // TextField(
              //   controller: _nisnController,
              //   decoration: InputDecoration(labelText: 'NISN'),
              // ),
              // SizedBox(height: 20),
              // TextField(
              //   controller: _ortuController,
              //   decoration: InputDecoration(labelText: 'No. HP Orangtua'),
              // ),
              // SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Text('Gender'),
              //     SizedBox(width: 10),
              //     Radio(
              //       value: true,
              //       groupValue: _isMale,
              //       onChanged: (bool? value) {
              //         setState(() {
              //           _isMale = value!;
              //         });
              //       },
              //     ),
              //     Text('male'),
              //     Radio(
              //       value: false,
              //       groupValue: _isMale,
              //       onChanged: (bool? value) {
              //         setState(() {
              //           _isMale = value!;
              //         });
              //       },
              //     ),
              //     Text('female')
              //   ],
              // ),
              // SizedBox(height: 20),
              // DropdownButtonFormField<String>(
              //   items: _cities.map((city) {
              //     return DropdownMenuItem<String>(
              //       value: city['nama_kota'],
              //       child: Text(city['nama_kota']),
              //     );
              //   }).toList(),
              //   onChanged: (String? value) {
              //     setState(() {
              //       _selectedCity = value;
              //     });
              //   },
              //   decoration: InputDecoration(labelText: 'Kota'),
              //   value: _selectedCity,
              // ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
