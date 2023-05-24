import 'package:drone_controller/components/end_value_slider.dart';
import 'package:drone_controller/components/trim_slider.dart';
import 'package:drone_controller/main.dart';
import 'package:flutter/material.dart';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final double _value = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.blue,
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
              onPressed: () {},
              icon: const Icon(
                Icons.wifi,
                color: Colors.green,
              )),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
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
      body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
          child: Column(
            children: [
              TrimSlider(
                  inputType: "Roll Trim",
                  id: "roll",
                  endVal: Provider.of<TrimData>(context).endValue.toDouble(),
                  rollTrim: Provider.of<TrimData>(context).trimData['roll'],
                  pitchTrim: Provider.of<TrimData>(context).trimData['pitch']),
              TrimSlider(
                  inputType: "Pitch Trim",
                  id: "pitch",
                  endVal: Provider.of<TrimData>(context).endValue.toDouble(),
                  rollTrim: Provider.of<TrimData>(context).trimData['roll'],
                  pitchTrim: Provider.of<TrimData>(context).trimData['pitch']),
              EndSlider(endVal: Provider.of<TrimData>(context).endValue.toDouble()),
            ],
          )),
    );
  }
}
