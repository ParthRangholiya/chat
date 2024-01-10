import 'package:cached_network_image/cached_network_image.dart';
import 'package:chart_app/main.dart';
import 'package:chart_app/models/chart_user.dart';
import 'package:chart_app/screens/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChartUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            //user profile picture
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  width: mq.width * .5 / 1.2,
                  height: mq.height * .9 / 4.6,
                  imageUrl: user.image,
                  fit: BoxFit.fill,
                  // placeholder: (context, url) =>
                  //     Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),

            //user name
            Positioned(
              left: mq.width * .04,
              top: mq.height * .02,
              width: mq.width * .55,
              child: Text(
                user.name,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // info button
            Positioned(
              right: 8,
              top: 4,
              child: Align(
                alignment: Alignment.topRight,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewProfileScreen(user: user),
                      ),
                    );
                  },
                  minWidth: 0,
                  padding: EdgeInsets.all(0),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blueGrey,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
