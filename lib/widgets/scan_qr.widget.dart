import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: QRScannerWidget(),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  @override
  _QRScannerWidgetState createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: GlobalKey(debugLabel: 'QR'),
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 200,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      Navigator.of(context).pop(scanData.code); // Return scanned code
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
