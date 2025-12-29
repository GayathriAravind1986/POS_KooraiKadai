import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"_id":"69526b04cd98efef7dd31e36","date":"2025-12-29T00:00:00.000Z","locationId":{"_id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"customerId":{"_id":"694e36fe1d157e1ae77390eb","name":"hari"},"price":4000,"description":"","createdBy":{"_id":"6878971f0bc550868fe1b34b","name":"Saranya"},"createdAt":"2025-12-29T11:50:28.999Z","updatedAt":"2025-12-29T12:15:38.801Z","creditCode":"CRD-20251229-0011","__v":0}

GetCustomerByCreditIdModel getCustomerByCreditIdModelFromJson(String str) => GetCustomerByCreditIdModel.fromJson(json.decode(str));
String getCustomerByCreditIdModelToJson(GetCustomerByCreditIdModel data) => json.encode(data.toJson());

class GetCustomerByCreditIdModel {
  GetCustomerByCreditIdModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
    String? errorMessage,
  }) {
    _success = success;
    _data = data;
    _errorResponse = errorResponse;
    _errorMessage = errorMessage;
  }

  GetCustomerByCreditIdModel.fromJson(dynamic json) {
    _success = json['success'];

    // Handle data field with null safety
    if (json['data'] != null) {
      try {
        _data = Data.fromJson(json['data']);
      } catch (e) {
        // If data parsing fails, create an error response
        _errorResponse = ErrorResponse(
          message: 'Failed to parse credit details: $e',
        );
      }
    }

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
      _errorMessage = 'Failed to fetch credit details';
      _errorResponse = ErrorResponse(message: _errorMessage);
    }
  }

  bool? _success;
  Data? _data;
  ErrorResponse? _errorResponse;
  String? _errorMessage;

  GetCustomerByCreditIdModel copyWith({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
    String? errorMessage,
  }) => GetCustomerByCreditIdModel(
    success: success ?? _success,
    data: data ?? _data,
    errorResponse: errorResponse ?? _errorResponse,
    errorMessage: errorMessage ?? _errorMessage,
  );

  bool? get success => _success;
  Data? get data => _data;
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
      map['data'] = _data?.toJson();
    }

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
  factory GetCustomerByCreditIdModel.error(String message, {String? code}) {
    return GetCustomerByCreditIdModel(
      success: false,
      errorResponse: ErrorResponse(message: message),
      errorMessage: message,
    );
  }
}

/// _id : "69526b04cd98efef7dd31e36"
/// date : "2025-12-29T00:00:00.000Z"
/// locationId : {"_id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"}
/// customerId : {"_id":"694e36fe1d157e1ae77390eb","name":"hari"}
/// price : 4000
/// description : ""
/// createdBy : {"_id":"6878971f0bc550868fe1b34b","name":"Saranya"}
/// createdAt : "2025-12-29T11:50:28.999Z"
/// updatedAt : "2025-12-29T12:15:38.801Z"
/// creditCode : "CRD-20251229-0011"
/// __v : 0

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    String? id,
    String? date,
    LocationId? locationId,
    CustomerId? customerId,
    num? price,
    String? description,
    CreatedBy? createdBy,
    String? createdAt,
    String? updatedAt,
    String? creditCode,
    num? v,
  }) {
    _id = id;
    _date = date;
    _locationId = locationId;
    _customerId = customerId;
    _price = price;
    _description = description;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _creditCode = creditCode;
    _v = v;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _date = json['date'];
    _locationId = json['locationId'] != null ? LocationId.fromJson(json['locationId']) : null;
    _customerId = json['customerId'] != null ? CustomerId.fromJson(json['customerId']) : null;
    _price = json['price'];
    _description = json['description'];
    _createdBy = json['createdBy'] != null ? CreatedBy.fromJson(json['createdBy']) : null;
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _creditCode = json['creditCode'];
    _v = json['__v'];
  }

  String? _id;
  String? _date;
  LocationId? _locationId;
  CustomerId? _customerId;
  num? _price;
  String? _description;
  CreatedBy? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  String? _creditCode;
  num? _v;

  Data copyWith({
    String? id,
    String? date,
    LocationId? locationId,
    CustomerId? customerId,
    num? price,
    String? description,
    CreatedBy? createdBy,
    String? createdAt,
    String? updatedAt,
    String? creditCode,
    num? v,
  }) => Data(
    id: id ?? _id,
    date: date ?? _date,
    locationId: locationId ?? _locationId,
    customerId: customerId ?? _customerId,
    price: price ?? _price,
    description: description ?? _description,
    createdBy: createdBy ?? _createdBy,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
    creditCode: creditCode ?? _creditCode,
    v: v ?? _v,
  );

  String? get id => _id;
  String? get date => _date;
  LocationId? get locationId => _locationId;
  CustomerId? get customerId => _customerId;
  num? get price => _price;
  String? get description => _description;
  CreatedBy? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get creditCode => _creditCode;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['date'] = _date;
    if (_locationId != null) {
      map['locationId'] = _locationId?.toJson();
    }
    if (_customerId != null) {
      map['customerId'] = _customerId?.toJson();
    }
    map['price'] = _price;
    map['description'] = _description;
    if (_createdBy != null) {
      map['createdBy'] = _createdBy?.toJson();
    }
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['creditCode'] = _creditCode;
    map['__v'] = _v;
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
  }) => CreatedBy(
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

/// _id : "694e36fe1d157e1ae77390eb"
/// name : "hari"

CustomerId customerIdFromJson(String str) => CustomerId.fromJson(json.decode(str));
String customerIdToJson(CustomerId data) => json.encode(data.toJson());

class CustomerId {
  CustomerId({
    String? id,
    String? name,
  }) {
    _id = id;
    _name = name;
  }

  CustomerId.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
  }

  String? _id;
  String? _name;

  CustomerId copyWith({
    String? id,
    String? name,
  }) => CustomerId(
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

/// _id : "68c8ef05e42b9d827aeb4af3"
/// name : "TUTY"

LocationId locationIdFromJson(String str) => LocationId.fromJson(json.decode(str));
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
  }) => LocationId(
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