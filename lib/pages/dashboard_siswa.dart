import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:siswa_app/chart/bar_card.dart';
import 'package:siswa_app/chart/pie_card.dart';
import 'package:siswa_app/pages/auth_page.dart';
import 'package:siswa_app/pages/dashboard_pelanggaran.dart';
import 'package:siswa_app/pages/display_kota.dart';
import 'package:siswa_app/pages/display_pelanggaran.dart';
import 'package:siswa_app/pages/display_siswa.dart';
import 'package:siswa_app/chart/info_card.dart';
import 'package:siswa_app/pages/paired_devices.dart';
import 'package:siswa_app/pages/scan_code_page.dart';
import 'package:siswa_app/pages/tentangaplikasi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  List<Widget> _pages = [
    DashboardContent(),
    DashboardPage(),
    DisplaySiswa(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(height: 60,),
            Image.asset('images/logoapk-hori.png'),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text('Daftar Siswa'),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplaySiswa(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text('Daftar Kota'),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DisplayKota(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 14
                      ),
                      child: Text('Daftar Pelanggaran'),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JenisPelanggaranPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.bluetooth),
              title: Text('Paired Device'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PairedDevicesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout_outlined),
              title: Text('Sign Out'),
              onTap: () => _signOut(context),
              iconColor: Colors.red,
              textColor: Colors.red,
              selectedTileColor: Colors.grey[400],
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScanCodePage(),));
        },
        child: const Icon(Icons.qr_code, color: Colors.white,),
        backgroundColor: Colors.red[900],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Stat Siswa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Top Pelanggaran',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.red[900],
          onTap: _onItemTapped,
        ),
      );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  Future<List<SiswaModel>> _fetchSiswaData(BuildContext context) async {
    try {
      final response = await Supabase.instance.client
          .from('siswa')
          .select('id, nama, birth, nisn, kota(id,nama_kota), gender');

      return (response as List)
          .map((data) => SiswaModel.fromJson(data))
          .toList();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $error')),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SiswaModel>>(
      future: _fetchSiswaData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final siswaList = snapshot.data!;
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    infocard(
                      title: 'Total Siswa',
                      value: siswaList.length.toString(),
                    ),
                    infocard(
                      title: 'Laki-Laki',
                      value: siswaList
                          .where((siswa) => siswa.gender == 'male')
                          .length
                          .toString(),
                    ),
                    infocard(
                      title: 'Perempuan',
                      value: siswaList
                          .where((siswa) => siswa.gender == 'female')
                          .length
                          .toString(),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: piecard(
                        title: 'Jenis Kelamin',
                        data: _createGenderData(siswaList),
                      ),
                    ),
                    Expanded(
                      child: piecard(
                        title: 'Kota Siswa',
                        data: _createCityData(siswaList),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(8),
                child: barcard(
                  title: 'Tahun Kelahiran',
                  data: _createYearData(siswaList),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to create gender data for the pie chart
  List<PieChartSectionData> _createGenderData(List<SiswaModel> siswaList) {
    int maleCount = siswaList.where((siswa) => siswa.gender == 'male').length;
    int femaleCount = siswaList.where((siswa) => siswa.gender == 'female').length;
    return [
      PieChartSectionData(
        value: maleCount.toDouble(),
        title: 'Laki-Laki',
        color: Colors.blue,
      ),
      PieChartSectionData(
        value: femaleCount.toDouble(),
        title: 'Perempuan',
        color: Colors.pink,
      ),
    ];
  }

  // Function to create city data for the pie chart
  List<PieChartSectionData> _createCityData(List<SiswaModel> siswaList) {
    Map<String, int> cityCounts = {};
    for (var siswa in siswaList) {
      String cityName = siswa.kota['nama_kota'];
      cityCounts[cityName] = (cityCounts[cityName] ?? 0) + 1;
    }

    return cityCounts.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: entry.key,
        color: Colors.primaries[
            cityCounts.keys.toList().indexOf(entry.key) % Colors.primaries.length],
      );
    }).toList();
  }

  // Function to create year data for the bar chart
  List<BarChartGroupData> _createYearData(List<SiswaModel> siswaList) {
    Map<String, int> yearCounts = {};
    for (var siswa in siswaList) {
      String birthYear = siswa.birth.split('-')[0];
      yearCounts[birthYear] = (yearCounts[birthYear] ?? 0) + 1;
    }
    var sortedYears = yearCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedYears.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: int.parse(entry.value.key),
        barRods: [
          BarChartRodData(
            toY: entry.value.value.toDouble(),
            color: Colors.red[900],
          )
        ],
      );
    }).toList();
  }
}

class SiswaModel {
  final int id;
  final String nama;
  final String birth;
  final String nisn;
  final Map<String, dynamic> kota;
  final String gender;

  SiswaModel({
    required this.id,
    required this.nama,
    required this.birth,
    required this.nisn,
    required this.kota,
    required this.gender,
  });

  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    return SiswaModel(
      id: json['id'],
      nama: json['nama'],
      birth: json['birth'],
      nisn: json['nisn'],
      kota: json['kota'],
      gender: json['gender'],
    );
  }
}
