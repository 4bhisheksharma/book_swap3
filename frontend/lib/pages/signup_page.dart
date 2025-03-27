import 'package:book_swap/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String name = "";
  bool changeButton = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        changeButton = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/register/'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'username': usernameController.text.trim(),
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(),
          }),
        );

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 201) {
          _showSuccess(context);
          Navigator.pushReplacementNamed(context, MyRoutes.loginRoute);
        } else {
          final errorMessage = responseBody['errors'] ??
              responseBody['detail'] ??
              'Registration failed';
          _showError(context, errorMessage);
        }
      } on http.ClientException catch (e) {
        _showError(context, 'Network error: ${e.message}');
      } catch (e) {
        _showError(context, 'An unexpected error occurred');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            changeButton = false;
          });
        }
      }
    }
  }

  void _handleError(http.Response response) {
    final responseBody = jsonDecode(response.body);
    final errorMessage = responseBody['errors'] ??
        responseBody['detail'] ??
        'Registration failed';
    _showError(context, errorMessage.toString());
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signup successful! Please login'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  "assets/images/signup_image.png",
                  height: 280,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 5),
                Text(
                  "Welcome $name",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Create your account",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                _buildFormFields(),
                const SizedBox(height: 30),
                _buildSignupButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.symmetric()),
        TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: "Username",
              prefixIcon: Icon(Icons.person),
              // validator: (value) {
              //   if (value?.isEmpty ?? true) return "Username is required";
              // if (value!.length < 3) return "Minimum 3 characters";
              // return null;
            )),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
              labelText: "Email", prefixIcon: Icon(Icons.email)),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return "Email is required";
            if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value!)) {
              return "Enter a valid email";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
              labelText: "Password", prefixIcon: Icon(Icons.lock)),
          validator: (value) {
            if (value?.isEmpty ?? true) return "Password is required";
            if (value!.length < 8) return "Minimum 8 characters";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _registerUser(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 10,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text("Sign Up",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(fontSize: 19),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, MyRoutes.loginRoute),
          child: const Text(
            "Login",
            style: TextStyle(
              fontSize: 19,
              color: Colors.deepPurple,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
