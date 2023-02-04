import 'dart:async';

import 'package:drone_controller/JoystickCodes/joystick.dart';
import 'package:drone_controller/Utility/JoystickUtility.dart';
import 'package:drone_controller/main.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

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
  IOWebSocketChannel? channel;
  bool connected = false;
  Timer? timer;
  String command = "";

  ///output = output_start + ((output_end - output_start) / (input_end - input_start)) * (input - input_start)
  ///formula for changing value range

  int changeRange(double input, int start, int end, int iniS, int iniE) {
    int output =
        (start + ((end - start) / (iniE - iniS)) * (input + 1)).toInt();
    return output;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _x = MediaQuery.of(context).size.width / 2 - ballSize / 2;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    command = "$_roll : $_pitch : $_throttle : $_yaw";
    connected = false; //initially connection status is "NO" so its FALSE

    Future.delayed(Duration.zero, () async {
      channelconnect(); //connect to WebSocket wth NodeMCU
    });
    timer = Timer.periodic(
        const Duration(milliseconds: 250), (Timer t) => sendcmd(command));
    super.initState();
  }

  channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://192.168.0.1:81"); //channel IP : Port
      channel!.stream.listen(
        (message) {
          print(message);
          setState(() {
            if (message == "connected") {
              connected = true; //message is "connected" from NodeMCU
            }
          });
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendcmd(String cmd) async {
    print("Entered $cmd");
    if (connected == true) {
      channel!.sink.add(cmd); //sending Command to NodeMCU

    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {},
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
        title: const Text(
          'PyiTechnologies',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.white,
            ),
            Ball(_x, _y),
            Ball(_x2, _y2),
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
                    command =
                        "${changeRange(details.x, 0, 100, -1, 1)} : ${changeRange(-1 * details.y, 0, 100, -1, 1)} : $_throttle : $_yaw";
                  });
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
                    _throttle = changeRange(-1 * details.y, 0, 255, -1, 1);
                    _x2 = _x2 + step * details.x;
                    _y2 = _y2 + step * details.y;
                    command =
                        "$_roll : $_pitch : ${changeRange(-1 * details.y, 0, 255, -1, 1)} : ${changeRange(details.x, 0, 100, -1, 1)}";
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
