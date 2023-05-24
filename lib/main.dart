import 'package:drone_controller/screens/controller_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(const MyApp());
  });
}

const ballSize = 20.0;
const step = 30.0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TrimData>(
      create: (context) => TrimData(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PyiTech',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const ControllerScreen()),
    );
  }
}

class TrimData extends ChangeNotifier {
  Map trimData = {"roll": 0.0, "pitch": 0.0};
  int endValue = 100;

  void updateTrims(input) {
    trimData = input;
    notifyListeners();
  }

  void updateRollTrim(input) {
    trimData["roll"] = input;
    notifyListeners();
  }

  void updatePitchTrim(input) {
    trimData["pitch"] = input;
    notifyListeners();
  }

  void updateEndValue(input) {
    endValue = input.toInt();
    notifyListeners();
  }
}
