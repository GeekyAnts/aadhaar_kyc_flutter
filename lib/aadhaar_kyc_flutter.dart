// library adhaar_kyc_flutter;
import 'dart:convert';
import 'dart:io' as io;
import 'package:aadhaar_kyc_flutter/models/aadhaar_data.dart';
import 'package:aadhaar_kyc_flutter/utils/strings.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:aadhaar_kyc_flutter/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';

/// Aadhaar KYC
class AadhaarKyc extends StatefulWidget {
  final double? containerWidth;
  final double? containerHeight;
  final EdgeInsets? containerPadding;
  final Color? containerBackground;
  final EdgeInsets? textFormFieldPadding;
  final String? aadhaarNumberHintText;
  final Color? otpTextFieldColor;
  final String? apiKey;

  const AadhaarKyc(
      {super.key,
      this.containerHeight,
      this.containerWidth,
      this.containerPadding,
      this.containerBackground,
      this.textFormFieldPadding,
      this.aadhaarNumberHintText,
      this.otpTextFieldColor,
      this.apiKey});
  @override
  State<AadhaarKyc> createState() => _AadhaarKycState();
}

class _AadhaarKycState extends State<AadhaarKyc> {
  bool scanning = false;
  String indvidualAadhaarNumber = '';
  io.File? aadhaarFront;
  final TextEditingController _aadhaarNumberController =
      TextEditingController();
  String passAadhaarNumber = '';
  bool showOtpField = false;
  String clientID = '';
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
        width: widget.containerWidth ?? SizeConfig().screenWidth,
        height: widget.containerHeight ?? SizeConfig().screenHeight,
        color: widget.containerBackground ?? Colors.white,
        child: Padding(
          padding: widget.textFormFieldPadding ??
              EdgeInsets.symmetric(
                  horizontal: 20.0.toWidth, vertical: 25.0.toHeight),
          child: Form(
              child: Column(
            children: [
              FocusScope(
                node: FocusScopeNode(),
                child: TextFormField(
                  controller: _aadhaarNumberController,
                  decoration: InputDecoration(
                    suffixIcon: scanning
                        ? (_aadhaarNumberController.text ==
                                TextStrings().aadhaarNumberNotFound)
                            ? IconButton(
                                onPressed: getAadhaarFront,
                                icon: const Icon(
                                  Icons.upload,
                                  color: Colors.green,
                                ),
                              )
                            : IconButton(
                                onPressed: () {
                                  sendOtp(_aadhaarNumberController.text);
                                },
                                icon: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.green,
                                ),
                              )
                        : IconButton(
                            onPressed: getAadhaarFront,
                            icon: const Icon(Icons.upload)),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.0.toWidth, vertical: 20.0.toHeight),
                    hintText: widget.aadhaarNumberHintText ??
                        TextStrings().aadhaarNumber,
                  ),
                ),
              ),
              SizedBox(
                height: 50.toHeight,
              ),
              showOtpField
                  ? PinCodeTextField(
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          inactiveColor:
                              widget.otpTextFieldColor ?? Colors.blue,
                          activeColor: Colors.green),
                      appContext: context,
                      length: 6,
                      onChanged: (String value) {},
                      onCompleted: (value) {
                        validateOtp(
                            _aadhaarNumberController.text, int.parse(value));
                      },
                    )
                  : const SizedBox()
            ],
          )),
        ));
  }

  Future getAadhaarFront() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    aadhaarFront = io.File(pickedFile!.path);
    String extractAadhaarNumber =
        await FlutterTesseractOcr.extractText(pickedFile.path);
    String removeMultine = extractAadhaarNumber.replaceAll("\n", ' ');
    String indvidualAadhaarNumber =
        RegExp(r'\d{4}\s\d{4}\s\d{4}').stringMatch(removeMultine).toString();
    setState(() {
      indvidualAadhaarNumber == TextStrings().valueNull
          ? _aadhaarNumberController.text = TextStrings().aadhaarNumberNotFound
          : _aadhaarNumberController.text = RegExp(r'\d{4}\s\d{4}\s\d{4}')
              .stringMatch(removeMultine)
              .toString();
      passAadhaarNumber = indvidualAadhaarNumber.replaceAll(RegExp(r"\s+"), "");
      scanning = true;
    });
  }

  Future<dynamic> sendOtp(String aadhaarNumber) async {
    showOtpField = true;
    var url = 'https://sandbox.aadhaarkyc.io/api/v1/aadhaar-v2/generate-otp';
    final http.Response response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Bearer ${widget.apiKey}"
        },
        body: jsonEncode({'id_number': aadhaarNumber}));
    if (response.statusCode == 200) {
      var dataCard = Aadhaardata.fromJson(json.decode(response.body)["data"]);
      clientID = dataCard.clientId!;
      return Aadhaardata.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to CREATE event: ${response.body}');
    }
  }

  Future<dynamic> validateOtp(String aadhaarNumber, int otp) async {
    var url = 'https://sandbox.aadhaarkyc.io/api/v1/aadhaar-v2/submit-otp';
    final http.Response response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Bearer ${widget.apiKey}"
        },
        body: jsonEncode({'client_id': aadhaarNumber, 'otp': otp}));
    if (response.statusCode == 200) {
      showDialog(
          barrierColor: Colors.white.withOpacity(0),
          context: context,
          builder: (context) {
            return AlertDialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 100.toHeight,
                    color: Colors.green,
                  ),
                  SizedBox(
                    height: 40.toHeight,
                  ),
                  Text(
                    'Aadhaar Validated',
                    style: TextStyle(fontSize: 40.toFont),
                  )
                ],
              ),
            );
          });
    } else {
      showInformation(
          message: 'Incorrect OTP',
          messageIcon: Icons.cancel_rounded,
          iconColor: Colors.red,
          showButton: true);
    }
  }

  showInformation(
      {String? message,
      Color? iconColor,
      IconData? messageIcon,
      bool showButton = false,
      String? buttonText}) {
    showDialog(
        barrierColor: Colors.white.withOpacity(0),
        context: context,
        builder: (context) {
          return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            actions: [
              showButton
                  ? InkWell(
                      onTap: () {
                        sendOtp(_aadhaarNumberController.text);
                      },
                      child: Text(
                        buttonText ?? 'Resend Otp',
                        style: TextStyle(fontSize: 20.toFont),
                      ),
                    )
                  : const SizedBox()
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  messageIcon!,
                  size: 100.toHeight,
                  color: iconColor ?? Colors.green,
                ),
                SizedBox(
                  height: 40.toHeight,
                ),
                Text(
                  message!,
                  style: TextStyle(fontSize: 40.toFont),
                )
              ],
            ),
          );
        });
  }
}
