import 'package:flutter/material.dart';
import 'package:siswa_app/pages/add_siswa.dart';
import 'package:siswa_app/pages/auth_page.dart';
import 'package:siswa_app/pages/dashboard_siswa.dart';
import 'package:siswa_app/pages/display_kota.dart';
import 'package:siswa_app/pages/display_siswa.dart';
import 'package:siswa_app/pages/auth_page.dart';

class splash_page extends StatefulWidget {
  const splash_page({super.key});

  @override
  State<splash_page> createState() => _splash_pageState();
}


class _splash_pageState extends State<splash_page> {

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.white,
      child: Center(
        child: Image.asset('images/logotelkom.png', width: 150,),
      ),

    );
  }
}