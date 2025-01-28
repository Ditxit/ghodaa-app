import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      await Permission.camera.request();
      status = await Permission.camera.status;
    }

    if (status.isGranted) {
      setState(() {
        hasPermission = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera permission is required to scan QR codes.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR'),
      ),
      body: hasPermission
          ? MobileScanner(
              controller: cameraController,
              onDetect: (BarcodeCapture barcode) {
                if (barcode.raw != null) {
                  Navigator.of(context).pop(barcode.raw);
                }
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
