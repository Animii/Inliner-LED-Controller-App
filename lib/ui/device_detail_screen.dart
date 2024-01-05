import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';
import 'package:inlinerapp/storage/storage_device.dart';
import 'package:inlinerapp/ui/animation/screen/animation_list_screen.dart';
import 'package:inlinerapp/ui/device_interaction_tab.dart';
import 'package:provider/provider.dart';

class DeviceDetailScreen extends StatelessWidget {
  final StorageDevice device;

  const DeviceDetailScreen({required this.device, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer2<BleDeviceConnector, ConnectionStateUpdate>(
        builder: (_, deviceConnector, connectionStream, __) => _DeviceDetail(
          device: device,
          deviceConnector: deviceConnector,
          connectionStream: connectionStream,
          disconnect: deviceConnector.disconnect,
        ),
      );
}

class _DeviceDetail extends StatefulWidget {
  final StorageDevice device;
  final void Function(String deviceId) disconnect;
  final ConnectionStateUpdate connectionStream;
  final BleDeviceConnector deviceConnector;
  const _DeviceDetail({
    required this.device,
    required this.deviceConnector,
    required this.disconnect,
    required this.connectionStream,
    Key? key,
  }) : super(key: key);

  @override
  _DeviceDetailState createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<_DeviceDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildConnectingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildConnectedState() {
    return DeviceInteractionScreen(device: widget.device);
  }

  Widget _buildConnectionState() {
    switch (widget.connectionStream.connectionState) {
      case DeviceConnectionState.connected:
        return _buildConnectedState();
      case DeviceConnectionState.disconnected:
      default:
        return _buildConnectingState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //widget.disconnect(widget.device.id);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnimationList(),
                      ));
                },
                icon: const Icon(Icons.logo_dev))
          ],
          title: Text(
            widget.device.name.isNotEmpty ? widget.device.name : "Unnamed",
          ),
        ),
        body: _buildConnectionState(),
      ),
    );
  }
}
