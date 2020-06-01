import 'package:flutter/material.dart';
import 'package:universal_barcode/universal_barcode.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Universal Barcode';
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            UniversalBarcode(
                (code){}, [BarcodeFormat.QR_CODE]
            ),
            OutlineButton.icon(
                onPressed: () => UniversalBarcode.show(
                    context, (_) => print(_), [BarcodeFormat.EAN_13]),
                icon: Icon(Icons.extension),
                label: Text("Only EAN-13")),
            OutlineButton.icon(
                onPressed: () => UniversalBarcode.show(
                    context, (_) => print(_), [BarcodeFormat.QR_CODE]),
                icon: Icon(Icons.local_bar),
                label: Text("Only QRCode")),
            OutlineButton.icon(
                onPressed: () => UniversalBarcode.show(
                    context, (_) => print(_), BarcodeFormat.values),
                icon: Icon(Icons.all_inclusive),
                label: Text("Exhaustive All"))
          ],
        ),
      ),
    );
  }
}
