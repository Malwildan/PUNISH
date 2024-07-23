import 'package:siswa_app/models/siswa_model.dart';
import 'package:flutter/material.dart';

class saveSiswa extends ChangeNotifier{

  List<SiswaModel> _list=[
    SiswaModel(nama: 'akmal', year: '2006', kota: 'malang', gender: true),
    SiswaModel(nama: 'kumalala', year: '2006', kota: 'bogor', gender: false),
    SiswaModel(nama: 'hdmi', year: '2004', kota: 'jakarta', gender: true),
    SiswaModel(nama: 'ryzen', year: '2007', kota: 'india', gender: true),
    SiswaModel(nama: 'dadar jagung', year: '2004', kota: 'singapore', gender: false),
    SiswaModel(nama: 'trenggiling', year: '2004', kota: 'india', gender: false)
  ];

  List<SiswaModel> get list => _list;
  
  void addSiswa(SiswaModel siswa){
    list.add(siswa);
    notifyListeners();
  }

  void removeSiswa(SiswaModel siswa){
    list.remove(siswa);
    notifyListeners();
  }
  
  void updateSiswa(SiswaModel oldSiswa, SiswaModel newSiswa) {
    final index = _list.indexOf(oldSiswa);
      if (index != -1) {
      _list[index] = newSiswa;
    notifyListeners();
  }
  }

  List<String> getYears(){
    return _list.map((siswa) => siswa.year).toSet().toList();
  }

}