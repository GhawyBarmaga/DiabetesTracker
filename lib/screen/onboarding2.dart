import 'package:daibetes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'This application helps you organize and record diabetes readings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/page4.jpeg',
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.to(() => const MyHomePage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: const StadiumBorder(),
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          )
        ]));
  }
}
