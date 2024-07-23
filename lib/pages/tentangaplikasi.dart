import 'package:flutter/material.dart';

class tentang extends StatelessWidget {
  const tentang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tentang Aplikasi'),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('images/logotelkom.png', width: 150,),
            SizedBox(height: 15,),
            Text('Versi 1'),
            SizedBox(height: 15,),
            Text('SMK Telkom malang'),
            SizedBox(height: 20,),
            Text('SISWA-KU adalah aplikasi yang berisikan data-data dari siwa-siswi SMK Telkom Malang', textAlign: TextAlign.center,),
            
          ],
        ),
      ),
    );
  }
}