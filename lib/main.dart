import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siswa_app/models/save_kota.dart';
import 'package:siswa_app/models/save_siswa.dart';
import 'package:siswa_app/pages/add_siswa.dart';
import 'package:siswa_app/pages/dashboard_siswa.dart';
import 'package:siswa_app/pages/display_kota.dart';
import 'package:siswa_app/pages/display_siswa.dart';
import 'package:siswa_app/pages/auth_page.dart';
import 'package:siswa_app/pages/generate_qr.dart';
import 'package:siswa_app/pages/scan_code_page.dart';
import 'package:siswa_app/pages/add_kota.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jrcnaunpmoknbwwmlwrz.supabase.co',
    anonKey: 
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpyY25hdW5wbW9rbmJ3d21sd3J6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEwMzk4NzMsImV4cCI6MjAzNjYxNTg3M30.ripFUeAUC_R8A70WBosGuyRVGL7dmuyBBFEcjvS6x5g',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => saveSiswa()),
        ChangeNotifierProvider(create: (_) => saveKota())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
        initialRoute: '/',
        routes: {
          '/add_page': (_) => AddSiswa(),
          '/add_kota': (_) => addKota(),
          '/to_siswa': (_) => DisplaySiswa(),
          '/to_kota':(_) => DisplayKota(),
          '/scan': (_) => ScanCodePage(),
          '/generate':(_) => GenerateCodePage()
  }),
      
    );
  }
}