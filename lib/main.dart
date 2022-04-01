import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_fcm_notifications_exp/model/push_notificaton_model.dart';
import 'package:firebase_fcm_notifications_exp/widgets/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';






main()  {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Initiliaze some values
  late final FirebaseMessaging _messaging;
  int _totalNotificationCounter = 0;
  //model
  PushNotification? _notificationInfo;
  //Register Notification
  void registerNotification() async {
    await Firebase.initializeApp();
    //instance for firebase messaging
    _messaging = FirebaseMessaging.instance;

    //Permissions for notification
    //three types of states in Notification
    //not determined(null), granted(true). decline(false)

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted the permission');

      //main message
      //listening to server notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        setState(() {
          _totalNotificationCounter++;
          _notificationInfo = notification;
        });

        if(_notificationInfo != null) {
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotification: _totalNotificationCounter),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.blue,
            duration: const Duration(seconds: 2),
          );
        }
      });
    }
    else{
      print('user declined the permission');
    }
  }

  void onBackgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    });
  }

  void onTerminateStateNotification() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification!.title,
        body: initialMessage.notification!.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );

      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    }
  }

  @override
  void initState() {
    registerNotification();
    onBackgroundNotification();
    onTerminateStateNotification();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Push Notification'),),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              const Text("Flutter PushNotification",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),),
              NotificationBadge(totalNotification: _totalNotificationCounter),
              _notificationInfo != null
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Title: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}'),
                  Text('Body: ${_notificationInfo!.dataBody ?? _notificationInfo!.body}'),
                ],
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

