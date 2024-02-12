import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi_app_assessment/controllers/user_controller.dart';
import 'package:taxi_app_assessment/models/user.dart';
import 'package:taxi_app_assessment/views/map_trip_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final userController = Get.put(UserController());
  late NavigatorState _navigatorState;
  late ScaffoldMessengerState _messenger;

  @override
  void didChangeDependencies() {
    _navigatorState = Navigator.of(context);
    _messenger = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  late String? email = "";
  late String? password = "";

  void _userLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      User? user = await userController.login(email!, password!);
      if (user != null) {
        _navigatorState.push(
          MaterialPageRoute(
            builder: (_) => const MapTripPage(),
          ),
        );
      } else {
        _messenger.showSnackBar(const SnackBar(
          content: Text("Worng Email or Password"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
          left: 13.0,
          right: 13.0,
          bottom: 13.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 35),
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value,
                validator: (email) {
                  if (email!.isEmpty) return "Email is required";
                  if (!email.contains("@")) {
                    return "Invalid email format";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Email"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                obscureText: true,
                onSaved: (value) => password = value,
                validator: (password) {
                  if (password!.isEmpty) return "Password is required";
                  if (password.contains(" ")) {
                    return "Password must not contain spaces";
                  }
                  if (password.length > 20 || password.length < 4) {
                    return "Please enter password LTN 21 and GTN than 3";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Password"),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _userLogin,
                  icon: const Icon(
                    Icons.login,
                  ),
                  label: const Text("Login"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
