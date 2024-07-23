import 'package:flutter/material.dart';
import 'package:siswa_app/pages/add_pelanggaran.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JenisPelanggaranPage extends StatefulWidget {
  @override
  _JenisPelanggaranPageState createState() => _JenisPelanggaranPageState();
}

class _JenisPelanggaranPageState extends State<JenisPelanggaranPage> {
  final supabaseClient = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchJenisPelanggaran() async {
  try {
    final response = await supabaseClient.from('pelanggaran').select('id, nama, poin');
    return List<Map<String, dynamic>>.from(response as List<dynamic>);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch data: $e')),
    );
    return [];
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jenis Pelanggaran'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => addPelanggaran(),));
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchJenisPelanggaran(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }
          final jenisPelanggaran = snapshot.data!;
          return ListView.builder(
            itemCount: jenisPelanggaran.length,
            itemBuilder: (context, index) {
              final pelanggaran = jenisPelanggaran[index];
              return ListTile(
                title: Text(pelanggaran['nama']),
                trailing: Text('Poin: ${pelanggaran['poin']}'.toString(), style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                // onTap: () {
                //   // Handle tap if necessary
                // },
              );
            },
          );
        },
      ),
    );
  }
}
