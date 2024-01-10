import 'package:cached_network_image/cached_network_image.dart';
import 'package:chart_app/helper/my_date_util.dart';
import 'package:chart_app/main.dart';
import 'package:chart_app/models/chart_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// view profiles screen -- to view profile of user
class ViewProfileScreen extends StatefulWidget {
  final ChartUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(CupertinoIcons.home),
          title: Text(widget.user.name),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert,
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Joined On : ",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                context: context,
                time: widget.user.createdAt,
                showYear: true,
              ),
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ],
        ),
        body: Padding(
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
                      child: CachedNetworkImage(
                        width: mq.height * .2,
                        height: mq.height * .2,
                        imageUrl: widget.user.image,
                        fit: BoxFit.fill,
                        errorWidget: (context, url, error) =>
                            CircleAvatar(child: Icon(Icons.person)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: mq.height * .03),
                Text(
                  widget.user.email,
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
                SizedBox(height: mq.height * .02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "About : ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      widget.user.about,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
