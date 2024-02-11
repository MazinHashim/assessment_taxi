import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_app_assessment/views/map_trip_page.dart';
import 'package:taxi_app_assessment/views/login_page.dart';

void main() async {
  await dotenv.load(fileName: ".env"); //path to your .env file
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final futurelocalStorage = SharedPreferences.getInstance();
  late SharedPreferences? pref;
  late String? currentUser;
  @override
  void initState() {
    currentUser = null;
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    pref = await futurelocalStorage;
    setState(() {
      currentUser = pref?.getString("user");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: currentUser == null ? const Login() : const MapTripPage(),
    );
  }
}
