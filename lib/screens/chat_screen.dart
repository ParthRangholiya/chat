import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chart_app/api/apis.dart';
import 'package:chart_app/helper/my_date_util.dart';
import 'package:chart_app/main.dart';
import 'package:chart_app/models/chart_user.dart';
import 'package:chart_app/models/message.dart';
import 'package:chart_app/screens/view_profile_screen.dart';
import 'package:chart_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChartScreen extends StatefulWidget {
  final ChartUser user;
  const ChartScreen({super.key, required this.user});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  //for storing all messages
  List<Message> _list = [];

  //for handling messages text changes
  final TextEditingController _textController = TextEditingController();

  // for storing value of showing or hiding emoji
  bool _showEmoji = false;

  //for checking if image is uploding or not?
  bool _isUploding = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        // ignore: deprecated_member_use
        child: WillPopScope(
          //if searching is on & back button is pressed then close search
          //or else simple close current screen on backs button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              // systemOverlayStyle: SystemUiOverlayStyle(
              //   statusBarColor: Colors.blueGrey,
              //   systemNavigationBarColor: Colors.blueGrey,
              //   systemStatusBarContrastEnforced: true,
              // ),
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
              backgroundColor: Colors.indigo.shade50,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Container(
                //   // margin: EdgeInsets.all(mq.width * .04),
                //   padding: EdgeInsets.symmetric(vertical: mq.width * .02),
                //   child: _appBar(),
                //   decoration: BoxDecoration(
                //     color: Colors.black12,
                //   ),
                // ),
                Expanded(
                  child: StreamBuilder(
                    stream: Apis.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              itemCount: _list.length,
                              shrinkWrap: true,
                              reverse: true,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                "Say Hii! 👋",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),

                //progress indicator for showing uploading
                if (_isUploding)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),

                //chat input filed
                _chartInput(),

                // Show emojis on keyboard emoji button click & vice versa
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfileScreen(user: widget.user),
            ),
          );
        },
        child: StreamBuilder(
          stream: Apis.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChartUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .5),
                  child: CachedNetworkImage(
                    width: mq.height * .055,
                    height: mq.height * .055,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        CircleAvatar(child: Icon(Icons.person)),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? "online"
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive,
                                )
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive,
                            ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ));
  }

  // bottem  chart input field
  Widget _chartInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .0,
        horizontal: mq.width * .01,
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.indigo.shade50),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //input field & buttons
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //emoji button
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.blueGrey,
                        size: 26,
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: () {
                          if (_showEmoji)
                            setState(() => _showEmoji = !_showEmoji);
                        },
                        decoration: InputDecoration(
                          hintText: "Type something",
                          hintStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    // pick image from gallery button
                    IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        //uploadig & sending images one by one
                        for (var i in images) {
                          setState(() => _isUploding = true);
                          await Apis.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploding = false);
                        }
                      },
                      icon: Icon(
                        Icons.image_outlined,
                        color: Colors.blueGrey,
                        size: 26,
                      ),
                    ),

                    // tack image from camera button
                    IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        //pick an image
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 70,
                        );
                        if (image != null) {
                          setState(() => _isUploding = true);
                          await Apis.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploding = false);
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.blueGrey,
                        size: 26,
                      ),
                    ),
                    SizedBox(width: mq.width * .02),
                  ],
                ),
              ),
            ),

            // send message button
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: MaterialButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    if (_list.isEmpty) {
                      // on first message (and user to my_user collection of chat user)
                      Apis.sendFirstMessge(
                          widget.user, _textController.text, Type.text);
                      _textController.text = "";
                    } else {
                      // simply send message
                      Apis.sendMessage(
                          widget.user, _textController.text, Type.text);
                      _textController.text = "";
                    }
                  }
                },
                minWidth: 0,
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
                child: Icon(
                  Icons.send,
                  size: 25,
                  color: Colors.white,
                ),
                shape: CircleBorder(),
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
