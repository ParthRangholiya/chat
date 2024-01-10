import 'dart:convert';
import 'dart:io';

import 'package:chart_app/models/chart_user.dart';
import 'package:chart_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class Apis {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing cloud Firebase Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for Storing self information
  static late ChartUser me;

  //to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging token
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print(".....................................Push Token: $t");
      }
    });
  }

  //for sending push notification
  static Future<void> sendPushNotification(
      ChartUser chartUser, String msg) async {
    try {
      final body = {
        "to": chartUser.pushToken,
        "notification": {
          "title": chartUser.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        }
      };

      var response =
          await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
              headers: {
                HttpHeaders.contentTypeHeader: "application/json",
                HttpHeaders.authorizationHeader:
                    "key=AAAAmBOOti8:APA91bHRFR7u3QkPMUH5sEDIdkQ447uXLXEkvJ3T-cCqCwBBjrV8TKRjVuS3Peez-S4BYKQyFykx6kFfAOL3sY80h0aiynFA_unC3n8qXimm1sIKSiQxgDCdVU89GoPTUa2qUB8OzR7y"
              },
              body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print("\n sendPushNotificationE: $e");
    }
  }

  //for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  //for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      // user exists

      print("user exists: ${data.docs.first.data()}");
      firestore
          .collection("users")
          .doc(user.uid)
          .collection("my_users")
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      // user don't exist
      return false;
    }
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then(
      (user) async {
        if (user.exists) {
          me = ChartUser.fromJson(user.data()!);
          await getFirebaseMessagingToken();

          // for setting user status to active
          Apis.updateActiveStatus(true);

          debugPrint("My data : ${user.data()}");
        } else {
          await createUser().then((value) => getSelfInfo());
        }
      },
    );
  }

  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chartUser = ChartUser(
      image: user.photoURL.toString(),
      name: user.displayName.toString(),
      about: "Hey, I'm using we chat!",
      createdAt: time,
      id: user.uid,
      lastActive: time,
      email: user.email.toString(),
      pushToken: "",
      isOnline: false,
    );

    await firestore.collection("users").doc(user.uid).set(chartUser.toJson());
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return Apis.firestore
        .collection("users")
        .doc(user.uid)
        .collection("my_users")
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    return Apis.firestore
        .collection("users")
        .where("id", whereIn: userIds.isEmpty ? [""] : userIds)
        // .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  //for checking if user exists or not?
  static Future<void> sendFirstMessge(
      ChartUser chatUser, String msg, Type type) async {
    await firestore
        .collection("users")
        .doc(chatUser.id)
        .collection("my_users")
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  //for adding new user to my user when first message is send
  static Future<void> updateUserInfo() async {
    await firestore.collection("users").doc(user.uid).update({
      "name": me.name,
      "about": me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    // getting image file extantion
    final ext = file.path.split('.').last;
    debugPrint("extantion : $ext");

    //strong file ref with part
    final ref = storage.ref().child("profile_pictures/${user.uid}.$ext");

    //uploding image
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      debugPrint("Data Transferred : ${p0.bytesTransferred / 100} kb");
    });

    //updating image in firestore databse
    me.image = await ref.getDownloadURL();
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({"image": me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChartUser chartUser) {
    return Apis.firestore
        .collection("users")
        .where("id", isEqualTo: chartUser.id)
        .snapshots();
  }

  // update online or last active status of use
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection("users").doc(user.uid).update({
      "is_online": isOnline,
      "last_active": DateTime.now().millisecondsSinceEpoch.toString(),
      "push_token": me.pushToken,
    });
  }

  ///**********Chart Screen Related APIs**********

  // chats (collection) --> conversations_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? "${user.uid}_$id"
      : "${id}_${user.uid}";

  // for getting All messages of a specific coversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChartUser user) {
    return Apis.firestore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(
      ChartUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        msg: msg,
        read: "",
        told: chatUser.id,
        fromld: user.uid,
        type: type,
        sent: time);

    final ref = firestore
        .collection("chats/${getConversationID(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : "image"));
  }

  //update read status of messages
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection("chats/${getConversationID(message.fromld)}/messages/")
        .doc(message.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChartUser user) {
    return Apis.firestore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChartUser chartUser, File file) async {
    // getting image file extantion
    final ext = file.path.split('.').last;
    debugPrint("extantion : $ext");

    //strong file ref with part
    final ref = storage.ref().child(
        "images/${getConversationID(chartUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");

    //uploding image
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      debugPrint("Data Transferred : ${p0.bytesTransferred / 1000} kb");
    });

    //updating image in firestore databse
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chartUser, imageUrl, Type.image);
  }

  // delete message
  static Future<void> deleteMessage(Message message) async {
    firestore
        .collection("chats/${getConversationID(message.told)}/messages")
        .doc(message.sent)
        .delete();
    if (message.type == Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  // update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    firestore
        .collection("chats/${getConversationID(message.told)}/messages")
        .doc(message.sent)
        .update({"msg": updatedMsg});
  }
}
