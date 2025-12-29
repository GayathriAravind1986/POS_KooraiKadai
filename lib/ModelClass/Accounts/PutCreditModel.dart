import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"_id":"69526b04cd98efef7dd31e36","date":"2025-12-29T00:00:00.000Z","locationId":"68c8ef05e42b9d827aeb4af3","customerId":"694e36fe1d157e1ae77390eb","price":8000,"description":"","createdBy":"6878971f0bc550868fe1b34b","createdAt":"2025-12-29T11:50:28.999Z","updatedAt":"2025-12-29T15:04:39.021Z","creditCode":"CRD-20251229-0011","__v":0}

PutCreditModel putCreditModelFromJson(String str) => PutCreditModel.fromJson(json.decode(str));
String putCreditModelToJson(PutCreditModel data) => json.encode(data.toJson());

class PutCreditModel {
  PutCreditModel({
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

  PutCreditModel.fromJson(dynamic json) {
    _success = json['success'];

    // Handle data field with null safety
    if (json['data'] != null) {
      try {
        _data = Data.fromJson(json['data']);
      } catch (e) {
        // If data parsing fails, create an error response
        _errorResponse = ErrorResponse(
          message: 'Failed to parse credit data: $e',
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
      _errorMessage = 'Credit update failed but no error details provided';
      _errorResponse = ErrorResponse(message: _errorMessage);
    }
  }

  bool? _success;
  Data? _data;
  ErrorResponse? _errorResponse;
  String? _errorMessage;

  PutCreditModel copyWith({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
    String? errorMessage,
  }) => PutCreditModel(
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
  factory PutCreditModel.error(String message, {String? code}) {
    return PutCreditModel(
      success: false,
      errorResponse: ErrorResponse(message: message),
      errorMessage: message,
    );
  }

  // Factory method for creating success response
  factory PutCreditModel.success(Data data) {
    return PutCreditModel(
      success: true,
      data: data,
    );
  }
}

/// _id : "69526b04cd98efef7dd31e36"
/// date : "2025-12-29T00:00:00.000Z"
/// locationId : "68c8ef05e42b9d827aeb4af3"
/// customerId : "694e36fe1d157e1ae77390eb"
/// price : 8000
/// description : ""
/// createdBy : "6878971f0bc550868fe1b34b"
/// createdAt : "2025-12-29T11:50:28.999Z"
/// updatedAt : "2025-12-29T15:04:39.021Z"
/// creditCode : "CRD-20251229-0011"
/// __v : 0

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    String? id,
    String? date,
    String? locationId,
    String? customerId,
    num? price,
    String? description,
    String? createdBy,
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
    _locationId = json['locationId'];
    _customerId = json['customerId'];
    _price = json['price'];
    _description = json['description'];
    _createdBy = json['createdBy'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _creditCode = json['creditCode'];
    _v = json['__v'];
  }

  String? _id;
  String? _date;
  String? _locationId;
  String? _customerId;
  num? _price;
  String? _description;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  String? _creditCode;
  num? _v;

  Data copyWith({
    String? id,
    String? date,
    String? locationId,
    String? customerId,
    num? price,
    String? description,
    String? createdBy,
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
  String? get locationId => _locationId;
  String? get customerId => _customerId;
  num? get price => _price;
  String? get description => _description;
  String? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get creditCode => _creditCode;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['date'] = _date;
    map['locationId'] = _locationId;
    map['customerId'] = _customerId;
    map['price'] = _price;
    map['description'] = _description;
    map['createdBy'] = _createdBy;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['creditCode'] = _creditCode;
    map['__v'] = _v;
    return map;
  }
}