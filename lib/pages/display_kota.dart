import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siswa_app/main.dart';
import 'package:siswa_app/pages/dashboard_siswa.dart';
import 'package:siswa_app/pages/edit_kota.dart';
import 'package:siswa_app/pages/edit_siswa.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisplayKota extends StatefulWidget {
  const DisplayKota({super.key});

  @override
  State<DisplayKota> createState() => _DisplayKotaState();
}

class _DisplayKotaState extends State<DisplayKota> {
  List<dynamic> kotaList = [];
  List<dynamic> filteredList = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchKotaData();
  }

  Future<void> fetchKotaData() async {
    try {
      final response = await Supabase.instance.client
          .from('kota')
          .select('id, nama_kota');

      if (response == null) {
        throw response;
      }

      setState(() {
        kotaList = response;
        filteredList = kotaList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  Future<void> deleteKota(int id) async {
    try {
      final response = await Supabase.instance.client
          .from('kota')
          .delete()
          .eq('id', id);
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kota deleted successfully!')),
        );

      fetchKotaData();// Reload data after deletion
    } catch (e)  {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete data: $e')),
      );
      fetchKotaData();
    }
  }

  void filterSearchResults(String query) {
    List<dynamic> tempList = [];
    if (query.isNotEmpty) {
      tempList = kotaList.where((kota) {
        return kota['nama_kota'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      tempList = kotaList;
    }

    setState(() {
      filteredList = tempList;
      searchQuery = query;
    });
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kota List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_page');
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                filterSearchResults(value);
              },
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search by Nama",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(child: Text('No Data'))
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final kota = filteredList[index];
                          return ListTile(
                            title: Text(kota['nama_kota']),
                            // subtitle: Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Text('TTL: ${formatDate(siswa['birth'])}'),
                            //     Text('NISN: ${siswa['nisn']}'),
                            //     Text('Asal: ${siswa['kota']['nama_kota']}'),
                            //     Text('Gender: ${siswa['gender']}'),
                            //   ],
                            // ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await deleteKota(kota['id']);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => EditKota(id:(kota['id']),),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
