import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = FlutterLocalNotificationsPlugin();
  await notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  tz.initializeTimeZones();
  runApp(MyApp(notifications: notifications));
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin notifications;
  const MyApp({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: NotificationHome(notifications: notifications),
    );
  }
}

class NotificationHome extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notifications;
  const NotificationHome({super.key, required this.notifications});

  @override
  State<NotificationHome> createState() => _NotificationHomeState();
}

class _NotificationHomeState extends State<NotificationHome> {
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(msg)),
        behavior: SnackBarBehavior.floating,
        width: 200,
      ),
    );
  }

  Future<void> _immediateNotification() async {
    await widget.notifications.show(
      1,
      'Immediate',
      'This notification appears right now!',
      const NotificationDetails(
        android: AndroidNotificationDetails('ch1', 'Immediate', importance: Importance.max),
        iOS: DarwinNotificationDetails(),
      ),
    );
    _showMessage('✓ Immediate');
  }

  Future<void> _scheduledNotification() async {
    await widget.notifications.zonedSchedule(
      2,
      'Scheduled',
      '5 seconds have passed!',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails('ch2', 'Scheduled'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    _showMessage('⏰ 5 seconds');
  }

  Future<void> _bigTextNotification() async {
    await widget.notifications.show(
      3,
      'Big Text',
      'Pull down to read more',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'ch3',
          'Big Text',
          styleInformation: const BigTextStyleInformation(
            'I am Gregory CLEDANOR, computer science student at Ecole Superieure d\'Infotronique d\'Haiti. This app is developed by me for the Android course.',
          ),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
    _showMessage('📝 Big text');
  }

  Future<void> _actionNotification() async {
    final androidDetails = AndroidNotificationDetails(
      'ch4',
      'With Buttons',
      importance: Importance.max,
      priority: Priority.high,
      actions: const [
        AndroidNotificationAction('accept', 'Accept', showsUserInterface: true),
        AndroidNotificationAction('decline', 'Decline', showsUserInterface: true),
      ],
    );
    await widget.notifications.show(
      4,
      'With Buttons',
      'Tap a button',
      NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails()),
    );
    _showMessage('🔘 Buttons');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GregNotif', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Notification',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _btn(Icons.flash_on, Colors.blue, 'Immediate', _immediateNotification),
            _btn(Icons.schedule, Colors.orange, 'Scheduled (5s)', _scheduledNotification),
            _btn(Icons.text_fields, Colors.purple, 'Big Text', _bigTextNotification),
            _btn(Icons.touch_app, Colors.teal, 'With Buttons', _actionNotification),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, Color color, String label, VoidCallback onTap) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}