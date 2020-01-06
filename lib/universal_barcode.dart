library universal_barcode;

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UniversalBarcode extends StatefulWidget {
  final Function(String code) didCatchCode;
  UniversalBarcode(this.didCatchCode);

  @override
  State<StatefulWidget> createState() => _UniversalBarcodeState();
}

class _UniversalBarcodeState extends State<UniversalBarcode> {
  bool keyboardMode = false;
  TextEditingController _textEditingController = TextEditingController();
  String error;
  String barcode;
  @override
  void initState() {
    super.initState();
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
          !keyboardMode ? buildKeyboardButton() : buildTextfield(),
          FractionallySizedBox(
            widthFactor: 0.7,
            child: RaisedButton.icon(
                onPressed: openCameraScanner,
                icon: Icon(Icons.camera_rear),
                label: Text("Camera")),
          )
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
    try {
      String _barcode = await BarcodeScanner.scan();
      didScan(_barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.error = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.error = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.error =
      'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.error = 'Unknown error: $e');
    }
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

  buildTextfield() {
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
}