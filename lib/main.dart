import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inlinerapp/animation/animation_provider.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';
import 'package:inlinerapp/ble/ble_device_interactor.dart';
import 'package:inlinerapp/ble/ble_logger.dart';
import 'package:inlinerapp/ble/ble_scanner.dart';
import 'package:inlinerapp/ble/ble_status_monitor.dart';
import 'package:inlinerapp/ble_status_screen.dart';
import 'package:inlinerapp/color_schemes.g.dart';
import 'package:inlinerapp/storage/storage.dart';
import 'package:inlinerapp/ui/animation/screen/animation_list_screen.dart';
import 'package:inlinerapp/ui/device_brightnes_slider.dart';
import 'package:inlinerapp/ui/device_screen/device_screen.dart';
import 'package:permission_handler/permission_handler.dart';

final flutterReactiveBle = FlutterReactiveBle();
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ble = FlutterReactiveBle();
  final bleLogger = BleLogger(ble: ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final monitor = BleStatusMonitor(ble);
  final connector = BleDeviceConnector(
    ble: ble,
    logMessage: bleLogger.addToLog,
  );
  final serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: (deviceId) async {
      //await ble.discoverAllServices(deviceId);
      return ble.getDiscoveredServices(deviceId);
    },
    logMessage: bleLogger.addToLog,
  );
  final storage = Storage();
  final animationProvider = AnimationProvider();

  storage.loadAnimations().forEach((element) {
    animationProvider.createAnimation(element);
  });
  animationProvider.addListener(
    () {
      storage.saveAnimations(animationProvider.animations);
    },
  );

  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Flutter Reactive BLE example',
        theme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        home: const HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(
        builder: (_, status, __) {
          _requestBluetoothPermission();
          if (status == BleStatus.ready) {
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: const Row(children: [
                    Text("Home"),
                    Expanded(child: DeviceBrightnessSlider())
                  ]),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: "Animation"),
                      Tab(text: "Devices"),
                    ],
                  ),
                ),
                body: const TabBarView(
                  children: [
                    AnimationList(),
                    DeviceScreen(),
                  ],
                ),
              ),
            );
          } else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}

Future<void> _requestBluetoothPermission() async {
  if (await Permission.bluetooth.isDenied) {
    await Permission.bluetooth.request();
  }
  if (await Permission.location.isDenied) {
    await Permission.location.request();
  }
  if (await Permission.bluetoothAdvertise.isDenied) {
    await Permission.bluetoothAdvertise.request();
  }
  if (await Permission.bluetoothConnect.isDenied) {
    await Permission.bluetoothConnect.request();
  }
  if (await Permission.bluetoothScan.isDenied) {
    await Permission.bluetoothScan.request();
  }
  if (await Permission.locationAlways.isDenied) {
    await Permission.locationAlways.request();
  }
  if (await Permission.locationWhenInUse.isDenied) {
    await Permission.locationWhenInUse.request();
  }
}
