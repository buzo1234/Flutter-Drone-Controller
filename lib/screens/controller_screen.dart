import 'package:drone_controller/JoystickCodes/joystick.dart';
import 'package:drone_controller/Utility/JoystickUtility.dart';
import 'package:drone_controller/main.dart';
import 'package:flutter/material.dart';

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
  String? _roll = '0', _pitch = '0';
  String? _throttle = '0', _yaw = '0';
  final JoystickMode _joystickMode = JoystickMode.all;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _x = MediaQuery.of(context).size.width / 2 - ballSize / 2;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.settings,
                color: Colors.blue,
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
                    _roll = details.x.toStringAsFixed(2);
                    _pitch = (-1 * details.y).toStringAsFixed(2);
                    _x = _x + step * details.x;
                    _y = _y + step * details.y;
                  });
                },
              ),
            ),
            Align(
              alignment: const Alignment(-0.8, 0),
              child: Joystick(
                isThrottle:true,
                stick: Container(
                  height: 75,
                  width: 75,
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                ),
                mode: _joystickMode,
                listener: (details) {
                  setState(() {
                    _yaw = details.x.toStringAsFixed(2);
                    _throttle = (-1 * details.y).toStringAsFixed(2);
                    _x2 = _x2 + step * details.x;
                    _y2 = _y2 + step * details.y;
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
