import 'package:flutter_config/flutter_config.dart';
import 'package:get/state_manager.dart';
import 'package:taxi_app_assessment/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  String? userId = FlutterConfig.get('USER_ID');
  String? email = FlutterConfig.get('USER_EMAIL');
  String? name = FlutterConfig.get('USER_NAME');
  String? password = FlutterConfig.get('USER_PASSWORD');

  Rx<User> user = User().obs;
  Future<SharedPreferences>? futurelocalStorage;

  @override
  void onInit() {
    user.value.userId = userId;
    user.value.email = email;
    user.value.name = name;
    user.value.password = password;
    futurelocalStorage = SharedPreferences.getInstance();
    super.onInit();
  }

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == user.value.email && password == user.value.password) {
      SharedPreferences pref = await futurelocalStorage!;
      pref.setString("user", user.value.email!);
      return user.value;
    }
    return null;
  }
}
