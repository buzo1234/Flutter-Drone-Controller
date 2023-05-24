import 'package:drone_controller/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EndSlider extends StatefulWidget {
  double endVal;
  EndSlider({required this.endVal, super.key});
  @override
  State<EndSlider> createState() => _EndSliderState();
}

class _EndSliderState extends State<EndSlider> {
  double _value = 100;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _value = widget.endVal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Color.fromARGB(26, 158, 158, 158),
              blurRadius: 1.0,
              offset: Offset(0, 5))
        ],
        color: Colors.white,
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Adjust Throws",
              style: TextStyle(fontSize: 17),
            ),
            Text(_value.toInt().toString()),
            IconButton(
                onPressed: () {
                  setState(() {
                    _value = 100;
                  });
                  Provider.of<TrimData>(context, listen: false)
                      .updateEndValue(_value.toInt());
                },
                icon: const Icon(Icons.restart_alt))
          ],
        ),
        Slider(
          min: 50,
          max: 300,
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
            });

            Provider.of<TrimData>(context, listen: false)
                .updateEndValue(_value.toInt());
          },
        ),
      ]),
    );
  }
}
