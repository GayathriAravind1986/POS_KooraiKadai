import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : [{"id":"694e36fe1d157e1ae77390eb","name":"hari","phone":"8989898978","address":"","email":"","location":{"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"createdBy":"Saranya","createdAt":"2025-12-26","updatedAt":"2025-12-26T07:19:26.845Z"}]
/// total : 16

GetCustomerModel getCustomerModelFromJson(String str) =>
    GetCustomerModel.fromJson(json.decode(str));
String getCustomerModelToJson(GetCustomerModel data) =>
    json.encode(data.toJson());

class GetCustomerModel {
  GetCustomerModel({
    bool? success,
    List<Data>? data,
    num? total,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
    _total = total;
    this.errorResponse = errorResponse;
  }

  GetCustomerModel.fromJson(dynamic json) {
    _success = json['success'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
    _total = json['total'];

    if (json['errors'] != null) {
      if (json['errors'] is Map<String, dynamic>) {
        errorResponse = ErrorResponse.fromJson(json['errors']);
      } else if (json['errors'] is List && (json['errors'] as List).isNotEmpty) {
        errorResponse = ErrorResponse(
          message: json['errors'][0]['message'] ?? 'Unknown error',
          statusCode: json['statusCode'],
        );
      }
    } else if (json['message'] != null && _success == false) {
      errorResponse = ErrorResponse(
        message: json['message'],
        statusCode: json['statusCode'],
      );
    }
  }

  bool? _success;
  List<Data>? _data;
  num? _total;
  ErrorResponse? errorResponse;

  GetCustomerModel copyWith({
    bool? success,
    List<Data>? data,
    num? total,
    ErrorResponse? errorResponse,
  }) =>
      GetCustomerModel(
        success: success ?? _success,
        data: data ?? _data,
        total: total ?? _total,
        errorResponse: errorResponse ?? this.errorResponse,
      );

  bool? get success => _success;
  List<Data>? get data => _data;
  num? get total => _total;

  num? get totalCount => _total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['total'] = _total;
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
    String? email,
    Location? location,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _name = name;
    _phone = phone;
    _address = address;
    _email = email;
    _location = location;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _phone = json['phone'];
    _address = json['address'];
    _email = json['email'];
    _location =
    json['location'] != null ? Location.fromJson(json['location']) : null;
    _createdBy = json['createdBy'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }

  String? _id;
  String? _name;
  String? _phone;
  String? _address;
  String? _email;
  Location? _location;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;

  Data copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    Location? location,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        name: name ?? _name,
        phone: phone ?? _phone,
        address: address ?? _address,
        email: email ?? _email,
        location: location ?? _location,
        createdBy: createdBy ?? _createdBy,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );

  String? get id => _id;
  String? get name => _name;
  String? get phone => _phone;
  String? get address => _address;
  String? get email => _email;
  Location? get location => _location;
  String? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['phone'] = _phone;
    map['address'] = _address;
    map['email'] = _email;
    if (_location != null) {
      map['location'] = _location?.toJson();
    }
    map['createdBy'] = _createdBy;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }
}

class Location {
  Location({
    String? id,
    String? name,
  }) {
    _id = id;
    _name = name;
  }

  Location.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
  }

  String? _id;
  String? _name;

  Location copyWith({
    String? id,
    String? name,
  }) =>
      Location(
        id: id ?? _id,
        name: name ?? _name,
      );

  String? get id => _id;
  String? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    return map;
  }
}