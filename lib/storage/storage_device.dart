import 'package:inlinerapp/storage/storage_saveable.dart';

class StorageDevice implements SaveableEntity {
  final String name;
  final String id;

  StorageDevice({required this.name, required this.id});

  StorageDevice.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        id = json["id"];

  @override
  Map<String, dynamic> toJSONEncodable() {
    Map<String, dynamic> map = {};

    map['name'] = name;
    map['id'] = id;

    return map;
  }
}

class StorageDeviceList implements SaveableList {
  List<StorageDevice> devices = List.empty(growable: true);

  StorageDeviceList({required this.devices});

  StorageDeviceList.fromJson(List<dynamic> json) {
    devices = List<StorageDevice>.from(
        (json).map((item) => StorageDevice.fromJson(item)));
  }

  StorageDeviceList.empty();

  @override
  List<Map<String, dynamic>> toJSONEncodable() {
    return devices.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}
