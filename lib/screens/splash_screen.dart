import 'package:chart_app/screens/auth/login_screen.dart';
import 'package:chart_app/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemStatusBarContrastEnforced: true,
          statusBarColor: Colors.white,
        ),
      );

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreenView(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(
              seconds: 2,
            ),
            top: mq.height * .15,
            left: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset(
              "assets/image/message.png",
            ),
          ),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: Text(
              "Chat App",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
