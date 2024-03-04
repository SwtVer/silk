import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:silk_innovation_swativerma/game.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //String? _phoneNumberError;

  bool _isPasswordType = true;
  void _toggleInputType() {
    setState(() {
      _isPasswordType = !_isPasswordType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        body: SafeArea(
          child: Center(
            child: Column(children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                "WELCOME",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Phone Number',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      keyboardType: _isPasswordType
                          ? TextInputType.text
                          : TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: _isPasswordType
                            ? 'Password (Hint: Alphanumeric)'
                            : 'PIN (Hint: 4-digit number)',
                        hintText: 'Password:Text/Pin',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordType ? Icons.vpn_key : Icons.lock,
                          ),
                          onPressed: _toggleInputType,
                          tooltip: _isPasswordType
                              ? 'Switch to PIN'
                              : 'Switch to Password',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  _submitForm();
                },
                child: const Text('Sign In'),
              ),
            ]),
          ),
        ));
  }

  void _submitForm() {
    String phoneNumber = _phoneController.text.trim();
    String credential = _passwordController.text.trim();
    print(credential);

    if (_isValidPhoneNumber(phoneNumber)) {
      _login(phoneNumber, credential);
    } else {
      _showError('Invalid phone number');
    }
  }

  bool _isValidPhoneNumber(String value) {
    if (value.length != 10) {
      return false;
    }

    if (RegExp(r'^98[456]\d{7}$').hasMatch(value)) {
      return true;
    }

    if (value.startsWith('984') || value.startsWith('986')) {
      return true;
    } else if (value.startsWith('985')) {
      return true;
    } else if (value.startsWith('980') ||
        value.startsWith('981') ||
        value.startsWith('982')) {
      return true;
    }

    return false;
  }

  bool _isValidPassword(String value) {
    return value.isNotEmpty;
  }

  bool _isValidPIN(String value) {
    return RegExp(r'^\d{4}$').hasMatch(value);
  }

  void _login(String phoneNumber, String credential) async {
    String url = 'https://wallet.silkinv.com/api/login';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'App-Authorizer': '647061697361',
      'Accept': 'application/json',
    };

    String requestBody;
    if (_isValidPhoneNumber(phoneNumber)) {
      if (_isValidPIN(credential)) {
        requestBody = jsonEncode({
          'mobile_no': phoneNumber,
          'pin': credential,
          'fcm_token': 'no_fcm',
        });
      } else if (_isValidPassword(credential)) {
        requestBody = jsonEncode({
          'mobile_no': phoneNumber,
          'password': credential,
          'fcm_token': 'no_fcm',
        });
      } else {
        _showError('Invalid password/PIN');
        return;
      }

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: requestBody,
        );

        if (response.statusCode == 200) {
          // Successful login
          //final responseData = jsonDecode(response.body);
          // String accessToken = responseData['access_token'];
          // Store the access token in the device
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Game()),
          );
        } else {
          // Handle error response
          //final errorData = jsonDecode(response.body);
          //String errorMessage = errorData['message'];
          // Display error message to the user
        }
      } catch (e) {
        // Handle network errors
        print('Error: $e');
      }
    } else {
      _showError('Invalid phone number');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
