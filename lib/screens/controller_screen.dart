import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:drone_controller/JoystickCodes/joystick.dart';
import 'package:drone_controller/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:battery_indicator/battery_indicator.dart';

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
  }

  @override
  void initState() {
    isArmed = false;
    command = "";
    connected = false; //initially connection status is "NO" so its FALSE

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
                    ))
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
              right: 10,
              child: Text("Roll: $_roll , Pitch: $_pitch"),
            ),
            Positioned(
              top: 0,
              right: 10,
              child: Text("Throttle: $_throttle , Yaw: $_yaw"),
            ),
            Positioned(
              bottom: 20,
              child: SwipeButton(
                width: 200,
                thumb: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                activeTrackColor:
                    isArmed ? Colors.green[300] : Colors.blue[300],
                activeThumbColor: isArmed ? Colors.green : Colors.blue,
                child: Container(
                  margin: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    isArmed ? "Swipe to DisArm" : "Swipe to Arm",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                onSwipe: () async {
                  //bool? hasVib = await Vibration.hasVibrator();

                  if (_throttle <= 0) {
                    setState(() {
                      _throttle = 0;
                      _yaw = 50;
                      _roll = 50;
                      _pitch = 50;
                    });

                    _sendMessage();

                    if (isArmed) {
                      setState(() {
                        isArmed = false;
                      });
                    } else {
                      setState(() {
                        isArmed = true;
                      });
                    }

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
                  height: 75,
                  width: 75,
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                ),
                mode: _joystickMode,
                listener: (details) {
                  setState(() {
                    _roll = changeRange(details.x, 0, 100, -1, 1);
                    _pitch = changeRange(-1 * details.y, 0, 100, -1, 1);
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
                  height: 75,
                  width: 75,
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                ),
                mode: _joystickMode,
                listener: (details) {
                  setState(() {
                    _yaw = changeRange(details.x, 0, 100, -1, 1);
                    _throttle = changeRange(-1 * details.y, -2, 100, -1, 1);
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
