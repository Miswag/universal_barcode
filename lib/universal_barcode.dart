library universal_barcode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:last_qr_scanner/barcode_types.dart';
export 'package:last_qr_scanner/barcode_types.dart';
import 'package:last_qr_scanner/last_qr_scanner.dart';

import 'dart:async';

import 'package:universal_barcode/utils/debouncer.dart';

class UniversalBarcode extends StatefulWidget {
  final Function(String code) didCatchCode;
  final List<BarcodeFormat> lookupFormats;
  UniversalBarcode(this.didCatchCode, this.lookupFormats);

  @override
  State<StatefulWidget> createState() => _UniversalBarcodeState();

  static Future<void> show(BuildContext context, Function(String) callback, List<BarcodeFormat> lookupFormats) async {

    AlertDialog dialog = AlertDialog(
      title: Text("Select A Method.."),
      content:Container(
        height: 340,
        child: UniversalBarcode(callback, lookupFormats),
      ),
      contentPadding: EdgeInsets.all(0),
      actions: <Widget>[
        FlatButton(
          child: Text('Done'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }
}

class _UniversalBarcodeState extends State<UniversalBarcode> {
  bool keyboardMode = false;
  bool cameraMode = false;
  TextEditingController _textEditingController = TextEditingController();
  String error;
  String barcode;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var controller;

  final _debouncer = Debouncer(milliseconds: 80);

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    final channel = controller.channel;
    controller.init(qrKey);
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onRecognizeQR":
          _debouncer.run(() {
            dynamic arguments = call.arguments;
            widget.didCatchCode(arguments.toString());
          });
      }
    });
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          this.error != null
              ? Center(
            child: Text(
              this.error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          )
              : Container(),
          this.barcode != null
              ? Center(
            child: Text(
              this.barcode,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green),
            ),
          )
              : Container(),
          !keyboardMode ? buildKeyboardButton() : buildTextField(),
          !cameraMode ? FractionallySizedBox(
            widthFactor: 0.7,
            child: RaisedButton.icon(
                onPressed: openCameraScanner,
                icon: Icon(Icons.camera_rear),
                label: Text("Camera")),
          ) : buildCameraFeed()
        ],
      ),
    );
  }

  didScan(String _barcode){
    setState(() {
      this.error = null;
      this.barcode = _barcode;
    });
    widget.didCatchCode(_barcode);
  }

  void openCameraScanner() async {
    setState(() {
      this.cameraMode = !cameraMode;
    });
  }

  FractionallySizedBox buildKeyboardButton() {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: RaisedButton.icon(
          onPressed: toggleKeyboard,
          icon: Icon(Icons.keyboard),
          label: Text("Barcode Scanner")),
    );
  }

  void toggleKeyboard() {
    setState(() {
      this.keyboardMode = !this.keyboardMode;
//      if (keyboardMode) _textFieldFocus.requestFocus();
    });
  }

  buildTextField() {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 200,
                child: TextField(
                  controller: _textEditingController,
                  onSubmitted: (code) {
                    didScan(code);
                    _textEditingController.clear();
                  },
                  autofocus: true,
                )),
            FlatButton(
              onPressed: toggleKeyboard,
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
              color: Colors.red,
            )
          ],
        ),
      ),
    );
  }


  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }



  Widget buildCameraFeed(){
    return Container(
      height: 210,
      child: LastQrScannerPreview(
        key: qrKey,
        lookupFormats: widget.lookupFormats,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }
}

