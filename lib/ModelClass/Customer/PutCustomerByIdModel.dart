import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"_id":"694520d7e3980a538593c36a","name":"alia","phone":"12345555","address":"road","locationId":"6878e0589f3b224c9a2d6377","createdBy":"6878971f0bc550868fe1b34b","createdAt":"2025-12-19T09:54:31.514Z","updatedAt":"2025-12-26T16:39:34.220Z","__v":0,"email":"123@gmail.com"}

PutCustomerByIdModel putCustomerByIdModelFromJson(String str) => PutCustomerByIdModel.fromJson(json.decode(str));
String putCustomerByIdModelToJson(PutCustomerByIdModel data) => json.encode(data.toJson());

class PutCustomerByIdModel {
  PutCustomerByIdModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse, // Added
  }){
    _success = success;
    _data = data;
    this.errorResponse = errorResponse;
  }

  PutCustomerByIdModel.fromJson(dynamic json) {
    _success = json['success'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;

    // Error Handling logic
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }

  bool? _success;
  Data? _data;
  ErrorResponse? errorResponse; // Added

  PutCustomerByIdModel copyWith({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse, // Added
  }) => PutCustomerByIdModel(
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

class Data {
  Data({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? locationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
    String? email,}){
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
    _locationId = json['locationId'];
    _createdBy = json['createdBy'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
    _email = json['email'];
  }

  String? _id;
  String? _name;
  String? _phone;
  String? _address;
  String? _locationId;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  String? _email;

  Data copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? locationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
    String? email,
  }) => Data(
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
  String? get locationId => _locationId;
  String? get createdBy => _createdBy;
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
    map['locationId'] = _locationId;
    map['createdBy'] = _createdBy;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    map['email'] = _email;
    return map;
  }
}