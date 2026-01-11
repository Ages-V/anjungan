import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Pastikan ini sesuai nama file di folder mipmap
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("🔔 Notifikasi diklik: ${details.payload}");
      },
    );

    // Request Permission Lengkap
    final platform = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.requestNotificationsPermission();
    await platform?.requestExactAlarmsPermission();
  }

  // === FUNGSI JADWAL ===
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // Minta izin lagi (Safety check)
      final platform = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await platform?.requestExactAlarmsPermission();

      final reminderTime = scheduledTime; 

      print("🕒 Waktu Sekarang: ${DateTime.now()}");
      print("⏰ Waktu Akan Bunyi: $reminderTime");

      if (reminderTime.isBefore(DateTime.now())) {
        print("❌ GAGAL: Waktu sudah lewat!");
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            // === NAMA CHANNEL BARU (Agar settingan HP kereset) ===
            'channel_anti_stres_v1', 
            'Notifikasi Bimbingan', 
            channelDescription: 'Pengingat jadwal bimbingan skripsi',
            importance: Importance.max, // Wajib Max
            priority: Priority.high,    // Wajib High
            icon: '@mipmap/ic_launcher',
            
            // === SETTINGAN PAKSA BUNYI ===
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true, // Mencoba muncul full screen jika layar mati
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("✅ SUKSES: Notifikasi dijadwalkan!");
    } catch (e) {
      print("❌ ERROR SYSTEM: $e");
    }
  }

  // === FUNGSI TES LANGSUNG (Opsional, untuk debug) ===
  Future<void> showNotificationImmediate() async {
     try {
       await flutterLocalNotificationsPlugin.show(
        999,
        'TES LANGSUNG',
        'Halo, ini tes notifikasi!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_anti_stres_v1', // Samakan channelnya
            'Notifikasi Bimbingan',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
     } catch (e) {
       print(e);
     }
  }
}