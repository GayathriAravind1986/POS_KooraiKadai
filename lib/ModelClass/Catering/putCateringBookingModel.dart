import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"_id":"6952101a2d8c2d639b840d39","locationId":"68c8ef05e42b9d827aeb4af3","date":"2025-12-29T00:00:00.000Z","customerId":"6948e3676478c1090fab8e05","packageId":"6948f15018768350f3a24893","items":["6896dd1e34000a85304985bd"],"addons":["69466f6beeae7ae2a8622f0e"],"packageamount":123,"quantity":1,"addonsamount":10,"paymenttype":"PARTIALLY","paidamount":35,"finalamount":120,"discounttype":"PERCENTAGE","discountvalue":10,"discountamount":13,"totalamount":133,"balanceamount":85,"paymentmode":"CARD","paymentdetails":[{"mode":"UPI","amount":10,"date":"2025-12-29T05:25:11.735Z"},{"mode":"CARD","amount":20,"date":"2025-12-29T05:26:43.489Z"},{"mode":"CARD","amount":5,"date":"2025-12-29T05:26:43.489Z"}],"createdBy":"6878971f0bc550868fe1b34b","createdAt":"2025-12-29T05:22:34.497Z","updatedAt":"2025-12-29T05:35:25.204Z","__v":0}

class PutCateringBookingModel {
  PutCateringBookingModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
  }

  PutCateringBookingModel.fromJson(dynamic json) {
    _success = json['success'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  bool? _success;
  Data? _data;
  ErrorResponse? errorResponse;
  PutCateringBookingModel copyWith({
    bool? success,
    Data? data,
  }) =>
      PutCateringBookingModel(
        success: success ?? _success,
        data: data ?? _data,
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

/// _id : "6952101a2d8c2d639b840d39"
/// locationId : "68c8ef05e42b9d827aeb4af3"
/// date : "2025-12-29T00:00:00.000Z"
/// customerId : "6948e3676478c1090fab8e05"
/// packageId : "6948f15018768350f3a24893"
/// items : ["6896dd1e34000a85304985bd"]
/// addons : ["69466f6beeae7ae2a8622f0e"]
/// packageamount : 123
/// quantity : 1
/// addonsamount : 10
/// paymenttype : "PARTIALLY"
/// paidamount : 35
/// finalamount : 120
/// discounttype : "PERCENTAGE"
/// discountvalue : 10
/// discountamount : 13
/// totalamount : 133
/// balanceamount : 85
/// paymentmode : "CARD"
/// paymentdetails : [{"mode":"UPI","amount":10,"date":"2025-12-29T05:25:11.735Z"},{"mode":"CARD","amount":20,"date":"2025-12-29T05:26:43.489Z"},{"mode":"CARD","amount":5,"date":"2025-12-29T05:26:43.489Z"}]
/// createdBy : "6878971f0bc550868fe1b34b"
/// createdAt : "2025-12-29T05:22:34.497Z"
/// updatedAt : "2025-12-29T05:35:25.204Z"
/// __v : 0

class Data {
  Data({
    String? id,
    String? date,
    num? quantity,
    num? packageamount,
    num? addonsamount,
    num? discountamount,
    num? totalamount,
    num? finalamount,
    num? paidamount,
    num? balanceamount,
    String? discounttype,
    num? discountvalue,
    String? paymenttype,
    String? paymentmode,
    List<Paymentdetails>? paymentdetails,
    String? createdBy,
    String? locationName,
    String? customerName,
    String? packageName,
    List<String>? addonNames,
    List<String>? itemNames,
  }) {
    _id = id;
    _date = date;
    _quantity = quantity;
    _packageamount = packageamount;
    _addonsamount = addonsamount;
    _discountamount = discountamount;
    _totalamount = totalamount;
    _finalamount = finalamount;
    _paidamount = paidamount;
    _balanceamount = balanceamount;
    _discounttype = discounttype;
    _discountvalue = discountvalue;
    _paymenttype = paymenttype;
    _paymentmode = paymentmode;
    _paymentdetails = paymentdetails;
    _createdBy = createdBy;
    _locationName = locationName;
    _customerName = customerName;
    _packageName = packageName;
    _addonNames = addonNames;
    _itemNames = itemNames;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _date = json['date'];
    _quantity = json['quantity'];
    _packageamount = json['packageamount'];
    _addonsamount = json['addonsamount'];
    _discountamount = json['discountamount'];
    _totalamount = json['totalamount'];
    _finalamount = json['finalamount'];
    _paidamount = json['paidamount'];
    _balanceamount = json['balanceamount'];
    _discounttype = json['discounttype'];
    _discountvalue = json['discountvalue'];
    _paymenttype = json['paymenttype'];
    _paymentmode = json['paymentmode'];
    if (json['paymentdetails'] != null) {
      _paymentdetails = [];
      json['paymentdetails'].forEach((v) {
        _paymentdetails?.add(Paymentdetails.fromJson(v));
      });
    }
    _createdBy = json['createdBy'];
    _locationName = json['locationName'];
    _customerName = json['customerName'];
    _packageName = json['packageName'];
    _addonNames =
        json['addonNames'] != null ? json['addonNames'].cast<String>() : [];
    _itemNames =
        json['itemNames'] != null ? json['itemNames'].cast<String>() : [];
  }
  String? _id;
  String? _date;
  num? _quantity;
  num? _packageamount;
  num? _addonsamount;
  num? _discountamount;
  num? _totalamount;
  num? _finalamount;
  num? _paidamount;
  num? _balanceamount;
  String? _discounttype;
  num? _discountvalue;
  String? _paymenttype;
  String? _paymentmode;
  List<Paymentdetails>? _paymentdetails;
  String? _createdBy;
  String? _locationName;
  String? _customerName;
  String? _packageName;
  List<String>? _addonNames;
  List<String>? _itemNames;
  Data copyWith({
    String? id,
    String? date,
    num? quantity,
    num? packageamount,
    num? addonsamount,
    num? discountamount,
    num? totalamount,
    num? finalamount,
    num? paidamount,
    num? balanceamount,
    String? discounttype,
    num? discountvalue,
    String? paymenttype,
    String? paymentmode,
    List<Paymentdetails>? paymentdetails,
    String? createdBy,
    String? locationName,
    String? customerName,
    String? packageName,
    List<String>? addonNames,
    List<String>? itemNames,
  }) =>
      Data(
        id: id ?? _id,
        date: date ?? _date,
        quantity: quantity ?? _quantity,
        packageamount: packageamount ?? _packageamount,
        addonsamount: addonsamount ?? _addonsamount,
        discountamount: discountamount ?? _discountamount,
        totalamount: totalamount ?? _totalamount,
        finalamount: finalamount ?? _finalamount,
        paidamount: paidamount ?? _paidamount,
        balanceamount: balanceamount ?? _balanceamount,
        discounttype: discounttype ?? _discounttype,
        discountvalue: discountvalue ?? _discountvalue,
        paymenttype: paymenttype ?? _paymenttype,
        paymentmode: paymentmode ?? _paymentmode,
        paymentdetails: paymentdetails ?? _paymentdetails,
        createdBy: createdBy ?? _createdBy,
        locationName: locationName ?? _locationName,
        customerName: customerName ?? _customerName,
        packageName: packageName ?? _packageName,
        addonNames: addonNames ?? _addonNames,
        itemNames: itemNames ?? _itemNames,
      );
  String? get id => _id;
  String? get date => _date;
  num? get quantity => _quantity;
  num? get packageamount => _packageamount;
  num? get addonsamount => _addonsamount;
  num? get discountamount => _discountamount;
  num? get totalamount => _totalamount;
  num? get finalamount => _finalamount;
  num? get paidamount => _paidamount;
  num? get balanceamount => _balanceamount;
  String? get discounttype => _discounttype;
  num? get discountvalue => _discountvalue;
  String? get paymenttype => _paymenttype;
  String? get paymentmode => _paymentmode;
  List<Paymentdetails>? get paymentdetails => _paymentdetails;
  String? get createdBy => _createdBy;
  String? get locationName => _locationName;
  String? get customerName => _customerName;
  String? get packageName => _packageName;
  List<String>? get addonNames => _addonNames;
  List<String>? get itemNames => _itemNames;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['date'] = _date;
    map['quantity'] = _quantity;
    map['packageamount'] = _packageamount;
    map['addonsamount'] = _addonsamount;
    map['discountamount'] = _discountamount;
    map['totalamount'] = _totalamount;
    map['finalamount'] = _finalamount;
    map['paidamount'] = _paidamount;
    map['balanceamount'] = _balanceamount;
    map['discounttype'] = _discounttype;
    map['discountvalue'] = _discountvalue;
    map['paymenttype'] = _paymenttype;
    map['paymentmode'] = _paymentmode;
    if (_paymentdetails != null) {
      map['paymentdetails'] = _paymentdetails?.map((v) => v.toJson()).toList();
    }
    map['createdBy'] = _createdBy;
    map['locationName'] = _locationName;
    map['customerName'] = _customerName;
    map['packageName'] = _packageName;
    map['addonNames'] = _addonNames;
    map['itemNames'] = _itemNames;
    return map;
  }
}

/// mode : "UPI"
/// amount : 10
/// date : "2025-12-29T05:25:11.735Z"

class Paymentdetails {
  Paymentdetails({
    String? mode,
    num? amount,
    String? date,
  }) {
    _mode = mode;
    _amount = amount;
    _date = date;
  }

  Paymentdetails.fromJson(dynamic json) {
    _mode = json['mode'];
    _amount = json['amount'];
    _date = json['date'];
  }
  String? _mode;
  num? _amount;
  String? _date;
  Paymentdetails copyWith({
    String? mode,
    num? amount,
    String? date,
  }) =>
      Paymentdetails(
        mode: mode ?? _mode,
        amount: amount ?? _amount,
        date: date ?? _date,
      );
  String? get mode => _mode;
  num? get amount => _amount;
  String? get date => _date;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['mode'] = _mode;
    map['amount'] = _amount;
    map['date'] = _date;
    return map;
  }
}
