import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'applogo.dart';
import 'loginPage.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false; // For form validation
  bool _isLoading = false; // For showing a loading indicator

  /// Function to register the user
  void registerUser() async {
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        isValidEmail(emailController.text)) {
      setState(() {
        _isLoading = true; // Start loading
      });

      var regBody = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };

      try {
        var response = await http.post(
          Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        var jsonResponse = jsonDecode(response.body);

        // Check API response status
        if (jsonResponse['status']) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignInPage()),
          );
        } else {
          _showMessage("Registration failed. Please try again.");
        }
      } catch (e) {
        _showMessage("An error occurred. Please check your connection.");
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } else {
      setState(() {
        _isNotValidate = true; // Trigger validation error
      });
    }
  }

  /// Function to show a toast-like message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Function to validate email format
  bool isValidEmail(String email) {
    String emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    return RegExp(emailPattern).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Gradient background
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0XFFF95A3B), Color(0XFFF96713)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CommonLogo(),
                    HeightBox(10),
                    "CREATE YOUR ACCOUNT".text.size(22).yellow100.make(),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: TextStyle(color: Colors.white),
                        errorText: _isNotValidate &&
                                !isValidEmail(emailController.text)
                            ? "Enter a valid email address"
                            : null,
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ).p4().px24(),
                    TextField(
                      controller: passwordController,
                      obscureText: true, // Hide password
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            final data = ClipboardData(
                              text: passwordController.text,
                            );
                            Clipboard.setData(data);
                          },
                        ),
                        prefixIcon: IconButton(
                          icon: Icon(Icons.password),
                          onPressed: () {
                            String passGen = generatePassword();
                            passwordController.text = passGen;
                            setState(() {});
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: TextStyle(color: Colors.white),
                        errorText:
                            _isNotValidate && passwordController.text.isEmpty
                                ? "Enter a password"
                                : null,
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ).p4().px24(),
                    if (_isLoading)
                      CircularProgressIndicator()
                          .p16() // Show loader when loading
                    else
                      GestureDetector(
                        onTap: registerUser,
                        child: VxBox(
                          child: "Register".text.white.makeCentered().p16(),
                        ).green600.roundedLg.make().px16().py16(),
                      ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      },
                      child: HStack([
                        "Already Registered?".text.make(),
                        " Sign In".text.white.make(),
                      ]).centered(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Password generator function
String generatePassword() {
  const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const lower = 'abcdefghijklmnopqrstuvwxyz';
  const numbers = '1234567890';
  const symbols = '!@#\$%^&*()<>,./';

  const passLength = 12;
  final seed = upper + lower + numbers + symbols;
  final rand = Random();

  return List.generate(passLength, (_) => seed[rand.nextInt(seed.length)])
      .join();
}
