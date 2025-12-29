import 'package:simple/Bloc/Response/errorResponse.dart';

/// Model for Return/Credit Report API Response
class ReturnReportModel {
  ReturnReportModel({
    bool? success,
    List<ReturnReportData>? data,
    num? totalRecords,
    num? offset,
    num? limit,
    ReportSummary? summary,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
    _totalRecords = totalRecords;
    _offset = offset;
    _limit = limit;
    _summary = summary;
    _errorResponse = errorResponse;
  }

  ReturnReportModel.fromJson(dynamic json) {
    _success = json['success'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(ReturnReportData.fromJson(v));
      });
    }
    _totalRecords = json['totalRecords'];
    _offset = json['offset'];
    _limit = json['limit'];
    _summary = json['summary'] != null
        ? ReportSummary.fromJson(json['summary'])
        : null;

    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      _errorResponse = ErrorResponse.fromJson(json['errors']);
    }
  }

  bool? _success;
  List<ReturnReportData>? _data;
  num? _totalRecords;
  num? _offset;
  num? _limit;
  ReportSummary? _summary;
  ErrorResponse? _errorResponse;

  bool? get success => _success;
  List<ReturnReportData>? get data => _data;
  num? get totalRecords => _totalRecords;
  num? get offset => _offset;
  num? get limit => _limit;
  ReportSummary? get summary => _summary;
  ErrorResponse? get errorResponse => _errorResponse;

  set errorResponse(ErrorResponse? value) {
    _errorResponse = value;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['totalRecords'] = _totalRecords;
    map['offset'] = _offset;
    map['limit'] = _limit;
    if (_summary != null) {
      map['summary'] = _summary?.toJson();
    }
    if (_errorResponse != null) {
      map['errors'] = _errorResponse!.toJson();
    }
    return map;
  }
}

/// Individual customer return/credit data
class ReturnReportData {
  ReturnReportData({
    String? customerId,
    String? customerName,
    num? totalCredit,
    num? totalReturn,
    num? balanceDue,
    num? creditCount,
    num? returnCount,
  }) {
    _customerId = customerId;
    _customerName = customerName;
    _totalCredit = totalCredit;
    _totalReturn = totalReturn;
    _balanceDue = balanceDue;
    _creditCount = creditCount;
    _returnCount = returnCount;
  }

  ReturnReportData.fromJson(dynamic json) {
    _customerId = json['customerId'];
    _customerName = json['customerName'];
    _totalCredit = json['totalCredit'];
    _totalReturn = json['totalReturn'];
    _balanceDue = json['balanceDue'];
    _creditCount = json['creditCount'];
    _returnCount = json['returnCount'];
  }

  String? _customerId;
  String? _customerName;
  num? _totalCredit;
  num? _totalReturn;
  num? _balanceDue;
  num? _creditCount;
  num? _returnCount;

  String? get customerId => _customerId;
  String? get customerName => _customerName;
  num? get totalCredit => _totalCredit;
  num? get totalReturn => _totalReturn;
  num? get balanceDue => _balanceDue;
  num? get creditCount => _creditCount;
  num? get returnCount => _returnCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['customerId'] = _customerId;
    map['customerName'] = _customerName;
    map['totalCredit'] = _totalCredit;
    map['totalReturn'] = _totalReturn;
    map['balanceDue'] = _balanceDue;
    map['creditCount'] = _creditCount;
    map['returnCount'] = _returnCount;
    return map;
  }
}

/// Report summary totals
class ReportSummary {
  ReportSummary({
    num? totalCreditAmount,
    num? totalReturnAmount,
    num? totalBalanceDue,
    num? customersWithDue,
  }) {
    _totalCreditAmount = totalCreditAmount;
    _totalReturnAmount = totalReturnAmount;
    _totalBalanceDue = totalBalanceDue;
    _customersWithDue = customersWithDue;
  }

  ReportSummary.fromJson(dynamic json) {
    _totalCreditAmount = json['totalCreditAmount'];
    _totalReturnAmount = json['totalReturnAmount'];
    _totalBalanceDue = json['totalBalanceDue'];
    _customersWithDue = json['customersWithDue'];
  }

  num? _totalCreditAmount;
  num? _totalReturnAmount;
  num? _totalBalanceDue;
  num? _customersWithDue;

  num? get totalCreditAmount => _totalCreditAmount;
  num? get totalReturnAmount => _totalReturnAmount;
  num? get totalBalanceDue => _totalBalanceDue;
  num? get customersWithDue => _customersWithDue;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['totalCreditAmount'] = _totalCreditAmount;
    map['totalReturnAmount'] = _totalReturnAmount;
    map['totalBalanceDue'] = _totalBalanceDue;
    map['customersWithDue'] = _customersWithDue;
    return map;
  }
}