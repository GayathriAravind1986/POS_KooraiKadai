import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : [{"id":"6952a2ebd878628571737483","date":"2025-12-29T00:00:00.000Z","returnCode":"RTN-20251229-0023","price":200,"description":"","customer":{"id":"694e161859eb2ff32443aa1f","name":"Ajay"},"location":{"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"credit":{"id":"6952487a3f266c0993ee9024","code":"CRD-20251229-0005","price":2000},"createdBy":"Mano","createdAt":"2025-12-29","updatedAt":"2025-12-29T15:48:59.587Z"}]
/// total : 11

GetAllReturnsModel getAllReturnsModelFromJson(String str) => GetAllReturnsModel.fromJson(json.decode(str));
String getAllReturnsModelToJson(GetAllReturnsModel data) => json.encode(data.toJson());

class GetAllReturnsModel {
  GetAllReturnsModel({
    bool? success,
    List<Data>? data,
    num? total,
    ErrorResponse? errorResponse,
    String? errorMessage,
  }) {
    _success = success;
    _data = data;
    _total = total;
    _errorResponse = errorResponse;
    _errorMessage = errorMessage;
  }

  GetAllReturnsModel.fromJson(dynamic json) {
    _success = json['success'];

    // Handle data field with null safety
    if (json['data'] != null && json['data'] is List) {
      try {
        _data = [];
        json['data'].forEach((v) {
          _data?.add(Data.fromJson(v));
        });
      } catch (e) {
        // If data parsing fails, create an error response
        _errorResponse = ErrorResponse(
          message: 'Failed to parse returns data: $e',
        );
      }
    }

    _total = json['total'];

    // Handle error response - check for 'errors' field in JSON
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      _errorResponse = ErrorResponse.fromJson(json['errors']);
    }

    // Also check for 'message' field (common error format)
    if (json['message'] != null && json['message'] is String) {
      _errorMessage = json['message'];
      if (_errorResponse == null) {
        _errorResponse = ErrorResponse(message: _errorMessage);
      }
    }

    // Check if success is false but no explicit error provided
    if (_success == false && _errorResponse == null && _errorMessage == null) {
      _errorMessage = 'Failed to fetch returns data';
      _errorResponse = ErrorResponse(message: _errorMessage);
    }
  }

  bool? _success;
  List<Data>? _data;
  num? _total;
  ErrorResponse? _errorResponse;
  String? _errorMessage;

  GetAllReturnsModel copyWith({
    bool? success,
    List<Data>? data,
    num? total,
    ErrorResponse? errorResponse,
    String? errorMessage,
  }) => GetAllReturnsModel(
    success: success ?? _success,
    data: data ?? _data,
    total: total ?? _total,
    errorResponse: errorResponse ?? _errorResponse,
    errorMessage: errorMessage ?? _errorMessage,
  );

  bool? get success => _success;
  List<Data>? get data => _data;
  num? get total => _total;
  ErrorResponse? get errorResponse => _errorResponse;
  String? get errorMessage => _errorMessage;

  // Helper method to check if there's any error
  bool get hasError => errorResponse != null || errorMessage != null;

  // Helper method to get combined error message
  String? get combinedErrorMessage {
    if (errorResponse?.message != null) {
      return errorResponse!.message;
    }
    return errorMessage;
  }

  // Setter for error response
  set errorResponse(ErrorResponse? value) {
    _errorResponse = value;
  }

  // Setter for error message
  set errorMessage(String? value) {
    _errorMessage = value;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['total'] = _total;

    // Include error response in JSON if it exists
    if (_errorResponse != null) {
      map['errors'] = _errorResponse!.toJson();
    }

    // Include error message if it exists
    if (_errorMessage != null) {
      map['message'] = _errorMessage;
    }

    return map;
  }

  // Factory method for creating error response
  factory GetAllReturnsModel.error(String message, {String? code}) {
    return GetAllReturnsModel(
      success: false,
      errorResponse: ErrorResponse(message: message),
      errorMessage: message,
    );
  }

  // Factory method for creating success response
  factory GetAllReturnsModel.success(List<Data> data, {num? total}) {
    return GetAllReturnsModel(
      success: true,
      data: data,
      total: total ?? data.length,
    );
  }
}

/// id : "6952a2ebd878628571737483"
/// date : "2025-12-29T00:00:00.000Z"
/// returnCode : "RTN-20251229-0023"
/// price : 200
/// description : ""
/// customer : {"id":"694e161859eb2ff32443aa1f","name":"Ajay"}
/// location : {"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"}
/// credit : {"id":"6952487a3f266c0993ee9024","code":"CRD-20251229-0005","price":2000}
/// createdBy : "Mano"
/// createdAt : "2025-12-29"
/// updatedAt : "2025-12-29T15:48:59.587Z"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    String? id,
    String? date,
    String? returnCode,
    num? price,
    String? description,
    Customer? customer,
    Location? location,
    Credit? credit,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _date = date;
    _returnCode = returnCode;
    _price = price;
    _description = description;
    _customer = customer;
    _location = location;
    _credit = credit;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _date = json['date'];
    _returnCode = json['returnCode'];
    _price = json['price'];
    _description = json['description'];
    _customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    _location = json['location'] != null ? Location.fromJson(json['location']) : null;
    _credit = json['credit'] != null ? Credit.fromJson(json['credit']) : null;
    _createdBy = json['createdBy'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }

  String? _id;
  String? _date;
  String? _returnCode;
  num? _price;
  String? _description;
  Customer? _customer;
  Location? _location;
  Credit? _credit;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;

  Data copyWith({
    String? id,
    String? date,
    String? returnCode,
    num? price,
    String? description,
    Customer? customer,
    Location? location,
    Credit? credit,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) => Data(
    id: id ?? _id,
    date: date ?? _date,
    returnCode: returnCode ?? _returnCode,
    price: price ?? _price,
    description: description ?? _description,
    customer: customer ?? _customer,
    location: location ?? _location,
    credit: credit ?? _credit,
    createdBy: createdBy ?? _createdBy,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
  );

  String? get id => _id;
  String? get date => _date;
  String? get returnCode => _returnCode;
  num? get price => _price;
  String? get description => _description;
  Customer? get customer => _customer;
  Location? get location => _location;
  Credit? get credit => _credit;
  String? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['date'] = _date;
    map['returnCode'] = _returnCode;
    map['price'] = _price;
    map['description'] = _description;
    if (_customer != null) {
      map['customer'] = _customer?.toJson();
    }
    if (_location != null) {
      map['location'] = _location?.toJson();
    }
    if (_credit != null) {
      map['credit'] = _credit?.toJson();
    }
    map['createdBy'] = _createdBy;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }
}

/// id : "6952487a3f266c0993ee9024"
/// code : "CRD-20251229-0005"
/// price : 2000

Credit creditFromJson(String str) => Credit.fromJson(json.decode(str));
String creditToJson(Credit data) => json.encode(data.toJson());

class Credit {
  Credit({
    String? id,
    String? code,
    num? price,
  }) {
    _id = id;
    _code = code;
    _price = price;
  }

  Credit.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _price = json['price'];
  }

  String? _id;
  String? _code;
  num? _price;

  Credit copyWith({
    String? id,
    String? code,
    num? price,
  }) => Credit(
    id: id ?? _id,
    code: code ?? _code,
    price: price ?? _price,
  );

  String? get id => _id;
  String? get code => _code;
  num? get price => _price;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['price'] = _price;
    return map;
  }
}

/// id : "68c8ef05e42b9d827aeb4af3"
/// name : "TUTY"

Location locationFromJson(String str) => Location.fromJson(json.decode(str));
String locationToJson(Location data) => json.encode(data.toJson());

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
  }) => Location(
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

/// id : "694e161859eb2ff32443aa1f"
/// name : "Ajay"

Customer customerFromJson(String str) => Customer.fromJson(json.decode(str));
String customerToJson(Customer data) => json.encode(data.toJson());

class Customer {
  Customer({
    String? id,
    String? name,
  }) {
    _id = id;
    _name = name;
  }

  Customer.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
  }

  String? _id;
  String? _name;

  Customer copyWith({
    String? id,
    String? name,
  }) => Customer(
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