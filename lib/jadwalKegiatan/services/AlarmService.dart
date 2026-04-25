import 'dart:async';
import 'package:get/get.dart';
import 'package:alarm/alarm.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/AlarmRingScreen_view.dart';

class AlarmService extends GetxService {
  late StreamSubscription<AlarmSettings> _subscription;
  var isRinging = false.obs;
  AlarmSettings? currentAlarm;

  Future<AlarmService> init() async {
    await Alarm.init();

    //await _checkIfRingingOnStart();
    _listenToAlarm();

    return this;
  }

  void _listenToAlarm() {
    print("Alarm");
    _subscription = Alarm.ringStream.stream.listen((alarmSettings) {
      print("AlarmService: RINGING! ID: ${alarmSettings.id}");

      isRinging.value = true;
      currentAlarm = alarmSettings;


      if (Get.context != null) {
        Get.to(() => AlarmRingScreen_view(alarmSettings: alarmSettings),
          transition: Transition.fadeIn,
        );
      }
    });
  }

  /*
  Future<void> _checkIfRingingOnStart() async {
    final now = DateTime.now();
    final alarms = await Alarm.getAlarms();

    for (var i in alarms) {
      if (i.dateTime.isBefore(now.add(const Duration(seconds: 10))) &&
          i.dateTime.add(const Duration(minutes: 1)).isAfter(now)) {

        print("AlarmService: Startup Ringing: ${i.id}");
        isRinging.value = true;
        currentAlarm = i;
        break;
      }
    }
  }

   */


  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}