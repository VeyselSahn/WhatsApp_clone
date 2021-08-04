import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whatsup/Services/Auth.dart';
import 'package:whatsup/Services/trans.dart';

void main() async{
  WidgetsFlutterBinding();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WhatsUp',
      translations: Messages(), // your translations
      locale: Get.deviceLocale, // translations will be displayed in that locale
      fallbackLocale: Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: AuthService().handleAuth(),
    );
  }
}

