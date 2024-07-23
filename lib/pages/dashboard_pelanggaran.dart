import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siswa_app/chart/info_card.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabaseClient = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getTopPelanggaran() async {
    try {
      final response = await supabaseClient.rpc('top_pelanggaran');
      return List<Map<String, dynamic>>.from(response as List<dynamic>);
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTopSiswa() async {
    try {
      final response = await supabaseClient.rpc('top_siswa');
      return List<Map<String, dynamic>>.from(response as List<dynamic>);
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Data Pelanggaran Siswa'),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Row(
                      children: [
                        Text(
                          'Top Pelanggaran',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: getTopPelanggaran(),
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
                      final topPelanggaran = snapshot.data!;
                      return Container(
                        height: 150, // Set a height for the horizontal scroll view
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: topPelanggaran.map((pelanggaran) {
                              return Container(
                                width: 220, // Adjust width as needed
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                  child: infocard(
                                    title: pelanggaran['nama'],
                                    value: pelanggaran['jumlah'].toString(),
                                  ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      'Top Siswa dengan Poin Pelanggaran Terbanyak',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: getTopSiswa(),
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
                      final topSiswa = snapshot.data!;
                      return Container(
                        height: 150, // Set a height for the horizontal scroll view
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: topSiswa.map((siswa) {
                              return Container(
                                width: 200, // Adjust width as needed
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                child: Expanded(
                                  child: infocard(
                                    title: siswa['nama'],
                                    value: siswa['total_poin'].toString(),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
