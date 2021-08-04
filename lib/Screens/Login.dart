import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:whatsup/Models/Person.dart';
import 'package:whatsup/Services/Auth.dart';
import 'package:whatsup/Services/Firebase.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Color _color1 = Color(0xFF07ac12);
  Color _color2 = Color(0xFF515151);
  Color _color3 = Color(0xff777777);
  // ignore: unused_field
  Color _color4 = Color(0xFFaaaaaa);
  String number, verify, smsCode;
  dynamic phone;
  bool codeSent = false;
  final formKey = new GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  bool _buttonDisabled = true;
  TextEditingController textEditingController = TextEditingController();
  bool loading = false;

  // ignore: close_sinks
  StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  String currentText = "";
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
    return Scaffold(
        backgroundColor: Colors.white,
        body: loading == true
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(30, 120, 30, 30),
                  children: <Widget>[
                    Center(
                        child: Icon(Icons.phone_android,
                            color: _color1, size: 50)),
                    SizedBox(height: 20),
                    Center(
                        child: Text(
                      !codeSent
                          ? 'etpn'.tr
                          : "etvc".tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _color2),
                    )),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Text(
                        !codeSent
                            ? 'wtw'.tr
                            : 'tvch'.tr + '$number',
                        style: TextStyle(fontSize: 13, color: _color3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    !codeSent
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: controller,
                              validator: (value) {
                                if (value.isEmpty)
                                  return "Can't be empty";
                                else if (!value.contains('+'))
                                  return "Enter an valid email";
                                else
                                  return null;
                              },
                              onChanged: (value) {
                                if (value.length < 6) {
                                  _buttonDisabled = true;
                                } else {
                                  _buttonDisabled = false;
                                  setState(() {
                                    number = value;
                                  });
                                }
                              },
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: _color1,
                                ),
                                hintText: "etpn".tr,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 10.0),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10),
                            child: PinCodeTextField(
                              appContext: context,
                              pastedTextStyle: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                              length: 6,
                              obscureText: false,
                              animationType: AnimationType.fade,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.underline,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeFillColor: hasError
                                    ? Colors.blue.shade100
                                    : Colors.white,
                              ),
                              backgroundColor: Colors.white,
                              cursorColor: Colors.black,
                              animationDuration: Duration(milliseconds: 300),
                              enableActiveFill: false,
                              errorAnimationController: errorController,
                              controller: textEditingController,
                              keyboardType: TextInputType.number,
                              boxShadows: [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  color: Colors.white,
                                  blurRadius: 10,
                                )
                              ],
                              onCompleted: (v) {},
                              onTap: () {},
                              onChanged: (value) {
                                setState(() {
                                  smsCode = value;
                                });
                              },
                              beforeTextPaste: (text) {
                                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                return true;
                              },
                            )),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      child: SizedBox(
                          width: double.maxFinite,
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            splashColor:
                                _buttonDisabled ? Colors.transparent : _color1,
                            highlightColor:
                                _buttonDisabled ? Colors.transparent : _color1,
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(3.0),
                            ),
                            onPressed: () {
                              if (codeSent) {
                                register();
                              } else {
                                verifyPhone(number);
                              }
                            },
                            padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                            color: _buttonDisabled ? Colors.grey[300] : _color1,
                            child: Text(
                              'Verify',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _buttonDisabled
                                      ? Colors.grey[600]
                                      : Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
                  ],
                ),
              ));
  }

  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult, number);
    };

    final PhoneVerificationFailed verificationfailed = (var authException) {
      Get.snackbar("Time", "Exception error");
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verify = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verify = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 10),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  void register() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      setState(() {
        loading = true;
      });

      try {
        Person a = await AuthService().signInWithOTP(smsCode, verify, number);
       Person result = await Firebase().getUser(a.id);
        if (result.username != null) {
          print("");
        } else {
          Firebase().kullaniciOlustur(
              id: a.id,
              phone: number,
              photo:
                  "https://mymodernmet.com/wp/wp-content/uploads/2019/07/will-burrard-lucas-beetlecam-23-1024x683.jpg",
              username: "New User",
              about: "...");
        }
      } catch (error) {
        setState(() {
          loading = false;
        });
        Get.snackbar("Error", error.toString());
      }
    }
  }
}
