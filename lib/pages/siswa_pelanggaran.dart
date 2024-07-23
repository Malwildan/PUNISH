import 'package:flutter/material.dart';
import 'package:siswa_app/pages/add_siswa_pelanggaran.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SiswaPelanggaranPage extends StatefulWidget {
  final int siswaId;
  final String siswaNama;
  final String siswaNISN;

  SiswaPelanggaranPage({required this.siswaId, required this.siswaNama, required this.siswaNISN});

  @override
  _SiswaPelanggaranPageState createState() => _SiswaPelanggaranPageState();
}

class _SiswaPelanggaranPageState extends State<SiswaPelanggaranPage> {
  final supabaseClient = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPelanggaranSiswa(int siswaId) async {
    try {
      final response = await supabaseClient
          .from('siswa_pelanggaran')
          .select('pelanggaran(nama, poin)')
          .eq('siswa_id', siswaId);
      return List<Map<String, dynamic>>.from(response as List<dynamic>);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
      return [];
    }
  }

  int calculateTotalPoints(List<Map<String, dynamic>> pelanggaranList) {
    return pelanggaranList.fold<int>(
        0, (total, pelanggaran) => total + (pelanggaran['pelanggaran']['poin'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pelanggaran ${widget.siswaNama}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPelanggaranSiswa(widget.siswaId),
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
          final pelanggaranList = snapshot.data!;
          final totalPoints = calculateTotalPoints(pelanggaranList);

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total Poin: $totalPoints',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: pelanggaranList.length,
                  itemBuilder: (context, index) {
                    final pelanggaran = pelanggaranList[index]['pelanggaran'];
                    return ListTile(
                      title: Text(pelanggaran['nama']),
                      trailing: Text(
                        pelanggaran['poin'].toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSiswaPelanggaranPage(siswaId: widget.siswaId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
      ),
    );
  }
}
