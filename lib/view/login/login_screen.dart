import 'package:flutter/material.dart';
import 'package:poketstore/view/forgote_password.dart/forgote_password.dart';
import 'package:poketstore/view/reg/registration.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController userNameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  // color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('assets/login.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text(
                'PoketStor',
                style: TextStyle(
                  fontSize: 35,
                  color: const Color.fromARGB(255, 7, 3, 201),
                ),
              ),
              Text(
                'Welcome back!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: userNameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_3_outlined),
                    labelText: "UserName",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: passwordController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotePassword(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 7, 3, 201),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  height: 50,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Or Sign Up Using',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/facebook.png'),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/google.png'),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/apple.png'),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationScreen(),
                        ),
                      );
                    },

                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
