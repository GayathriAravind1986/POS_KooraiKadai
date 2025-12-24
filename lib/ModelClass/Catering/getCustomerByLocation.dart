import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : [{"id":"69463ea2ce36a20f74df859c","name":"phoneds","phone":"7890989076","address":"","email":"","location":{"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"createdBy":"Mano","createdAt":"2025-12-20","updatedAt":"2025-12-20T06:13:54.092Z"},{"id":"69463bd0d85a3f7ede0c6c1e","name":"phone","phone":"9965784466","address":"","email":"","location":{"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"createdBy":"Saranya","createdAt":"2025-12-20","updatedAt":"2025-12-20T06:01:52.891Z"},{"id":"69463bb2d85a3f7ede0c6bc1","name":"murugan","phone":"9876543210","address":"","email":"","location":{"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"createdBy":"Saranya","createdAt":"2025-12-20","updatedAt":"2025-12-20T06:01:22.436Z"},{"id":"69463971d85a3f7ede0c6a8f","name":"mano","phone":"9878967893","address":"fsd","email":"sentinix@gmail.com","location":{"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"createdBy":"Saranya","createdAt":"2025-12-20","updatedAt":"2025-12-20T05:51:45.589Z"}]
/// total : 4

class GetCustomerByLocation {
  GetCustomerByLocation({
    bool? success,
    List<Data>? data,
    num? total,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
    _total = total;
  }

  GetCustomerByLocation.fromJson(dynamic json) {
    _success = json['success'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
    _total = json['total'];
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  bool? _success;
  List<Data>? _data;
  num? _total;
  ErrorResponse? errorResponse;
  GetCustomerByLocation copyWith({
    bool? success,
    List<Data>? data,
    num? total,
  }) =>
      GetCustomerByLocation(
        success: success ?? _success,
        data: data ?? _data,
        total: total ?? _total,
      );
  bool? get success => _success;
  List<Data>? get data => _data;
  num? get total => _total;

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

/// id : "69463ea2ce36a20f74df859c"
/// name : "phoneds"
/// phone : "7890989076"
/// address : ""
/// email : ""
/// location : {"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"}
/// createdBy : "Mano"
/// createdAt : "2025-12-20"
/// updatedAt : "2025-12-20T06:13:54.092Z"

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

/// id : "68c8ef05e42b9d827aeb4af3"
/// name : "TUTY"

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
