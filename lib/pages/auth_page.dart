import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:siswa_app/pages/dashboard_siswa.dart';

final supabase = Supabase.instance.client;

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Duration get loginTime => const Duration(seconds: 1);

  Future<String?> _authUser(LoginData data, BuildContext context) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: data.name,
        password: data.password,
      );

      if (response.user != null) {
        // Registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User login successfully'),
            duration: Duration(seconds: 2),
            
          ),
        );
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(),
        ));
        // Optionally navigate to another screen or show a success message
      } else if (response != null) {
        // Handle registration error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: $response'),
            duration: Duration(seconds: 2),
          ),
        );
        // Optionally show an error message to the user
      }
    } catch (error) {
      // Handle other exceptions that might occur during signup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during login: $error'),
          duration: Duration(seconds: 2),
        ),
      );
      // Optionally show a generic error message to the user
    }
  }

  Future<String?> _signupUser(SignupData data, BuildContext context) async {
    try {
      final response = await supabase.auth.signUp(
        email: data.name!,
        password: data.password!,
      );

      if (response.user != null) {
        // Registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User registered successfully'),
            duration: Duration(seconds: 2),
            
          ),
        );
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
        // Optionally navigate to another screen or show a success message
      } else if (response != null) {
        // Handle registration error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: $response'),
            duration: Duration(seconds: 2),
          ),
        );
        // Optionally show an error message to the user
      }
    } catch (error) {
      // Handle other exceptions that might occur during signup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during registration: $error'),
          duration: Duration(seconds: 2),
        ),
      );
      // Optionally show a generic error message to the user
    }
    return null;
  }

  Future<String?> _recoverPassword(String name) async {
    try {
      final response = await supabase.auth.resetPasswordForEmail(name);

      // Password recovery request sent successfully
      return 'Password recovery email sent';
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      //title: 'PUNISH',
      logo: const AssetImage('images/logoapk-hori-white.png'),
      onLogin: (data) => _authUser(data, context),
      onSignup: (data) => _signupUser(data, context),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      },
      onRecoverPassword: _recoverPassword,
      theme: LoginTheme(
        primaryColor: Colors.red,
        textFieldStyle: const TextStyle(color: Colors.white),
        titleStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
