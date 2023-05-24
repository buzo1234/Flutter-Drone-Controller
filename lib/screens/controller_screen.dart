import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:drone_controller/JoystickCodes/joystick.dart';
import 'package:drone_controller/main.dart';
import 'package:drone_controller/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:provider/provider.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  double _x = 100;
  double _y = 100;
  double _x2 = 100;
  double _y2 = 100;
  int _roll = 50, _pitch = 50;
  int _throttle = 0, _yaw = 50;
  final JoystickMode _joystickMode = JoystickMode.all;
  bool connected = false;
  Timer? timer;
  String command = "";
  int portIListenOn = 5514; //0 is random

  bool isArmed = false;

  int rollTrim = 0;
  int pitchTrim = 0;

  int rollStart = 0;
  int rollEnd = 100;
  int pitchStart = 0;
  int pitchEnd = 100;

  ///output = output_start + ((output_end - output_start) / (input_end - input_start)) * (input - input_start)
  ///formula for changing value range

  int changeRange(double input, int start, int end, int iniS, int iniE) {
    int output =
        (start + ((end - start) / (iniE - iniS)) * (input + 1)).toInt();
    return output;
  }

  void _sendMessage() async {
    setState(() {
      command = String.fromCharCode(_roll) +
          String.fromCharCode(_pitch) +
          String.fromCharCode(_throttle) +
          String.fromCharCode(_yaw);
    });
    final udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    udpSocket.send(utf8.encode(command), InternetAddress('192.168.4.1'), 8888);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _x = MediaQuery.of(context).size.width / 2 - ballSize / 2;

    super.didChangeDependencies();

    rollTrim = Provider.of<TrimData>(context).trimData['roll'].toInt();

    pitchTrim = Provider.of<TrimData>(context).trimData['pitch'].toInt();

    int rollDouble = Provider.of<TrimData>(context).endValue.toInt();

    rollEnd = rollDouble;
    pitchEnd = rollDouble;

    _roll = rollDouble ~/ 2;
    _pitch = rollDouble ~/ 2;
  }

  @override
  void initState() {
    isArmed = false;
    command = "";
    connected = false; //initially connection status is "NO" so its FALSE
    rollStart = 0;
    rollEnd = 100;
    pitchStart = 0;
    pitchEnd = 100;

    //timer = Timer.periodic(
    //   const Duration(milliseconds: 250), (Timer t) => sendcmd(command));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          Container(
            height: 40.0,
            margin: const EdgeInsets.symmetric(vertical: 7.0),
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                child: Container(
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.0),
                      color: Colors.grey[400]),
                  height: 17.0,
                  width: 17.0,
                ),
              ),
              Align(
                alignment: const Alignment(0, 0),
                child: BatteryIndicator(
                  batteryFromPhone: false,
                  batteryLevel: 50,
                  style: BatteryIndicatorStyle.values[1],
                  colorful: true,
                  percentNumSize: 12.0,
                  showPercentNum: true,
                  mainColor: Colors.blue,
                  size: 25.0,
                  ratio: 2.0,
                  showPercentSlide: true,
                ),
              ),
            ]),
          ),
          IconButton(
              onPressed: () {
                _sendMessage();
              },
              icon: connected
                  ? const Icon(
                      Icons.wifi,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.wifi_off,
                      color: Colors.red,
                    )),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
              },
              icon: const Icon(Icons.settings, color: Colors.blue))
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/logo_nobg.png',
          width: 75.0,
        ),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.white,
            ),
            Positioned(
                top: 15,
                child: Text("Roll Trim : $rollTrim Pitch Trim: $pitchTrim")),
            Positioned(
              top: 30,
              child: Text("Roll: $_roll , Pitch: $_pitch"),
            ),
            Positioned(
              top: 45,
              child: Text("Throttle: $_throttle , Yaw: $_yaw"),
            ),
            Positioned(
              bottom: 50,
              child: SwipeButton(
                width: 200,
                height: 65,
                thumb: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                activeTrackColor: isArmed
                    ? const Color.fromARGB(255, 98, 213, 104)
                    : const Color.fromARGB(255, 81, 171, 245),
                activeThumbColor: isArmed
                    ? Colors.green
                    : const Color.fromARGB(255, 51, 96, 233),
                child: Container(
                  margin: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    isArmed ? "Armed" : "Un-Armed",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                onSwipe: () async {
                  //bool? hasVib = await Vibration.hasVibrator();

                  if (isArmed) {
                    setState(() {
                      _throttle = 0;
                      _yaw = 50;
                      _roll = rollEnd ~/ 2;
                      _pitch = pitchEnd ~/ 2;
                    });

                    _sendMessage();

                    setState(() {
                      isArmed = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArmed
                              ? "Drone is Armed, and READY TO FLY ✈️"
                              : "Drone is Dis-Armed ",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (!isArmed) {
                    if (_throttle <= 0) {
                      setState(() {
                        isArmed = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArmed
                                ? "Drone is Armed, and READY TO FLY ✈️"
                                : "Drone is Dis-Armed ",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please zero down the Throttle",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please zero down the Throttle",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

                  /* if (hasVib!) {
                    Vibration.vibrate(duration: 200);
                  } */
                },
              ),
            ),
            Align(
              alignment: const Alignment(0.8, 0),
              child: Joystick(
                isThrottle: false,
                stick: Container(
                  height: 105,
                  width: 105,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 7.0,
                    ),
                  ),
                ),
                mode: _joystickMode,
                listener: (details) {
                  setState(() {
                    _roll = changeRange(
                        details.x,
                        rollTrim >= 0 ? rollStart + rollTrim : rollStart,
                        rollTrim < 0 ? rollEnd + rollTrim : rollEnd,
                        -1,
                        1);
                    _pitch = changeRange(
                        -1 * details.y,
                        pitchTrim >= 0 ? pitchStart + pitchTrim : pitchStart,
                        pitchTrim < 0 ? pitchEnd + pitchTrim : pitchEnd,
                        -1,
                        1);
                    _x = _x + step * details.x;
                    _y = _y + step * details.y;
                  });
                  isArmed ? _sendMessage() : null;
                },
              ),
            ),
            Align(
              alignment: const Alignment(-0.8, 0),
              child: Joystick(
                isThrottle: true,
                stick: Container(
                  height: 105,
                  width: 105,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 7.0,
                    ),
                  ),
                ),
                mode: _joystickMode,
                listener: (details) {
                  setState(() {
                    _yaw = changeRange(details.x, 0, 100, -1, 1);
                    _throttle = changeRange(-1 * details.y, 0, 100, -1, 1);
                    _x2 = _x2 + step * details.x;
                    _y2 = _y2 + step * details.y;
                  });
                  isArmed ? _sendMessage() : null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
