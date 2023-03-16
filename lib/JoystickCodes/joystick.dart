import 'dart:async';

import 'package:drone_controller/JoystickCodes/joystic_controller.dart';
import 'package:flutter/material.dart';

import 'joystick_base.dart';
import 'joystick_stick.dart';
import 'joystick_stick_offset_calculator.dart';

/// Joystick widget
class Joystick extends StatefulWidget {
  /// Callback, which is called with [period] frequency when the stick is dragged.
  final StickDragCallback listener;

  /// Frequency of calling [listener] from the moment the stick is dragged, by default 100 milliseconds.
  final Duration period;

  /// Widget that renders joystick base, by default [JoystickBase].
  final Widget? base;

  /// Widget that renders joystick stick, it places in the center of [base] widget, by default [JoystickStick].
  final Widget stick;

  /// Controller allows to control joystick events outside the widget.
  final JoystickController? controller;

  /// Possible directions mode of the joystick stick, by default [JoystickMode.all]
  final JoystickMode mode;

  /// Calculate offset of the stick based on the stick drag start position and the current stick position.
  final StickOffsetCalculator stickOffsetCalculator;

  /// Callback, which is called when the stick starts dragging.
  final Function? onStickDragStart;

  /// Callback, which is called when the stick released.
  final Function? onStickDragEnd;

  final bool isThrottle;

  const Joystick({
    Key? key,
    required this.listener,
    this.period = const Duration(milliseconds: 100),
    this.base,
    this.stick = const JoystickStick(),
    this.mode = JoystickMode.all,
    this.stickOffsetCalculator = const CircleStickOffsetCalculator(),
    this.controller,
    this.onStickDragStart,
    this.onStickDragEnd,
    required this.isThrottle,
  }) : super(key: key);

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  final GlobalKey _baseKey = GlobalKey();
  Offset lastGlobal = Offset.zero;
  Offset _stickOffset = Offset.zero;
  Timer? _callbackTimer;
  Offset _startDragStickPosition = Offset.zero;
  Offset renderArea = Offset.zero;

  @override
  void initState() {
    super.initState();
    _stickOffset = widget.isThrottle ? const Offset(0.0, 1.0) : Offset.zero;
    _startDragStickPosition = Offset.zero;

    widget.controller?.onStickDragStart =
        (globalPosition) => _stickDragStart(globalPosition);
    widget.controller?.onStickDragUpdate =
        (globalPosition) => _stickDragUpdate(globalPosition);
    widget.controller?.onStickDragEnd = () => _stickDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(_stickOffset.dx, _stickOffset.dy),
      children: [
        Container(
          key: _baseKey,
          child: widget.base ?? JoystickBase(mode: widget.mode),
        ),
        GestureDetector(
          onPanStart: (details) => _stickDragStart(details.globalPosition),
          onPanUpdate: (details) => _stickDragUpdate(details.globalPosition),
          onPanEnd: (details) => _stickDragEnd(),
          child: widget.stick,
        ),
      ],
    );
  }

  void _stickDragStart(Offset globalPosition) {
    _runCallback();
    _startDragStickPosition = globalPosition;
    //widget.onStickDragStart?.call();
  }

  void _stickDragUpdate(Offset globalPosition) {
    final baseRenderBox =
        _baseKey.currentContext!.findRenderObject()! as RenderBox;

    setState(() {
      renderArea = baseRenderBox.localToGlobal(
          Offset(baseRenderBox.size.width / 2, baseRenderBox.size.height / 2));
    });

    final stickOffset = widget.stickOffsetCalculator.calculate(
      mode: widget.mode,
      startDragStickPosition: widget.isThrottle
          ? Offset(_startDragStickPosition.dx, renderArea.dy)
          : _startDragStickPosition,
      currentDragStickPosition: globalPosition,
      baseSize: baseRenderBox.size,
      stickOffset: _stickOffset,
    );

    setState(() {
      _stickOffset = stickOffset;
    });
  }

  void _stickDragEnd() {
    if (widget.isThrottle) {
      setState(() {
        _stickOffset = Offset(0.0, _stickOffset.dy);
      });

      _callbackTimer?.cancel();
      //send zero offset only for YAW stick
      widget.listener(StickDragDetails(_stickOffset.dx, _stickOffset.dy));
      _startDragStickPosition = Offset.zero;
      //widget.onStickDragEnd?.call();
    } else {
      setState(() {
        _stickOffset = Offset.zero;
      });
      _callbackTimer?.cancel();
      //send zero offset when the stick is released
      widget.listener(StickDragDetails(_stickOffset.dx, _stickOffset.dy));
      _startDragStickPosition = Offset.zero;
      //widget.onStickDragEnd?.call();
    }
  }

  void _runCallback() {
    _callbackTimer = Timer.periodic(widget.period, (timer) {
      widget.listener(StickDragDetails(_stickOffset.dx, _stickOffset.dy));
    });
  }

  @override
  void dispose() {
    _callbackTimer?.cancel();
    super.dispose();
  }
}

typedef StickDragCallback = void Function(StickDragDetails details);

/// Contains the stick offset from the center of the base.
class StickDragDetails {
  /// x - the stick offset in the horizontal direction. Can be from -1.0 to +1.0.
  final double x;

  /// y - the stick offset in the vertical direction. Can be from -1.0 to +1.0.
  final double y;

  StickDragDetails(this.x, this.y);
}

/// Possible directions of the joystick stick.
enum JoystickMode {
  /// allow move the stick in any direction: vertical, horizontal and diagonal.
  all,

  /// allow move the stick only in vertical direction.
  vertical,

  /// allow move the stick only in horizontal direction.
  horizontal,

  /// allow move the stick only in horizontal and vertical directions, not diagonal.
  horizontalAndVertical,
}
