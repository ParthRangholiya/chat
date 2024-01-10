import 'package:chart_app/api/apis.dart';
import 'package:chart_app/screens/auth/auth_methodes.dart';
import 'package:chart_app/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

class LoginScreenView extends StatefulWidget {
  const LoginScreenView({super.key});

  @override
  State<LoginScreenView> createState() => _LoginScreenViewState();
}

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final AuthMethode authMethode = AuthMethode();

class _LoginScreenViewState extends State<LoginScreenView> {
  bool animat = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(
        milliseconds: 500,
      ),
      () {
        setState(
          () {
            animat = true;
          },
        );
      },
    );
  }

  handleGoogleBtnclick() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    authMethode.signInWithGoogle().then((user) async {
      if (user != null) {
        debugPrint("\nUser : ${user.user}");
        debugPrint("\nUser AdditionalInfo : ${user.additionalUserInfo}");
        SnackBar(
          content: Text("you are successful login"),
          backgroundColor: Colors.black87,
        );

        if ((await Apis.userExists())) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ),
          );
        } else {
          await Apis.createUser().then(
            (value) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
              );
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Chat"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(
              seconds: 1,
            ),
            top: mq.height * .15,
            left: animat ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            child: Image.asset(
              "assets/image/message.png",
            ),
          ),
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .07,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                minimumSize: const Size(double.infinity, 10),
              ),
              onPressed: handleGoogleBtnclick,
              icon: Image.asset(
                "assets/image/google_logo.png",
                height: mq.height * .02,
              ),
              label: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.indigo,
                  ),
                  children: [
                    TextSpan(text: "Sign In with "),
                    TextSpan(
                      text: "Google",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
