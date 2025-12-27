import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"name":"Manikandan","phone":"12345555","email":"123@gmail.com","address":"road","locationId":"6878e0589f3b224c9a2d6377","createdBy":"68874a73138aa2dcca66347c","_id":"694ebd1e03766a6135e066a0","createdAt":"2025-12-26T16:51:42.666Z","updatedAt":"2025-12-26T16:51:42.666Z","__v":0}

PostCustomerModel postCustomerModelFromJson(String str) => PostCustomerModel.fromJson(json.decode(str));
String postCustomerModelToJson(PostCustomerModel data) => json.encode(data.toJson());

class PostCustomerModel {
  PostCustomerModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse, // Added
  }){
    _success = success;
    _data = data;
    this.errorResponse = errorResponse;
  }

  PostCustomerModel.fromJson(dynamic json) {
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

  PostCustomerModel copyWith({  bool? success,
    Data? data,
    ErrorResponse? errorResponse, // Added
  }) => PostCustomerModel(
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
    String? name,
    String? phone,
    String? email,
    String? address,
    String? locationId,
    String? createdBy,
    String? id,
    String? createdAt,
    String? updatedAt,
    num? v,}){
    _name = name;
    _phone = phone;
    _email = email;
    _address = address;
    _locationId = locationId;
    _createdBy = createdBy;
    _id = id;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Data.fromJson(dynamic json) {
    _name = json['name'];
    _phone = json['phone'];
    _email = json['email'];
    _address = json['address'];
    _locationId = json['locationId'];
    _createdBy = json['createdBy'];
    _id = json['_id']; // Correctly mapping _id
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v']; // Correctly mapping __v
  }

  String? _name;
  String? _phone;
  String? _email;
  String? _address;
  String? _locationId;
  String? _createdBy;
  String? _id;
  String? _createdAt;
  String? _updatedAt;
  num? _v;

  Data copyWith({  String? name,
    String? phone,
    String? email,
    String? address,
    String? locationId,
    String? createdBy,
    String? id,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) => Data(
    name: name ?? _name,
    phone: phone ?? _phone,
    email: email ?? _email,
    address: address ?? _address,
    locationId: locationId ?? _locationId,
    createdBy: createdBy ?? _createdBy,
    id: id ?? _id,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
    v: v ?? _v,
  );

  String? get name => _name;
  String? get phone => _phone;
  String? get email => _email;
  String? get address => _address;
  String? get locationId => _locationId;
  String? get createdBy => _createdBy;
  String? get id => _id;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['phone'] = _phone;
    map['email'] = _email;
    map['address'] = _address;
    map['locationId'] = _locationId;
    map['createdBy'] = _createdBy;
    map['_id'] = _id;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}