import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class addKota extends StatefulWidget {
  const addKota({super.key});

  @override
  State<addKota> createState() => _addKotaState();
}

class _addKotaState extends State<addKota> {
  final _namaController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
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
      final existingDataResponse = await supabase
          .from('kota')
          .select()
          .eq('nama_kota', _namaController.text);

      if (existingDataResponse != null && existingDataResponse.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data already exists for Kota: ${_namaController.text}')),
        );
        return;
      }

      final response = await supabase.from('kota').insert({
        'nama_kota': _namaController.text,
      });

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kota added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ADD KOTA'),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: _submitData, child: Text('Submit'))
          ],
        ),
      ),
    );
  }
}
