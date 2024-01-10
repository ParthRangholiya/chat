import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chart_app/api/apis.dart';
import 'package:chart_app/helper/dialogs.dart';
import 'package:chart_app/main.dart';
import 'package:chart_app/models/chart_user.dart';
import 'package:chart_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChartUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          // leading: Icon(CupertinoIcons.home),
          title: Text("Profile Screens"),
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.search,
          //     ),
          //   ),
          //   IconButton(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.more_vert,
          //     ),
          //   ),
          // ],
        ),

        //floating buttons to log out
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          onPressed: () async {
            //for showing progress dialog
            Dialogs.ShowprogressBar(context);

            await Apis.updateActiveStatus(false);

            //sign out from app
            await Apis.auth.signOut().then(
              (value) async {
                await GoogleSignIn().signIn().then(
                  (value) {
                    // for hiding progress dialog
                    Navigator.pop(context);

                    // for moving to home screen
                    Navigator.pop(context);

                    Apis.auth = FirebaseAuth.instance;

                    // replacing home screen with login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreenView(),
                      ),
                    );
                  },
                );
              },
            );
          },
          icon: Icon(Icons.logout),
          label: Text("Logout"),
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                imageUrl: widget.user.image,
                                fit: BoxFit.fill,
                                // placeholder: (context, url) =>
                                //     Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(child: Icon(Icons.person)),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 2,
                          onPressed: () {
                            _ShowBottomSheet(context);
                          },
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                          ),
                          color: Colors.blueGrey,
                          shape: CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mq.height * .03),
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black45),
                  ),
                  SizedBox(height: mq.height * .05),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (value) => Apis.me.name = value ?? "",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "This Field is required",
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: "eg. Happy Singh",
                      label: Text("Name"),
                    ),
                  ),
                  SizedBox(height: mq.height * .02),
                  TextFormField(
                    onSaved: (value) => Apis.me.about = value ?? "",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "This Field is required",
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: "eg. Felling Happy",
                      label: Text("About"),
                    ),
                  ),
                  SizedBox(height: mq.height * .05),
                  FilledButton.icon(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        Apis.updateUserInfo().then(
                          (value) {
                            Dialogs.showSnackbar(
                                context, "Profile updated successfully");
                          },
                        );
                      }
                    },
                    icon: Icon(Icons.edit),
                    label: Text(
                      "Update", //UPDATE",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// bottom sheet for picking a profile picture for user
  Future<dynamic> _ShowBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * .03,
            bottom: mq.height * .05,
          ),
          children: [
            Text(
              "Pick profile Picture",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Divider(
              indent: mq.width * .10,
              endIndent: mq.width * .10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      debugPrint(
                          "Image Path: ${image.path} --MimeType: ${image.mimeType}");
                      setState(() {
                        _image = image.path;
                      });
                      Apis.updateProfilePicture(File(_image!));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(
                      mq.width * .3,
                      mq.height * .15,
                    ),
                  ),
                  child: Image.asset(
                    "assets/image/picture.png",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      debugPrint(
                          "Image Path: ${image.path} --MimeType: ${image.mimeType}");
                      setState(() {
                        _image = image.path;
                      });
                      Apis.updateProfilePicture(File(_image!));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(
                      mq.width * .3,
                      mq.height * .15,
                    ),
                  ),
                  child: Image.asset(
                    "assets/image/camera.png",
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
