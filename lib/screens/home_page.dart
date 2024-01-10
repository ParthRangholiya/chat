import 'package:chart_app/api/apis.dart';
import 'package:chart_app/helper/dialogs.dart';
import 'package:chart_app/main.dart';
import 'package:chart_app/models/chart_user.dart';
import 'package:chart_app/screens/profile_screen.dart';
import 'package:chart_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // for string all users
  List<ChartUser> _list = [];

  // for storing searched items
  List<ChartUser> _searchList = [];

  var selectedItem = "";

  //for storing search status
  bool _isSerching = false;
  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();

    // for updating user active status according to lifecycle events
    //resme -- active or online
    //pause -- inactive of offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      print(
          " =================================================== message : $message");

      if (Apis.auth.currentUser != null) {
        if (message.toString().contains("resume")) {
          Apis.updateActiveStatus(true);
        }
        if (message.toString().contains("pause")) {
          Apis.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        //if searching is on & back button is pressed then close search
        //or else simple close current screen on backs button click
        onWillPop: () {
          if (_isSerching) {
            setState(() {
              _isSerching = !_isSerching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            // leading: Icon(CupertinoIcons.home),
            // more features button
            leading: IconButton(
              onPressed: () {
                PopupMenuButton(
                  onSelected: (value) {
                    setState(() {
                      switch (value) {
                        case 2:
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.blueGrey,
                                      size: 28,
                                    ),
                                    Text("  Logout"),
                                  ],
                                ),
                                content:
                                    Text("Are you sure you want to logout?"),

                                // action buttons
                                actions: [
                                  // no button
                                  MaterialButton(
                                    onPressed: () {
                                      // for hiding dialog
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "No",
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),

                                  // yes buttons
                                  MaterialButton(
                                    onPressed: () {},
                                    child: Text(
                                      "yes",
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          break;
                        // ignore: unreachable_switch_case
                        case 2:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(user: Apis.me),
                            ),
                          );
                          break;
                        default:
                      }
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text("Logout"),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text("Profile Screen"),
                    ),
                  ],
                );
              },
              icon: Icon(
                Icons.menu,
              ),
            ),
            title: _isSerching
                ? TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Name, Email...",
                    ),
                    autofocus: true,
                    onChanged: (value) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text("Chat"),
            actions: [
              // search user button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSerching = !_isSerching;
                  });
                },
                icon: Icon(
                  _isSerching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _addChatUserDialog(context);
            },
            child: Icon(
              Icons.add_comment_rounded,
            ),
          ),
          body: StreamBuilder(
            stream: Apis.getMyUsersId(),

            // get id of only known
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: Apis.getAllUser(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChartUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              itemCount: _isSerching
                                  ? _searchList.length
                                  : _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ChartUserCard(
                                  user: _isSerching
                                      ? _searchList[index]
                                      : _list[index],
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                "No Connections Found!",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  // for adding new chat user
  Future<void> _addChatUserDialog(BuildContext context) {
    // ignore: unused_local_variable
    String email = "";

    return showDialog(
      context: context,
      builder: (context) => SizedBox(
        width: double.infinity,
        height: 200,
        child: AlertDialog(
          // contentPadding: EdgeInsets.only(
          //   left: 24,
          //   right: 24,
          //   top: 20,
          //   bottom: 10,
          // ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          // title
          title: Row(
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.blueGrey,
                size: 28,
              ),
              Text("  Add User"),
            ],
          ),

          // content
          content: SizedBox(
            width: mq.height * .40,
            child: TextFormField(
              maxLines: null,
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                hintText: "Email Id",
                prefixIcon: Icon(
                  Icons.email_rounded,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ),

          // action buttons
          actions: [
            // Cancel button
            MaterialButton(
              onPressed: () {
                // for hiding dialog
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ),

            // Add buttons
            MaterialButton(
              onPressed: () {
                // for hiding dialog
                Navigator.pop(context);
                if (email.isNotEmpty)
                  Apis.addChatUser(email).then((value) {
                    if (!value) {
                      Dialogs.showSnackbar(context, "User does not Exists!");
                    }
                  });
              },
              child: Text(
                "Add",
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
