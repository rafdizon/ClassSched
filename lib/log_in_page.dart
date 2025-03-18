import 'package:class_sched/services/auth_service.dart';
import 'package:flutter/material.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  var isViewPasswordEnabled = false;
  final authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final email = emailController.text;
    final password = passwordController.text;

    try {
      await authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: isMobile ? 20 : 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo1.png',
                    height: 80,
                  ),
                  if (!isMobile) ...[
                    Container(
                      height: 100,
                      child: VerticalDivider(
                        color: Theme.of(context).colorScheme.primary,
                        thickness: 1,
                        width: 50,
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo3.png',
                      width: 300,
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                ],
              ),
              SizedBox(height: isMobile ? 20 : 40),
              Container(
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).colorScheme.tertiary,
                width: isMobile ? screenWidth * 0.9 : 500,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'SPUSM E-mail',
                          labelStyle: Theme.of(context).textTheme.labelSmall
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: Theme.of(context).textTheme.labelSmall,
                          suffixIcon: GestureDetector(
                            child: const Icon(Icons.remove_red_eye),
                            onTapDown: (_) {
                              setState(() {
                                isViewPasswordEnabled = true;
                              });
                            },
                            onTapUp: (_) {
                              setState(() {
                                isViewPasswordEnabled = false;
                              });
                            },
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                        obscureText: !isViewPasswordEnabled,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: login,
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: TextButton(
                          onPressed: () {
                          },
                          child: const Text('Forgot Password'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 20 : 60),
            ],
          ),
        ),
      ),
    );
  }
}
