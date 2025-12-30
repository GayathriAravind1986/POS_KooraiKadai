import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : [{"creditId":"694e5fe4ae1a80e0671c9234","creditCode":"CRD-20251226-0004","location":"TUTY","date":"2025-12-26T00:00:00.000Z","totalCredit":200,"usedAmount":100,"balanceAmount":100,"description":""}]

GetBalanceModel getBalanceModelFromJson(String str) => GetBalanceModel.fromJson(json.decode(str));
String getBalanceModelToJson(GetBalanceModel data) => json.encode(data.toJson());

class GetBalanceModel {
  GetBalanceModel({
    bool? success,
    List<Data>? data,
    ErrorResponse? errorResponse,
    String? errorMessage,
  }) {
    _success = success;
    _data = data;
    _errorResponse = errorResponse;
    _errorMessage = errorMessage;
  }

  GetBalanceModel.fromJson(dynamic json) {
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
          message: 'Failed to parse balance data: $e',
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
      _errorMessage = 'Failed to fetch balance data';
      _errorResponse = ErrorResponse(message: _errorMessage);
    }
  }

  bool? _success;
  List<Data>? _data;
  ErrorResponse? _errorResponse;
  String? _errorMessage;

  GetBalanceModel copyWith({
    bool? success,
    List<Data>? data,
    ErrorResponse? errorResponse,
    String? errorMessage,
  }) => GetBalanceModel(
    success: success ?? _success,
    data: data ?? _data,
    errorResponse: errorResponse ?? _errorResponse,
    errorMessage: errorMessage ?? _errorMessage,
  );

  bool? get success => _success;
  List<Data>? get data => _data;
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
  factory GetBalanceModel.error(String message, {String? code}) {
    return GetBalanceModel(
      success: false,
      errorResponse: ErrorResponse(message: message),
      errorMessage: message,
    );
  }

  // Factory method for creating success response
  factory GetBalanceModel.success(List<Data> data) {
    return GetBalanceModel(
      success: true,
      data: data,
    );
  }
}

/// creditId : "694e5fe4ae1a80e0671c9234"
/// creditCode : "CRD-20251226-0004"
/// location : "TUTY"
/// date : "2025-12-26T00:00:00.000Z"
/// totalCredit : 200
/// usedAmount : 100
/// balanceAmount : 100
/// description : ""

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    String? creditId,
    String? creditCode,
    String? location,
    String? date,
    num? totalCredit,
    num? usedAmount,
    num? balanceAmount,
    String? description,
  }) {
    _creditId = creditId;
    _creditCode = creditCode;
    _location = location;
    _date = date;
    _totalCredit = totalCredit;
    _usedAmount = usedAmount;
    _balanceAmount = balanceAmount;
    _description = description;
  }

  Data.fromJson(dynamic json) {
    _creditId = json['creditId'];
    _creditCode = json['creditCode'];
    _location = json['location'];
    _date = json['date'];
    _totalCredit = json['totalCredit'];
    _usedAmount = json['usedAmount'];
    _balanceAmount = json['balanceAmount'];
    _description = json['description'];
  }

  String? _creditId;
  String? _creditCode;
  String? _location;
  String? _date;
  num? _totalCredit;
  num? _usedAmount;
  num? _balanceAmount;
  String? _description;

  Data copyWith({
    String? creditId,
    String? creditCode,
    String? location,
    String? date,
    num? totalCredit,
    num? usedAmount,
    num? balanceAmount,
    String? description,
  }) => Data(
    creditId: creditId ?? _creditId,
    creditCode: creditCode ?? _creditCode,
    location: location ?? _location,
    date: date ?? _date,
    totalCredit: totalCredit ?? _totalCredit,
    usedAmount: usedAmount ?? _usedAmount,
    balanceAmount: balanceAmount ?? _balanceAmount,
    description: description ?? _description,
  );

  String? get creditId => _creditId;
  String? get creditCode => _creditCode;
  String? get location => _location;
  String? get date => _date;
  num? get totalCredit => _totalCredit;
  num? get usedAmount => _usedAmount;
  num? get balanceAmount => _balanceAmount;
  String? get description => _description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['creditId'] = _creditId;
    map['creditCode'] = _creditCode;
    map['location'] = _location;
    map['date'] = _date;
    map['totalCredit'] = _totalCredit;
    map['usedAmount'] = _usedAmount;
    map['balanceAmount'] = _balanceAmount;
    map['description'] = _description;
    return map;
  }
}