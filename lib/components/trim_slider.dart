import 'package:drone_controller/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrimSlider extends StatefulWidget {
  String inputType;
  String id;
  double rollTrim, pitchTrim, endVal;

  TrimSlider(
      {required this.inputType,
      required this.endVal,
      required this.id,
      required this.pitchTrim,
      required this.rollTrim,
      super.key});

  @override
  State<TrimSlider> createState() => _TrimSliderState();
}

class _TrimSliderState extends State<TrimSlider> {
  Map data = {"roll": 0.0, "pitch": 0.0};

  double _value = 50;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = {"roll": widget.rollTrim, "pitch": widget.pitchTrim};
    _value = widget.endVal / 2 + data[widget.id];
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    data = {"roll": widget.rollTrim, "pitch": widget.pitchTrim};
    _value = (widget.endVal / 2 + data[widget.id]) > widget.endVal
        ? widget.endVal
        : (widget.endVal / 2 + data[widget.id]);
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _value = widget.endVal / 2 + data[widget.id];
    });
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
            Text(
              widget.inputType,
              style: const TextStyle(fontSize: 17),
            ),
            Text(_value.toInt().toString()),
            IconButton(
                onPressed: () {
                  setState(() {
                    _value = widget.endVal / 2;
                    data[widget.id] = 0.0;
                  });
                  widget.id == "roll"
                      ? Provider.of<TrimData>(context, listen: false)
                          .updateRollTrim(data["roll"])
                      : Provider.of<TrimData>(context, listen: false)
                          .updatePitchTrim(data["pitch"]);
                },
                icon: const Icon(Icons.restart_alt))
          ],
        ),
        Slider(
          min: 0,
          max: widget.endVal,
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
              data[widget.id] = value - widget.endVal / 2;
            });

            widget.id == "roll"
                ? Provider.of<TrimData>(context, listen: false)
                    .updateRollTrim(data["roll"])
                : Provider.of<TrimData>(context, listen: false)
                    .updatePitchTrim(data["pitch"]);
          },
        ),
      ]),
    );
  }
}
