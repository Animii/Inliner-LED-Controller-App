import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:inlinerapp/ble/ble_logger.dart';
import 'package:inlinerapp/ble/ble_scanner.dart';
import 'package:inlinerapp/storage/storage.dart';
import 'package:inlinerapp/storage/storage_device.dart';
import 'package:inlinerapp/widgets.dart';
import 'package:provider/provider.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer4<BleScanner, BleScannerState?, BleLogger, Storage>(
        builder: (_, bleScanner, bleScannerState, bleLogger, storage, __) =>
            _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          toggleVerboseLogging: bleLogger.toggleVerboseLogging,
          verboseLogging: bleLogger.verboseLogging,
          storage: storage,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList(
      {required this.scannerState,
      required this.startScan,
      required this.stopScan,
      required this.toggleVerboseLogging,
      required this.verboseLogging,
      required this.storage});

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final VoidCallback toggleVerboseLogging;
  final bool verboseLogging;
  final Storage storage;
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  @override
  void initState() {
    _startScanning();
    super.initState();
  }

  @override
  void dispose() {
    widget.stopScan();
    super.dispose();
  }

  void _startScanning() {
    widget.startScan([]);
  }

  void _saveDevice(DiscoveredDevice device) {
    List<StorageDevice> devices = widget.storage.loadDeviceList();
    devices.add(StorageDevice(name: device.name, id: device.id));
    widget.storage.saveDeviceList(devices);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan for devices'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: !widget.scannerState.scanIsInProgress
                            ? _startScanning
                            : null,
                        child: const Text('Scan'),
                      ),
                      ElevatedButton(
                        onPressed: widget.scannerState.scanIsInProgress
                            ? widget.stopScan
                            : null,
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                children: [
                  SwitchListTile(
                    title: const Text("Verbose logging"),
                    value: widget.verboseLogging,
                    onChanged: (_) => setState(widget.toggleVerboseLogging),
                  ),
                  ListTile(
                    title: Text(
                      !widget.scannerState.scanIsInProgress
                          ? 'Enter a UUID above and tap start to begin scanning'
                          : 'Tap a device to connect to it',
                    ),
                    trailing: (widget.scannerState.scanIsInProgress ||
                            widget.scannerState.discoveredDevices.isNotEmpty)
                        ? Text(
                            'count: ${widget.scannerState.discoveredDevices.length}',
                          )
                        : null,
                  ),
                  ...widget.scannerState.discoveredDevices
                      .map(
                        (device) => _DeviceListTile(
                          stopScan: widget.stopScan,
                          device: device,
                          saveDevice: _saveDevice,
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DeviceListTile extends StatelessWidget {
  const _DeviceListTile(
      {required this.stopScan, required this.device, required this.saveDevice});

  final VoidCallback stopScan;
  final DiscoveredDevice device;
  final void Function(DiscoveredDevice) saveDevice;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        device.name.isNotEmpty ? device.name : "Unnamed",
      ),
      subtitle: Text(
        """
${device.id}
RSSI: ${device.rssi}
${device.connectable}
        """,
      ),
      leading: const BluetoothIcon(),
      onTap: () async {
        stopScan();
        saveDevice(device);
        Navigator.pop(context);
      },
    );
  }
}
