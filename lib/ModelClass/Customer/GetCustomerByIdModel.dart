import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"_id":"694520d7e3980a538593c36a","name":"alia","phone":"12345555","address":"road","locationId":{"_id":"6878e0589f3b224c9a2d6377","name":"sample"},"createdBy":{"_id":"6878971f0bc550868fe1b34b","name":"Saranya"},"createdAt":"2025-12-19T09:54:31.514Z","updatedAt":"2025-12-26T07:26:38.807Z","__v":0,"email":"123@gmail.com"}

GetCustomerByIdModel getCustomerByIdModelFromJson(String str) =>
    GetCustomerByIdModel.fromJson(json.decode(str));
String getCustomerByIdModelToJson(GetCustomerByIdModel data) =>
    json.encode(data.toJson());

class GetCustomerByIdModel {
  GetCustomerByIdModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
    this.errorResponse = errorResponse;
  }

  GetCustomerByIdModel.fromJson(dynamic json) {
    _success = json['success'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }

  bool? _success;
  Data? _data;
  ErrorResponse? errorResponse;

  GetCustomerByIdModel copyWith({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
  }) =>
      GetCustomerByIdModel(
        success: success ?? _success,
        data: data ?? _data,
        errorResponse: errorResponse ?? this.errorResponse,
      );

  bool? get success => _success;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    if (errorResponse != null) {
      map['errors'] = errorResponse!.toJson();
    }
    return map;
  }
}

/// _id : "694520d7e3980a538593c36a"
/// name : "alia"
/// phone : "12345555"
/// address : "road"
/// locationId : {"_id":"6878e0589f3b224c9a2d6377","name":"sample"}
/// createdBy : {"_id":"6878971f0bc550868fe1b34b","name":"Saranya"}
/// createdAt : "2025-12-19T09:54:31.514Z"
/// updatedAt : "2025-12-26T07:26:38.807Z"
/// __v : 0
/// email : "123@gmail.com"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    String? id,
    String? name,
    String? phone,
    String? address,
    LocationId? locationId,
    CreatedBy? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
    String? email,
  }) {
    _id = id;
    _name = name;
    _phone = phone;
    _address = address;
    _locationId = locationId;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
    _email = email;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _phone = json['phone'];
    _address = json['address'];
    _locationId = json['locationId'] != null
        ? LocationId.fromJson(json['locationId'])
        : null;
    _createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy'])
        : null;
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
    _email = json['email'];
  }
  String? _id;
  String? _name;
  String? _phone;
  String? _address;
  LocationId? _locationId;
  CreatedBy? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  String? _email;
  Data copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    LocationId? locationId,
    CreatedBy? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
    String? email,
  }) =>
      Data(
        id: id ?? _id,
        name: name ?? _name,
        phone: phone ?? _phone,
        address: address ?? _address,
        locationId: locationId ?? _locationId,
        createdBy: createdBy ?? _createdBy,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
        email: email ?? _email,
      );
  String? get id => _id;
  String? get name => _name;
  String? get phone => _phone;
  String? get address => _address;
  LocationId? get locationId => _locationId;
  CreatedBy? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;
  String? get email => _email;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['phone'] = _phone;
    map['address'] = _address;
    if (_locationId != null) {
      map['locationId'] = _locationId?.toJson();
    }
    if (_createdBy != null) {
      map['createdBy'] = _createdBy?.toJson();
    }
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    map['email'] = _email;
    return map;
  }
}

/// _id : "6878971f0bc550868fe1b34b"
/// name : "Saranya"

CreatedBy createdByFromJson(String str) => CreatedBy.fromJson(json.decode(str));
String createdByToJson(CreatedBy data) => json.encode(data.toJson());

class CreatedBy {
  CreatedBy({
    String? id,
    String? name,
  }) {
    _id = id;
    _name = name;
  }

  CreatedBy.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
  }
  String? _id;
  String? _name;
  CreatedBy copyWith({
    String? id,
    String? name,
  }) =>
      CreatedBy(
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

/// _id : "6878e0589f3b224c9a2d6377"
/// name : "sample"

LocationId locationIdFromJson(String str) =>
    LocationId.fromJson(json.decode(str));
String locationIdToJson(LocationId data) => json.encode(data.toJson());

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