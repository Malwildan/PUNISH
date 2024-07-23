import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siswa_app/pages/add_siswa.dart';
import 'package:siswa_app/pages/edit_siswa.dart';
import 'package:siswa_app/pages/add_siswa_pelanggaran.dart';
import 'package:siswa_app/pages/scan_code_page.dart';
import 'package:siswa_app/pages/siswa_pelanggaran.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisplaySiswa extends StatefulWidget {
  const DisplaySiswa({super.key});

  @override
  State<DisplaySiswa> createState() => _DisplaySiswaState();
}

class _DisplaySiswaState extends State<DisplaySiswa> {
  List<dynamic> siswaList = [];
  List<dynamic> filteredList = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSiswaData();
  }

  Future<void> fetchSiswaData() async {
    try {
      final response = await Supabase.instance.client
          .from('siswa')
          .select('id, nama, birth, nisn, kota(id,nama_kota), gender');

      if (response == null) {
        throw response;
      }

      setState(() {
        siswaList = response;
        filteredList = siswaList;
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

  Future<void> deleteSiswa(int id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this siswa?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed Cancel
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed Delete
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      try {
        final response = await Supabase.instance.client
            .from('siswa')
            .delete()
            .eq('id', id); // Ensure execute() is called to actually perform the deletion

        if (response.error != null) {
          throw response.error!;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Siswa deleted successfully!')),
        );

        fetchSiswaData(); // Reload data after deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete data: $e')),
        );
      }
    }
  }

  void filterSearchResults(String query) {
    List<dynamic> tempList = [];
    if (query.isNotEmpty) {
      tempList = siswaList.where((siswa) {
        return siswa['nama'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      tempList = siswaList;
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
        title: Text('Daftar Siswa', style: TextStyle(fontWeight: FontWeight.w500),),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanCodePage(),
            ),
          );
        },
        child: FloatingActionButton(
          shape: CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddSiswa(),
              ),
            );
          },
          child: const Icon(Icons.add_box, color: Colors.white,),
          backgroundColor: Colors.red[900],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.red[900],
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: SizedBox(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
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
                          final siswa = filteredList[index];
                          return ListTile(
                            title: Text(siswa['nama']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TTL: ${formatDate(siswa['birth'])}'),
                                Text('NISN: ${siswa['nisn']}'),
                                Text('Asal: ${siswa['kota']['nama_kota']}'),
                                Text('Gender: ${siswa['gender']}'),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SiswaPelanggaranPage(
                                    siswaId: siswa['id'],
                                    siswaNama: siswa['nama'],
                                    siswaNISN: siswa['nisn'],
                                  ),
                                ),
                              );
                            },
                            trailing: Wrap(
                              spacing: 12, // space between two icons
                              children: <Widget>[
                                IconButton(
                                  onPressed: () async {
                                    await deleteSiswa(siswa['id']);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => EditSiswa(
                                          id: siswa['id'],
                                        ),
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
