import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class addPelanggaran extends StatefulWidget {
  const addPelanggaran({super.key});

  @override
  State<addPelanggaran> createState() => _addKotaState();
}

class _addKotaState extends State<addPelanggaran> {
  final _namaController = TextEditingController();
  final _poinController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _poinController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (_namaController.text.isEmpty || _poinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    try {
      final existingDataResponse = await supabase
          .from('pelanggaran')
          .select()
          .eq('nama', _namaController.text);

      if (existingDataResponse != null && existingDataResponse.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data already exists for Pelanggaran: ${_namaController.text}')),
        );
        return;
      }

      final response = await supabase.from('pelanggaran').insert({
        'nama': _namaController.text,
        'poin': _poinController.text,
      });

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pelanggaran added successfully!')),
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
      appBar: AppBar(title: Text('Add Pelanggaran'),
      foregroundColor: Colors.white,
      backgroundColor: Colors.red[900],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 10,),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _poinController,
              decoration: InputDecoration(labelText: 'Poin', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: _submitData, child: Text('Submit'))
          ],
        ),
      ),
    );
  }
}
