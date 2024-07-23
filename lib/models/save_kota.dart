import 'package:siswa_app/models/kota_model.dart';
import 'package:flutter/material.dart';

class saveKota extends ChangeNotifier{

  List<KotaModel> _list=[
    KotaModel(nama: 'malang'),
    KotaModel(nama: 'jakarta'),
    KotaModel(nama: 'bogor'),
    KotaModel(nama: 'ponorogo'),
    KotaModel(nama: 'pacet'),
    KotaModel(nama: 'batu'),
    KotaModel(nama: 'blitar'),
    KotaModel(nama: 'hongkong')
  ];

  List<KotaModel> get list => _list;
  
  void addKota(KotaModel kota){
    list.add(kota);
    notifyListeners();
  }

  void removeKota(KotaModel kota){
    list.remove(kota);
    notifyListeners();
  }

  void updateKota(KotaModel oldKota, KotaModel newKota) {
    final index = _list.indexOf(oldKota);
      if (index != -1) {
      _list[index] = newKota;
    notifyListeners();
  }
  }

}
