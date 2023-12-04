import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/widgets/dropdown_field.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../controllers/login_controller.dart';
import '../../di/service_locator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum InputType { userId, userName }

class _LoginScreenState extends State<LoginScreen> {
  final List<String> ids = [
    '101',
    '102',
    '103',
    '104'
  ];

  final List<String> userNames = ['John', 'Steve', 'Smith', 'Head', 'Glenn'];

  var selectedId = "";
  var selectedUserName = "";

  final controller = getIt<LoginController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            const SizedBox(
              width: 80,
              height: 80,
              child: Image(
                image: AssetImage('assets/logoSendbird.png'),
                fit: BoxFit.scaleDown,
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            _buildDropdown("Select User Id", ids, InputType.userId),
            const SizedBox(
              height: 16,
            ),
            _buildDropdown("Select User Name", userNames, InputType.userName),
            const Spacer(),
            _signInButton(context),
            const SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }

  _buildDropdown(String title, List<String> items, InputType type) {
    return DropDownField(title, items, (value) {
      if (type == InputType.userId) {
        selectedId = value.toString();
      } else if (type == InputType.userName) {
        selectedUserName = value.toString();
      }
    });
  }

  _signInButton(BuildContext context) {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  try {
                    await controller.login(selectedId, selectedUserName);
                    if (mounted) Navigator.pushNamed(context, '/channel_list');
                  } catch (e) {
                    if (kDebugMode) {
                      print('login_view.dart: _signInButton: ERROR: $e');
                    }
                    if (mounted) controller.showLoginFailAlert(context);
                  }
                },
          child: !controller.isLoading.value
              ? Text(
                  "Sign In",
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : const SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
        ));


  }

}
