import 'package:drone_controller/Utility/JoystickUtility.dart';
import 'package:drone_controller/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  double _x = 100;
  double _y = 100;
  String? _stickX = '0', _stickY = '0';
  JoystickMode _joystickMode = JoystickMode.all;

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
        title: const Text('Joystick'),
        actions: [
          JoystickModeDropdown(
            mode: _joystickMode,
            onChanged: (JoystickMode value) {
              setState(() {
                _joystickMode = value;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.white,
            ),
            Ball(_x, _y),
            Positioned(
              top: 15,
              left: 10,
              child: Text("X: $_x , Y: $_y"),
            ),
            Positioned(
              top: 30,
              left: 10,
              child: Text("StickX: $_stickX , StickY: $_stickY"),
            ),
            Align(
              alignment: const Alignment(0, 0.8),
              child: Joystick(
                stick: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                ),
                mode: _joystickMode,
                listener: (details) {
                  setState(() {
                    _stickX = details.x.toStringAsFixed(2);
                    _stickY = details.y.toStringAsFixed(2);
                    _x = _x + step * details.x;
                    _y = _y + step * details.y;
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
