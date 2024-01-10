import 'package:cached_network_image/cached_network_image.dart';
import 'package:chart_app/api/apis.dart';
import 'package:chart_app/helper/my_date_util.dart';
import 'package:chart_app/main.dart';
import 'package:chart_app/models/chart_user.dart';
import 'package:chart_app/models/message.dart';
import 'package:chart_app/screens/chat_screen.dart';
import 'package:chart_app/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/material.dart';

class ChartUserCard extends StatefulWidget {
  final ChartUser user;
  const ChartUserCard({super.key, required this.user});

  @override
  State<ChartUserCard> createState() => _ChartUserCardState();
}

class _ChartUserCardState extends State<ChartUserCard> {
  //last message info (if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.grey.shade200,
      elevation: 0.5,
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChartScreen(user: widget.user),
            ),
          );
        },
        child: StreamBuilder(
          stream: Apis.getLastMessages(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

            if (list.isNotEmpty) _message = list[0];

            return ListTile(
              leading: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ProfileDialog(user: widget.user),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .5),
                      child: CachedNetworkImage(
                        width: mq.height * .055,
                        height: mq.height * .055,
                        imageUrl: widget.user.image,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            CircleAvatar(child: Icon(Icons.person)),
                      ),
                    ),
                  ),
                ],
              ),

              //user name
              title: Text(widget.user.name),

              //last message
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? "image"
                        : _message!.msg
                    : widget.user.about,
                maxLines: 1,
              ),

              //last message time
              trailing: _message == null
                  ? null
                  //show nothing when no message is sent
                  : _message!.read.isEmpty && _message!.fromld != Apis.user.uid
                      ?
                      //show for unread messages
                      Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(
                            context: context,
                            time: _message!.sent,
                          ),
                          style: TextStyle(
                            color: Colors.black38,
                          ),
                        ),
            );
          },
        ),
      ),
    );
  }
}
