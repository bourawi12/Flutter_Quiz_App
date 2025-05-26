import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //get auth service
  final authService = AuthService();

  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void signUp() async{
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // check that passwords match
    if(password != confirmPassword){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("passwords don't match ")));
      return;
    }

    // attempt sign up ..
    try {
  await authService.signUpWithEmailPassword(email, password);
  //pop register page
      Navigator.pop(context);
    }catch(e){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign up"),
      ),
        body: ListView(
          children: [
            TextField(
              controller : _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller : _passwordController,
              decoration: const InputDecoration(labelText: "password"),
              obscureText: true,
            ),
            TextField(
              controller : _confirmPasswordController,
              decoration: const InputDecoration(labelText: "confirm password"),
              obscureText: true,
            ),
            ElevatedButton(onPressed: signUp, child: const Text("Sign up")),
            const SizedBox(height: 12),


          ],
        )
    );
  }
}
