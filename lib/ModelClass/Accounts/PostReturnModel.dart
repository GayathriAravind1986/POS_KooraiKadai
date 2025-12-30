import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"date":"2025-12-29T00:00:00.000Z","locationId":"68c8ef05e42b9d827aeb4af3","customerId":"694e161859eb2ff32443aa1f","creditId":"6952487a3f266c0993ee9024","price":200,"description":"","createdBy":"68874a73138aa2dcca66347c","_id":"6952a2ebd878628571737483","createdAt":"2025-12-29T15:48:59.587Z","updatedAt":"2025-12-29T15:48:59.587Z","returnCode":"RTN-20251229-0023","__v":0}

PostReturnModel postReturnModelFromJson(String str) => PostReturnModel.fromJson(json.decode(str));
String postReturnModelToJson(PostReturnModel data) => json.encode(data.toJson());

class PostReturnModel {
  PostReturnModel({
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

  PostReturnModel.fromJson(dynamic json) {
    _success = json['success'];

    // Handle data field with null safety
    if (json['data'] != null) {
      try {
        _data = Data.fromJson(json['data']);
      } catch (e) {
        // If data parsing fails, create an error response
        _errorResponse = ErrorResponse(
          message: 'Failed to parse return data: $e',
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
      _errorMessage = 'Return creation failed but no error details provided';
      _errorResponse = ErrorResponse(message: _errorMessage);
    }
  }

  bool? _success;
  Data? _data;
  ErrorResponse? _errorResponse;
  String? _errorMessage;

  PostReturnModel copyWith({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
    String? errorMessage,
  }) => PostReturnModel(
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
  factory PostReturnModel.error(String message, {String? code}) {
    return PostReturnModel(
      success: false,
      errorResponse: ErrorResponse(message: message),
      errorMessage: message,
    );
  }

  // Factory method for creating success response
  factory PostReturnModel.success(Data data) {
    return PostReturnModel(
      success: true,
      data: data,
    );
  }
}

/// date : "2025-12-29T00:00:00.000Z"
/// locationId : "68c8ef05e42b9d827aeb4af3"
/// customerId : "694e161859eb2ff32443aa1f"
/// creditId : "6952487a3f266c0993ee9024"
/// price : 200
/// description : ""
/// createdBy : "68874a73138aa2dcca66347c"
/// _id : "6952a2ebd878628571737483"
/// createdAt : "2025-12-29T15:48:59.587Z"
/// updatedAt : "2025-12-29T15:48:59.587Z"
/// returnCode : "RTN-20251229-0023"
/// __v : 0

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    String? date,
    String? locationId,
    String? customerId,
    String? creditId,
    num? price,
    String? description,
    String? createdBy,
    String? id,
    String? createdAt,
    String? updatedAt,
    String? returnCode,
    num? v,
  }) {
    _date = date;
    _locationId = locationId;
    _customerId = customerId;
    _creditId = creditId;
    _price = price;
    _description = description;
    _createdBy = createdBy;
    _id = id;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _returnCode = returnCode;
    _v = v;
  }

  Data.fromJson(dynamic json) {
    _date = json['date'];
    _locationId = json['locationId'];
    _customerId = json['customerId'];
    _creditId = json['creditId'];
    _price = json['price'];
    _description = json['description'];
    _createdBy = json['createdBy'];
    _id = json['_id'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _returnCode = json['returnCode'];
    _v = json['__v'];
  }

  String? _date;
  String? _locationId;
  String? _customerId;
  String? _creditId;
  num? _price;
  String? _description;
  String? _createdBy;
  String? _id;
  String? _createdAt;
  String? _updatedAt;
  String? _returnCode;
  num? _v;

  Data copyWith({
    String? date,
    String? locationId,
    String? customerId,
    String? creditId,
    num? price,
    String? description,
    String? createdBy,
    String? id,
    String? createdAt,
    String? updatedAt,
    String? returnCode,
    num? v,
  }) => Data(
    date: date ?? _date,
    locationId: locationId ?? _locationId,
    customerId: customerId ?? _customerId,
    creditId: creditId ?? _creditId,
    price: price ?? _price,
    description: description ?? _description,
    createdBy: createdBy ?? _createdBy,
    id: id ?? _id,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
    returnCode: returnCode ?? _returnCode,
    v: v ?? _v,
  );

  String? get date => _date;
  String? get locationId => _locationId;
  String? get customerId => _customerId;
  String? get creditId => _creditId;
  num? get price => _price;
  String? get description => _description;
  String? get createdBy => _createdBy;
  String? get id => _id;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get returnCode => _returnCode;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['date'] = _date;
    map['locationId'] = _locationId;
    map['customerId'] = _customerId;
    map['creditId'] = _creditId;
    map['price'] = _price;
    map['description'] = _description;
    map['createdBy'] = _createdBy;
    map['_id'] = _id;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['returnCode'] = _returnCode;
    map['__v'] = _v;
    return map;
  }
}