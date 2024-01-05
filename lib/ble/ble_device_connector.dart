import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:inlinerapp/ble/ble_device_model.dart';
import 'package:inlinerapp/ble/reactive_state.dart';

class BleDeviceConnector extends ReactiveState<ConnectionStateUpdate> {
  BleDeviceConnector({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;
  final Map<String, BleDeviceModel> _devices = {};
  Map<String, BleDeviceModel> get devices => _devices;

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  final Map<String, StreamSubscription<ConnectionStateUpdate>> _connections =
      {};

  Future<void> connect(String deviceId) async {
    if (devices.containsKey(deviceId)) return;
    _logMessage('Start connecting to $deviceId');
    await disconnect(deviceId);

    _connections[deviceId] = _ble
        .connectToDevice(
            id: deviceId, connectionTimeout: const Duration(seconds: 10))
        .listen(
      (update) async {
        switch (update.connectionState) {
          case DeviceConnectionState.connected:
            await _ble.discoverAllServices(update.deviceId);
            var services = await _ble.getDiscoveredServices(deviceId);
            int mtuSize = await _ble.requestMtu(deviceId: deviceId, mtu: 200);
            _devices[deviceId] = BleDeviceModel(
                ble: _ble,
                connectionState: update.connectionState,
                deviceId: update.deviceId,
                services: services,
                mtuSize: mtuSize);
            break;
          case DeviceConnectionState.disconnected:
            await disconnect(deviceId);
          default:
        }

        _logMessage(
            'ConnectionState for device $deviceId : ${update.connectionState}');
        _deviceConnectionController.add(update);
      },
      onError: (Object e) =>
          _logMessage('Connecting to device $deviceId resulted in error $e'),
    );
  }

  Future<void> disconnect(String deviceId) async {
    _logMessage('Disconnecting from device: $deviceId');
    try {
      await _connections[deviceId]?.cancel();
      _devices[deviceId]?.dispose();
      _devices.remove(deviceId);
      _connections.remove(deviceId);
    } on Exception catch (e, _) {
      _logMessage("Error disconnecting from a device: $e");
    } finally {
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }

  Future<void> dispose() async {
    for (var connection in _connections.values) {
      await connection.cancel();
    }
    await _deviceConnectionController.close();
  }
}
