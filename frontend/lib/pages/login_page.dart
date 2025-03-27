import 'package:book_swap/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add this import
import 'dart:convert'; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool changeButton = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(); // Add controller for email
  final passwordController =
      TextEditingController(); // Add controller for password

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> moveToHome(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => changeButton = true);

      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/token/'),
          body: jsonEncode({
            'username':
                emailController.text, // Or 'email' if using email-based auth
            'password': passwordController.text,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        print('Response status: ${response.statusCode}'); // Debug log
        print('Response body: ${response.body}'); // Debug log

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access', jsonDecode(response.body)['access']);
          await prefs.setString(
              'refresh', jsonDecode(response.body)['refresh']);

          // Ensure navigation happens after token save
          if (mounted) {
            Navigator.pushReplacementNamed(context, MyRoutes.homeRoute);
          }
        } else {
          throw Exception('Login failed: ${response.body}');
        }
      } catch (e) {
        print('Login error: $e'); // Detailed error logging
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => changeButton = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Image.asset(
                "assets/images/login_image.png",
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("Enter your credentials to login"),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 32.0,
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController, // Bind controller
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: "Enter Email",
                        labelText: "Username/Email",
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Email can't be empty";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: passwordController, // Bind controller
                      obscureText: true,
                      decoration: const InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Icon(Icons.lock),
                          )),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Password can't be empty";
                        }

                        // if (value!.length < 8) {
                        //   return "Password length must be eight or more";
                        // }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Material(
                      color: Colors.deepPurple,
                      borderRadius:
                          BorderRadius.circular(changeButton ? 50 : 8),
                      child: InkWell(
                        onTap: () => moveToHome(context),
                        child: AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          width: changeButton ? 50 : 150,
                          height: 50,
                          alignment: Alignment.center,
                          child: changeButton
                              ? const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 45,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, MyRoutes.signupRoute);
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ", // Normal text
                          style: TextStyle(
                            color: Colors
                                .black, // Default color for the rest of the text
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign Up", // Styled "Sign Up" part
                              style: TextStyle(
                                color: Colors.deepPurple, // Color for "Sign Up"
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration
                                    .underline, // Underline "Sign Up"
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
