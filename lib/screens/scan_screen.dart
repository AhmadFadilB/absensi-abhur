import 'dart:developer';
import 'dart:io';

import 'package:absensi/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key, required this.sesi}) : super(key: key);
  final int sesi;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final qrKey = GlobalKey(debugLabel: "QR");
  final textEditingController = TextEditingController();
  bool scanningMode = false;
  QRViewController? qrViewController;
  Barcode? barcode;
  bool loading = false;

  late AnimationController lottieController;

  @override
  void initState() {
    super.initState();

    lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
        lottieController.reset();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    lottieController.dispose();
    qrViewController?.dispose();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrViewController!.pauseCamera();
    } else if (Platform.isIOS) {
      qrViewController!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: Alignment.bottomCenter, children: [
        _buildQrView(context),
        Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: (() => Navigator.of(context).pop()),
            child: const Text("Back"),
          ),
        )
      ]),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
        borderWidth: 10,
        borderLength: 20,
        borderRadius: 10,
        borderColor: Colors.white,
      ),
    );
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      qrViewController = controller;
    });

    qrViewController!.resumeCamera();
    controller.scannedDataStream.listen((barcode) async {
      setState(() => this.barcode = barcode);

      if (barcode.code != null) {
        await postData(barcode.code!);
      }
    });
  }

  Future<void> postData(String name) async {
    if (loading) return;

    setState(() => loading = true);
    qrViewController!.pauseCamera();
    log(name);

    /// post logic

    try {
      final res = await Repository.postUser(name, widget.sesi);
      // log(res.body);
      // log(res.statusCode.toString());

      if (res.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Nama: $name, Sesi: ${widget.sesi}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey.withOpacity(0.8),
            textColor: Colors.white,
            fontSize: 20.0);
        await showSuccessDialog();
      } else {
        Fluttertoast.showToast(
            msg: res.body,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red.withOpacity(0.8),
            textColor: Colors.white,
            fontSize: 20.0);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red.withOpacity(0.8),
          textColor: Colors.white,
          fontSize: 20.0);
    }

    Future.delayed(const Duration(milliseconds: 100));
    qrViewController!.resumeCamera();
    setState(() {
      loading = false;
    });
  }

  Future<void> showSuccessDialog() => showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x00ffffff),
      builder: ((context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Lottie.asset("assets/success.json",
              repeat: false, controller: lottieController, onLoaded: (p0) {
            lottieController.duration = p0.duration;
            lottieController.forward();
          }),
        );
      }));
}
