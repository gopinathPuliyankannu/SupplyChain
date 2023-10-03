import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner/src/qrScannerList.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
// import 'dart:html' as html;
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner>
    with SingleTickerProviderStateMixin {
  late final qrlist supplyChain;
  Barcode? result;
  QRViewController? controller;
  bool scanning = true;
  bool isFlashOn = false;
  bool showCamera = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // static const white = 0xFFFFFFFF);
  // static const double dimension_10 = 10.0;
  // static const double dimension_30 = 30.0;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkStatus();
  }


  bool isQueryParamPresent(String paramName, String url) {
    // Parse the URL
    Uri uri = Uri.parse(url);

    // Check if the query parameter exists
    return uri.queryParameters.containsKey(paramName);
  }

  void checkStatus()async{
    print(kIsWeb);
    if (kIsWeb) {
      final initialLink = await getInitialLink();
      print(initialLink);
      // Your app is running in a web browser.
      String url = initialLink.toString();
      String paramNameToCheck = 'param';

      bool isPresent = isQueryParamPresent(paramNameToCheck, url);
      if (isPresent) {
        Route route = MaterialPageRoute(builder: (context) => qrlist(url: url));
        Navigator.pushReplacement(context, route);
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => qrlist(url: url)));
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      print('result $result');
      setState(() {
        result = scanData;
        showCamera = !showCamera;
      });
      bool _validURL = Uri.parse(result!.code.toString()).isAbsolute;
      if (_validURL) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => qrlist(url: result!.code)));
      } else {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('QR Error'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Please scan the valid QR'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("string $result");
    return Scaffold(
      body: Stack(
        children: <Widget>[
          (showCamera)
              ? Center(
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(bottom: 100.0),
                  child: Center(
                      child: Text(
                    'Tap the Scan button to read the QR',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ))),
          !showCamera
              ? Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.lightBlue),
                    ),
                    onPressed: () {
                      setState(() {
                        showCamera = !showCamera;
                      });

                    },
                    child: Text('QR Scanner'),
                  ),
                )
              : Text(""),
          showCamera
              ? Align(
                  alignment: Alignment.topRight,
                  child: new IconButton(
                      icon: Icon(Icons.cancel,
                          color: Colors.lightBlue, size: 40.0),
                      onPressed: () {
                        setState(() {
                          showCamera = !showCamera;
                        });
                      }),
                )
              : Text('')
        ],
      ),
    );
  }
}
