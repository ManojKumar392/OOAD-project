import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FCM {
  final messaging = FirebaseMessaging.instance;
  String? tokenCollectionName;
  String? tokenDocumentName;

  FCM() {

    messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage((message) async {
      print("Handling a background message: ${message.notification}");
    });
    messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    messaging.onTokenRefresh.listen((event) {
      if (tokenCollectionName != null && tokenDocumentName != null) {
        updateToken(
            collection: tokenCollectionName!, document: tokenDocumentName!);
      }
    });
  }

  ///Will be updated in the document with the field as token
  updateToken({required String collection, required String document}) async {
    tokenCollectionName = collection;
    tokenDocumentName = document;
    if(kIsWeb){
      FirebaseFirestore.instance.collection(collection).doc(document).update({
        "token": FieldValue.arrayUnion([await messaging.getToken(vapidKey: "BNvstmxoGar71uc7JWvVcIdwx08jw15wXqJos1ILIoVTplgRXfLzkeVOA7UQKqCiwo8CmUln0rmmp7N3wDHp-nU")])
      });
    }else {
      FirebaseFirestore.instance.collection(collection).doc(document).update({
        "token": FieldValue.arrayUnion([await messaging.getToken()])
      });
    }
  }
}
