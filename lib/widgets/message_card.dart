import 'package:cached_network_image/cached_network_image.dart';
import 'package:chart_app/api/apis.dart';
import 'package:chart_app/helper/dialogs.dart';
import 'package:chart_app/helper/my_date_util.dart';
import 'package:chart_app/main.dart';
import 'package:chart_app/models/message.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.message.fromld;

    return InkWell(
      onLongPress: () {
        _ShowBottomSheet(context, isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  //send or another user message cvvv
  Widget _blueMessage() {
    //update last read message if send and received are different
    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStatus(widget.message);
      print("============================================message read updated");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .02
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .01,
              vertical: mq.height * .01,
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 198, 215, 223),
              border: Border.all(color: Colors.blueGrey),

              //making border curved
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: widget.message.type == Type.text
                // show text
                ? Text(widget.message.msg)
                :
                // show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .01),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // message time
        Padding(
          padding: EdgeInsets.only(right: mq.width * .05),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  //our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // message time
        Row(
          children: [
            //for adding some space
            SizedBox(
              width: mq.width * .04,
            ),
            //double tick blue icon for messages read
            // if (widget.message.read.isNotEmpty)
            Icon(Icons.done_all_rounded,
                color: widget.message.read.isEmpty ? Colors.grey : Colors.blue,
                size: 20),

            //for adding some space
            SizedBox(width: 2),

            // read time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .02
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 194, 240, 196),

              border: Border.all(color: Colors.lightGreen),

              //making border curved
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: widget.message.type == Type.text
                // show text
                ? Text(widget.message.msg)
                :
                // show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .01),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

// bottom sheet for modifying messages details
  Future<dynamic> _ShowBottomSheet(BuildContext context, bool isMe) {
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
          children: [
            // black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: mq.height * .015,
                horizontal: mq.width * .4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.grey,
              ),
            ),

            widget.message.type == Type.text
                ? // copy option
                _OptionItem(
                    icon: Icon(Icons.copy_all_rounded,
                        color: Colors.blueGrey, size: 26),
                    name: "Copy Text",
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        // for hiding bottom sheet
                        Navigator.pop(context);

                        Dialogs.showSnackbar(context, "Text Copied!");
                      });
                    },
                  )
                : // save option
                _OptionItem(
                    icon: Icon(Icons.download_rounded,
                        color: Colors.blueGrey, size: 26),
                    name: "Save Image",
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: "Chat App")
                            .then((success) {
                          // for hiding bottom sheet
                          Navigator.pop(context);

                          if (success != null && success) {
                            Dialogs.showSnackbar(
                                context, "Image successfully selected!");
                          }
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),

            if (isMe)
              // seprator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .06,
                indent: mq.height * .03,
              ),

            if (widget.message.type == Type.text && isMe)
              // edit option
              _OptionItem(
                icon: Icon(Icons.edit, color: Colors.blueGrey, size: 26),
                name: "Edit Message",
                onTap: () {
                  // for hiding bottom sheet
                  Navigator.pop(context);
                  _showMessageUpdateDialog(context);
                },
              ),

            if (isMe)
              // Delete option
              _OptionItem(
                icon: Icon(Icons.delete_forever, color: Colors.red, size: 26),
                name: "Delete Message",
                onTap: () async {
                  await Apis.deleteMessage(widget.message).then((value) {});
                  // for hiding bottom sheet
                  Navigator.pop(context);
                },
              ),

            // seprator or divider
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .06,
              indent: mq.height * .03,
            ),
            // send option
            _OptionItem(
              icon: Icon(Icons.remove_red_eye, color: Colors.blueGrey),
              name:
                  "Sent At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
              onTap: () {},
            ),

            // read option
            _OptionItem(
              icon: Icon(Icons.remove_red_eye, color: Colors.red),
              name: widget.message.read.isEmpty
                  ? "Read At : Not seen yet"
                  : "Read At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}",
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  // dialog for updating messages content
  Future<void> _showMessageUpdateDialog(BuildContext context) {
    String updateMsg = widget.message.msg;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        // title
        title: Row(
          children: [
            Icon(
              Icons.message,
              color: Colors.blueGrey,
              size: 28,
            ),
            Text("  Update Message"),
          ],
        ),

        // content
        content: SizedBox(
          width: mq.height * .40,
          child: TextFormField(
            initialValue: updateMsg,
            maxLines: null,
            onChanged: (value) => updateMsg = value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),

        // action buttons
        actions: [
          // Cancel
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

          // Update
          MaterialButton(
            onPressed: () {
              // for hiding dialog
              Navigator.pop(context);
              Apis.updateMessage(widget.message, updateMsg);
            },
            child: Text(
              "Update",
              style: TextStyle(
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.width * .025,
          bottom: mq.width * .025,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                "    $name",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
