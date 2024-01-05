abstract class _Saveable {
  toJSONEncodable();
}

abstract class SaveableEntity extends _Saveable {
  @override
  Map<String, dynamic> toJSONEncodable();
}

abstract class SaveableList extends _Saveable {
  @override
  List<Map<String, dynamic>> toJSONEncodable();
}
