import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimePicker extends StatefulWidget {
  final Duration initialTimer;
  final Function(Duration) onTimeChanged;

  TimePicker(
      {Key? key, required this.initialTimer, required this.onTimeChanged})
      : super(key: key);

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          pickerTextStyle:
              GoogleFonts.poppins(fontSize: 16, color: Colors.black),
        ),
      ),
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: CupertinoTimerPicker(
          
          mode: CupertinoTimerPickerMode.hm,
          minuteInterval: 15,
          initialTimerDuration: widget.initialTimer,
          onTimerDurationChanged:
              widget.onTimeChanged, // Use the passed callback
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
