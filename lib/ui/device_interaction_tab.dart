import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';
import 'package:inlinerapp/ble/ble_device_interactor.dart';
import 'package:inlinerapp/storage/storage_device.dart';
import 'package:inlinerapp/ui/device_animation_selection.dart';
import 'package:inlinerapp/ui/device_brightnes_slider.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

class DeviceInteractionScreen extends StatelessWidget {
  const DeviceInteractionScreen({
    required this.device,
    Key? key,
  }) : super(key: key);

  final StorageDevice device;

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleDeviceConnector, ConnectionStateUpdate, BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
                __) =>
            _DeviceInteractionTab(
          viewModel: DeviceInteractionViewModel(
            deviceId: device.id,
            connectionStatus: connectionStateUpdate.connectionState,
            deviceConnector: deviceConnector,
            discoverServices: () =>
                serviceDiscoverer.discoverServices(device.id),
          ),
        ),
      );
}

class DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
  });

  final String deviceId;
  final DeviceConnectionState connectionStatus;
  final BleDeviceConnector deviceConnector;
  final Future<List<Service>> Function() discoverServices;

  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    //deviceConnector.disconnect(deviceId);
  }
}

class _DeviceInteractionTab extends StatefulWidget {
  const _DeviceInteractionTab({
    required this.viewModel,
    Key? key,
  }) : super(key: key);

  final DeviceInteractionViewModel viewModel;

  @override
  _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
}

class _DeviceInteractionTabState extends State<_DeviceInteractionTab> {
  late List<Service> discoveredServices;
  late DeviceConnectionState connectionState;

  late AnimationControllerBleService _animationControllerService;
  bool foundAnimationControllerService = false;

  @override
  void initState() {
    if (!widget.viewModel.deviceConnected) {
      widget.viewModel.connect();
    }

    discoverServices();

    super.initState();
  }

  Future<void> discoverServices() async {
    final result = await widget.viewModel.discoverServices();
    setState(() {
      setServices(result);
    });
  }

  Future<void> setServices(List<Service> discoveredServices) async {
    Service? service = discoveredServices.firstWhereOrNull((element) =>
        element.id == Uuid.parse("000000ff-0000-1000-8000-00805f9b34fb"));
    if (service == null) return;
    setState(() {
      discoveredServices = discoveredServices;
      _animationControllerService =
          AnimationControllerBleService(service: service);
      foundAnimationControllerService = true;
    });
  }

  Widget _buildSilder() {
    Characteristic? characteristic =
        _animationControllerService.getBrightnessCharacteristic();

    if (characteristic == null) return Container();

    return const DeviceBrightnessSlider();
  }

  Widget _buildAnimationSelection() {
    Characteristic? animationConfigCharacteristic =
        _animationControllerService.getAnimationConfigCharacteristic();
    Characteristic? currentAnimationCharacteristic =
        _animationControllerService.getCurrentAnimationIndexCharacteristic();
    if (animationConfigCharacteristic == null ||
        currentAnimationCharacteristic == null) return Container();

    return DeviceAnimationSelection(
        animationConfigCharacteristic: animationConfigCharacteristic,
        currentAnimationCharacteristic: currentAnimationCharacteristic);
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                if (widget.viewModel.deviceConnected &&
                    foundAnimationControllerService)
                  _buildSilder(),
                if (widget.viewModel.deviceConnected &&
                    foundAnimationControllerService)
                  _buildAnimationSelection(),
              ],
            ),
          ),
        ],
      );
}

class AnimationControllerBleService {
  final Service service;
  final Uuid _brightnessCharacteristicID =
      Uuid.parse("0000ff04-0000-1000-8000-00805f9b34fb");
  final Uuid _currentAnimationStateCharacteristicID =
      Uuid.parse("0000ff03-0000-1000-8000-00805f9b34fb");
  final Uuid _currentAnimationIndexCharacteristicID =
      Uuid.parse("0000ff02-0000-1000-8000-00805f9b34fb");
  final Uuid _animationConfigCharacteristicID =
      Uuid.parse("0000ff05-0000-1000-8000-00805f9b34fb");
  AnimationControllerBleService({required this.service});

  Characteristic? getBrightnessCharacteristic() {
    return service.characteristics.firstWhereOrNull(
        (element) => element.id == _brightnessCharacteristicID);
  }

  Characteristic? getCurrentAnimationIndexCharacteristic() {
    return service.characteristics.firstWhereOrNull(
        (element) => element.id == _currentAnimationIndexCharacteristicID);
  }

  Characteristic? getCurrentAnimationStateCharacteristic() {
    return service.characteristics.firstWhereOrNull(
        (element) => element.id == _currentAnimationStateCharacteristicID);
  }

  Characteristic? getAnimationConfigCharacteristic() {
    return service.characteristics.firstWhereOrNull(
        (element) => element.id == _animationConfigCharacteristicID);
  }
}
