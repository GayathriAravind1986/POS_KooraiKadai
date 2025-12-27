import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : [{"_id":"68948d6d09d7856330f9b1e5","name":"Salary","description":"","locationId":{"_id":"68903a7bf7a56be2b7654f2f","name":"NAGERCOIL"},"createdBy":"6890315266eb7a8181a3b4b4","isDefault":true,"createdAt":"2025-08-07T11:26:37.665Z","updatedAt":"2025-08-07T11:26:37.665Z","__v":0}]
/// totalCount : 1

class GetCategoryByLocationModel {
  GetCategoryByLocationModel({
    bool? success,
    List<Data>? data,
    num? totalCount,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
    _totalCount = totalCount;
  }

  GetCategoryByLocationModel.fromJson(dynamic json) {
    _success = json['success'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
    _totalCount = json['totalCount'];
  }
  bool? _success;
  List<Data>? _data;
  num? _totalCount;
  ErrorResponse? errorResponse;
  GetCategoryByLocationModel copyWith({
    bool? success,
    List<Data>? data,
    num? totalCount,
  }) =>
      GetCategoryByLocationModel(
        success: success ?? _success,
        data: data ?? _data,
        totalCount: totalCount ?? _totalCount,
      );
  bool? get success => _success;
  List<Data>? get data => _data;
  num? get totalCount => _totalCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    if (errorResponse != null) {
      map['errors'] = errorResponse!.toJson();
    }
    map['totalCount'] = _totalCount;
    return map;
  }
}

/// _id : "68948d6d09d7856330f9b1e5"
/// name : "Salary"
/// description : ""
/// locationId : {"_id":"68903a7bf7a56be2b7654f2f","name":"NAGERCOIL"}
/// createdBy : "6890315266eb7a8181a3b4b4"
/// isDefault : true
/// createdAt : "2025-08-07T11:26:37.665Z"
/// updatedAt : "2025-08-07T11:26:37.665Z"
/// __v : 0

/// _id : "692552bf947ed9543e5a3744"
/// name : "vadai"
/// description : "hi"
/// locationId : {"_id":"6890d1700eb176a5bfc48b2a","name":"Tenkasi"}
/// createdBy : "6878971f0bc550868fe1b34b"
/// isDefault : true
/// createdAt : "2025-11-25T06:54:56.016Z"
/// updatedAt : "2025-11-25T06:54:56.016Z"
/// __v : 0

class Data {
  Data({
    String? id,
    String? name,
    String? description,
    LocationId? locationId,
    String? createdBy,
    bool? isDefault,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _name = name;
    _description = description;
    _locationId = locationId;
    _createdBy = createdBy;
    _isDefault = isDefault;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _description = json['description'];
    _locationId = json['locationId'] != null
        ? LocationId.fromJson(json['locationId'])
        : null;
    _createdBy = json['createdBy'];
    _isDefault = json['isDefault'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _name;
  String? _description;
  LocationId? _locationId;
  String? _createdBy;
  bool? _isDefault;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Data copyWith({
    String? id,
    String? name,
    String? description,
    LocationId? locationId,
    String? createdBy,
    bool? isDefault,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      Data(
        id: id ?? _id,
        name: name ?? _name,
        description: description ?? _description,
        locationId: locationId ?? _locationId,
        createdBy: createdBy ?? _createdBy,
        isDefault: isDefault ?? _isDefault,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  String? get id => _id;
  String? get name => _name;
  String? get description => _description;
  LocationId? get locationId => _locationId;
  String? get createdBy => _createdBy;
  bool? get isDefault => _isDefault;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['description'] = _description;
    if (_locationId != null) {
      map['locationId'] = _locationId?.toJson();
    }
    map['createdBy'] = _createdBy;
    map['isDefault'] = _isDefault;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// _id : "6890d1700eb176a5bfc48b2a"
/// name : "Tenkasi"

class LocationId {
  LocationId({
    String? id,
    String? name,
  }) {
    _id = id;
    _name = name;
  }

  LocationId.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
  }
  String? _id;
  String? _name;
  LocationId copyWith({
    String? id,
    String? name,
  }) =>
      LocationId(
        id: id ?? _id,
        name: name ?? _name,
      );
  String? get id => _id;
  String? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    return map;
  }
}
