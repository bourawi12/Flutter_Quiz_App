import 'package:flutter/material.dart';
import 'package:quiz/auth/auth_service.dart';
import 'package:quiz/pages/register_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //get auth service
  final authService = AuthService();

  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //login button pressed
  void login() async{
    //prepare data
    final email = _emailController.text;
    final password = _passwordController.text;

    // attempt login ..
    try{
      await authService.signInWithEmailPassword(email, password);
    }catch(e){
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error : $e")));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
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
          ElevatedButton(onPressed: login, child: const Text("Login")),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder : (context)=> const RegisterPage(),
            )),
            child : Center(child: Text("Don t have an account ? Sign Up")),
          )

        ],
      )
    );
  }
}
