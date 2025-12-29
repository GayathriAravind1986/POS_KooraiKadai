import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart'; // Import the error response

/// success : true
/// data : [{"id":"694fa28b32c34f3cf17f5d85","date":"2025-12-27T00:00:00.000Z","creditCode":"CRD-20251127-0002","price":800,"description":"","customer":{"id":"69463971d85a3f7ede0c6a8f","name":"mano"},"location":{"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"createdBy":"Saranya","createdAt":"2025-12-27","updatedAt":"2025-12-27T09:30:13.982Z"}]
/// total : 10

GetAllCreditsModel getAllCreditsModelFromJson(String str) => GetAllCreditsModel.fromJson(json.decode(str));
String getAllCreditsModelToJson(GetAllCreditsModel data) => json.encode(data.toJson());

class GetAllCreditsModel {
  GetAllCreditsModel({
    bool? success,
    List<Data>? data,
    num? total,
    ErrorResponse? errorResponse,
    String? errorMessage, // Additional error message field
  }){
    _success = success;
    _data = data;
    _total = total;
    _errorResponse = errorResponse;
    _errorMessage = errorMessage;
  }

  GetAllCreditsModel.fromJson(dynamic json) {
    _success = json['success'];

    // Handle data field with null safety
    if (json['data'] != null && json['data'] is List) {
      _data = [];
      try {
        json['data'].forEach((v) {
          if (v != null) {
            _data?.add(Data.fromJson(v));
          }
        });
      } catch (e) {
        // If data parsing fails, create an error response
        _errorResponse = ErrorResponse(
          message: 'Failed to parse credit data: $e'
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
      _errorMessage = 'Request failed but no error details provided';
      _errorResponse = ErrorResponse(message: _errorMessage);
    }
  }

  bool? _success;
  List<Data>? _data;
  num? _total;
  ErrorResponse? _errorResponse;
  String? _errorMessage; // Simple error message

  GetAllCreditsModel copyWith({
    bool? success,
    List<Data>? data,
    num? total,
    ErrorResponse? errorResponse,
    String? errorMessage,
  }) => GetAllCreditsModel(
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
  factory GetAllCreditsModel.error(String message, {String? code}) {
    return GetAllCreditsModel(
      success: false,
      errorResponse: ErrorResponse(message: message),
      errorMessage: message,
    );
  }
}

/// id : "694fa28b32c34f3cf17f5d85"
/// date : "2025-12-27T00:00:00.000Z"
/// creditCode : "CRD-20251127-0002"
/// price : 800
/// description : ""
/// customer : {"id":"69463971d85a3f7ede0c6a8f","name":"mano"}
/// location : {"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"}
/// createdBy : "Saranya"
/// createdAt : "2025-12-27"
/// updatedAt : "2025-12-27T09:30:13.982Z"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    String? id,
    String? date,
    String? creditCode,
    num? price,
    String? description,
    Customer? customer,
    Location? location,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }){
    _id = id;
    _date = date;
    _creditCode = creditCode;
    _price = price;
    _description = description;
    _customer = customer;
    _location = location;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _date = json['date'];
    _creditCode = json['creditCode'];
    _price = json['price'] is int ? json['price'].toDouble() : json['price'];
    _description = json['description'];
    _customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    _location = json['location'] != null ? Location.fromJson(json['location']) : null;
    _createdBy = json['createdBy'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }

  String? _id;
  String? _date;
  String? _creditCode;
  num? _price;
  String? _description;
  Customer? _customer;
  Location? _location;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;

  Data copyWith({
    String? id,
    String? date,
    String? creditCode,
    num? price,
    String? description,
    Customer? customer,
    Location? location,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) => Data(
    id: id ?? _id,
    date: date ?? _date,
    creditCode: creditCode ?? _creditCode,
    price: price ?? _price,
    description: description ?? _description,
    customer: customer ?? _customer,
    location: location ?? _location,
    createdBy: createdBy ?? _createdBy,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
  );

  String? get id => _id;
  String? get date => _date;
  String? get creditCode => _creditCode;
  num? get price => _price;
  String? get description => _description;
  Customer? get customer => _customer;
  Location? get location => _location;
  String? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['date'] = _date;
    map['creditCode'] = _creditCode;
    map['price'] = _price;
    map['description'] = _description;
    if (_customer != null) {
      map['customer'] = _customer?.toJson();
    }
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

Location locationFromJson(String str) => Location.fromJson(json.decode(str));
String locationToJson(Location data) => json.encode(data.toJson());

class Location {
  Location({
    String? id,
    String? name,
  }){
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

/// id : "69463971d85a3f7ede0c6a8f"
/// name : "mano"

Customer customerFromJson(String str) => Customer.fromJson(json.decode(str));
String customerToJson(Customer data) => json.encode(data.toJson());

class Customer {
  Customer({
    String? id,
    String? name,
  }){
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