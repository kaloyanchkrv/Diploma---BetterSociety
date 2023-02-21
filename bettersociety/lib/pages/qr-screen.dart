import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    this.controller?.scannedDataStream.take(1).listen(
      (scanData) {
        if (scanData.code != null) {
          result = scanData.code!;
          this.controller?.pauseCamera();
          Navigator.pop(context, result);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 70,
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.clear,
            size: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Scan QR Code",
          style: textTheme.headlineLarge,
        ),
      ),
      body: Stack(
        children: [
          QRView(
            overlay: QrScannerOverlayShape(
                cutOutBottomOffset: 10,
                overlayColor: const Color(0x00333435).withOpacity(0.75),
                borderColor: Colors.white,
                borderRadius: 26,
                borderLength: 45,
                borderWidth: 7,
                cutOutSize: MediaQuery.of(context).size.width * 0.75),
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ],
      ),
    );
  }
}

class _FlashIconButton extends StatelessWidget {
  const _FlashIconButton(
      {Key? key, required this.onPressed, required this.isFlashOn})
      : super(key: key);

  final VoidCallback onPressed;
  final bool isFlashOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          isFlashOn ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }
}
