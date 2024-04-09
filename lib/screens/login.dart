import 'package:flutter/material.dart';
import 'package:ic_scanner/api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginNameController =
      TextEditingController(text: "John");
  final TextEditingController _passwordController =
      TextEditingController(text: "secret123");

  bool _loading = false;

  void _toHome() {
    // Ensure navigation is performed on the main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, "/home");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 42),
              child: Text("PUP SIGHT",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _loginNameController,
                      maxLength: 24,
                      decoration:
                          const InputDecoration(labelText: 'Login Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your login name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      maxLength: 32,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 52, 8, 8),
                      child: SizedBox(
                          height: 42,
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  userLogin(
                                          loginName: _loginNameController.text,
                                          password: _passwordController.text)
                                      .then((res) {
                                    if (res.statusCode == 200) {
                                      _loading = false;
                                      _toHome();
                                    } else if (res.statusCode == 401) {
                                      const snackBar = SnackBar(
                                        content: Text('Invalid credentials'),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } else {
                                      const snackBar = SnackBar(
                                        content: Text('Server Error'),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  }).whenComplete(() {
                                    setState(() {
                                      _loading = false;
                                    });
                                  });
                                }
                              },
                              child: _loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text("Login"))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white12)),
                          onPressed: () {
                            Navigator.pushNamed(context, "/register");
                          },
                          child: const Text('Register instead'),
                        ),
                      ),
                    ),
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
