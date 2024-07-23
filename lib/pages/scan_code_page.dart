import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siswa_app/pages/add_siswa_pelanggaran.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.red[900],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "/generate");
            },
            icon: const Icon(
              Icons.qr_code,
            ),
          ),
        ],
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: true,
        ),
        onDetect: (capture) async {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          for (final barcode in barcodes) {
            print('Barcode found! ${barcode.rawValue}');
            String? nisn = barcode.rawValue;
            if (nisn != null) {
              try{
                // Check if NISN exists in the database
              final response = await Supabase.instance.client
                  .from('siswa')
                  .select('id')
                  .eq('nisn', nisn)
                  .single();

              if (response != null) {
                int siswaId = response['id'];
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSiswaPelanggaranPage(siswaId: siswaId, nisn: nisn),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('error while fetching data')),
                );
              }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('error: $error')),
                );
              }
            }
          }
          // if (image != null) {
          //   showDialog(
          //     context: context,
          //     builder: (context) {
          //       return AlertDialog(
          //         title: Text(
          //           barcodes.first.rawValue ?? "",
          //         ),
          //         content: Image(
          //           image: MemoryImage(image),
          //         ),
          //       );
          //     },
          //   );
          // }
        },
      ),
    );
  }
}
