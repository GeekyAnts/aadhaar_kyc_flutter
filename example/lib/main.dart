import 'package:aadhaar_kyc_flutter/aadhaar_kyc_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Adhaar Kyc Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 44, 77),
        title: const Text('Aadhaar Kyc'),
        centerTitle: false,
      ),
      body: const AadhaarKyc(
        apiKey:
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY2MzU2Njg4OCwianRpIjoiYTZjZTNjYzEtYzY1NS00MjUxLWI5OGUtMjk3ODY5ZDcxYzA2IiwidHlwZSI6ImFjY2VzcyIsImlkZW50aXR5IjoiZGV2LmdlZWt5YW50c0BzdXJlcGFzcy5pbyIsIm5iZiI6MTY2MzU2Njg4OCwiZXhwIjoxNjY0NDMwODg4LCJ1c2VyX2NsYWltcyI6eyJzY29wZXMiOlsid2FsbGV0Il19fQ.X8DK6lEAW2Ijn8i0xSrwf-fRtYKVFnFxiWB8SAncrnI',
      ),
    );
  }
}
