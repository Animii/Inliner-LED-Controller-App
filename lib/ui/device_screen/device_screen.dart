import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';
import 'package:inlinerapp/storage/storage.dart';
import 'package:inlinerapp/storage/storage_device.dart';
import 'package:inlinerapp/ui/device_detail_screen.dart';
import 'package:inlinerapp/ui/device_list_screen.dart';
import 'package:provider/provider.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer2<Storage, BleDeviceConnector>(
        builder: (_, storage, bleDeviceConnector, __) => _DeviceScreen(
          storage: storage,
          bleDeviceConnector: bleDeviceConnector,
        ),
      );
}

class _DeviceScreen extends StatefulWidget {
  final Storage storage;
  final BleDeviceConnector bleDeviceConnector;

  const _DeviceScreen(
      {required this.storage, required this.bleDeviceConnector});

  @override
  State<_DeviceScreen> createState() {
    return _DeviceScreenState();
  }
}

class _DeviceScreenState extends State<_DeviceScreen> {
  List<StorageDevice> devices = List.empty();
  @override
  void initState() {
    super.initState();
    loadDevices();
  }

  void loadDevices() async {
    devices = widget.storage.loadDeviceList();
    setState(() {}); // Call setState to trigger a rebuild of the widget.
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openAddDeviceScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceListScreen()),
    );
  }

  void _openDeviceInteractionScreen(StorageDevice storageDevice) {
    widget.bleDeviceConnector.connect(storageDevice.id);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DeviceDetailScreen(
                device: storageDevice,
              )),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                widget.storage.saveDeviceList(List.empty());
              },
              icon: const Icon(Icons.remove)),
          IconButton(
              onPressed: () {
                _openAddDeviceScreen();
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          Flexible(
              child: ListView(
            children: [
              ...devices
                  .map((device) => _StorageDeviceListTile(
                        device: device,
                        onTab: _openDeviceInteractionScreen,
                      ))
                  .toList(),
            ],
          )),
        ],
      ));
}

class _StorageDeviceListTile extends StatelessWidget {
  const _StorageDeviceListTile({required this.device, required this.onTab});

  final StorageDevice device;
  final Function(StorageDevice) onTab;

  Image _loadImage() {
    return const Image(image: AssetImage('assets/img/inline_skates.png'));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          device.name.isNotEmpty ? device.name : "Unnamed",
        ),
        leading: _loadImage(),
        subtitle: Text(
          """
${device.name}
        """,
        ),
        trailing: SyncSwitch(deviceId: device.id),
        onTap: () {
          onTab(device);
        },
      ),
    );
  }
}

class SyncSwitch extends StatefulWidget {
  final String deviceId;

  const SyncSwitch({super.key, required this.deviceId});
  @override
  State<StatefulWidget> createState() {
    return _SyncSwitchState();
  }
}

class _SyncSwitchState extends State<SyncSwitch> {
  bool isSyncEnabled = false; // To manage the state of the switch
  @override
  Widget build(BuildContext context) {
    return Consumer2<BleDeviceConnector, ConnectionStateUpdate>(
      builder: (context, bleDeviceConnector, connectionState, child) => Switch(
        value: bleDeviceConnector.devices[widget.deviceId]?.connectionState ==
            DeviceConnectionState.connected,
        onChanged: (value) {
          // Handle the sync functionality here...
          if (value) {
            bleDeviceConnector.connect(widget.deviceId);
          } else {
            bleDeviceConnector.disconnect(widget.deviceId);
          }
        },
      ),
    );
  }
}
