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
    String? locationId,
    String? date,
    String? customerId,
    String? packageId,
    List<String>? items,
    List<String>? addons,
    num? packageamount,
    num? quantity,
    num? addonsamount,
    String? paymenttype,
    num? paidamount,
    num? finalamount,
    String? discounttype,
    num? discountvalue,
    num? discountamount,
    num? totalamount,
    num? balanceamount,
    String? paymentmode,
    List<Paymentdetails>? paymentdetails,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _locationId = locationId;
    _date = date;
    _customerId = customerId;
    _packageId = packageId;
    _items = items;
    _addons = addons;
    _packageamount = packageamount;
    _quantity = quantity;
    _addonsamount = addonsamount;
    _paymenttype = paymenttype;
    _paidamount = paidamount;
    _finalamount = finalamount;
    _discounttype = discounttype;
    _discountvalue = discountvalue;
    _discountamount = discountamount;
    _totalamount = totalamount;
    _balanceamount = balanceamount;
    _paymentmode = paymentmode;
    _paymentdetails = paymentdetails;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _locationId = json['locationId'];
    _date = json['date'];
    _customerId = json['customerId'];
    _packageId = json['packageId'];
    _items = json['items'] != null ? json['items'].cast<String>() : [];
    _addons = json['addons'] != null ? json['addons'].cast<String>() : [];
    _packageamount = json['packageamount'];
    _quantity = json['quantity'];
    _addonsamount = json['addonsamount'];
    _paymenttype = json['paymenttype'];
    _paidamount = json['paidamount'];
    _finalamount = json['finalamount'];
    _discounttype = json['discounttype'];
    _discountvalue = json['discountvalue'];
    _discountamount = json['discountamount'];
    _totalamount = json['totalamount'];
    _balanceamount = json['balanceamount'];
    _paymentmode = json['paymentmode'];
    if (json['paymentdetails'] != null) {
      _paymentdetails = [];
      json['paymentdetails'].forEach((v) {
        _paymentdetails?.add(Paymentdetails.fromJson(v));
      });
    }
    _createdBy = json['createdBy'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _locationId;
  String? _date;
  String? _customerId;
  String? _packageId;
  List<String>? _items;
  List<String>? _addons;
  num? _packageamount;
  num? _quantity;
  num? _addonsamount;
  String? _paymenttype;
  num? _paidamount;
  num? _finalamount;
  String? _discounttype;
  num? _discountvalue;
  num? _discountamount;
  num? _totalamount;
  num? _balanceamount;
  String? _paymentmode;
  List<Paymentdetails>? _paymentdetails;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Data copyWith({
    String? id,
    String? locationId,
    String? date,
    String? customerId,
    String? packageId,
    List<String>? items,
    List<String>? addons,
    num? packageamount,
    num? quantity,
    num? addonsamount,
    String? paymenttype,
    num? paidamount,
    num? finalamount,
    String? discounttype,
    num? discountvalue,
    num? discountamount,
    num? totalamount,
    num? balanceamount,
    String? paymentmode,
    List<Paymentdetails>? paymentdetails,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      Data(
        id: id ?? _id,
        locationId: locationId ?? _locationId,
        date: date ?? _date,
        customerId: customerId ?? _customerId,
        packageId: packageId ?? _packageId,
        items: items ?? _items,
        addons: addons ?? _addons,
        packageamount: packageamount ?? _packageamount,
        quantity: quantity ?? _quantity,
        addonsamount: addonsamount ?? _addonsamount,
        paymenttype: paymenttype ?? _paymenttype,
        paidamount: paidamount ?? _paidamount,
        finalamount: finalamount ?? _finalamount,
        discounttype: discounttype ?? _discounttype,
        discountvalue: discountvalue ?? _discountvalue,
        discountamount: discountamount ?? _discountamount,
        totalamount: totalamount ?? _totalamount,
        balanceamount: balanceamount ?? _balanceamount,
        paymentmode: paymentmode ?? _paymentmode,
        paymentdetails: paymentdetails ?? _paymentdetails,
        createdBy: createdBy ?? _createdBy,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  String? get id => _id;
  String? get locationId => _locationId;
  String? get date => _date;
  String? get customerId => _customerId;
  String? get packageId => _packageId;
  List<String>? get items => _items;
  List<String>? get addons => _addons;
  num? get packageamount => _packageamount;
  num? get quantity => _quantity;
  num? get addonsamount => _addonsamount;
  String? get paymenttype => _paymenttype;
  num? get paidamount => _paidamount;
  num? get finalamount => _finalamount;
  String? get discounttype => _discounttype;
  num? get discountvalue => _discountvalue;
  num? get discountamount => _discountamount;
  num? get totalamount => _totalamount;
  num? get balanceamount => _balanceamount;
  String? get paymentmode => _paymentmode;
  List<Paymentdetails>? get paymentdetails => _paymentdetails;
  String? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['locationId'] = _locationId;
    map['date'] = _date;
    map['customerId'] = _customerId;
    map['packageId'] = _packageId;
    map['items'] = _items;
    map['addons'] = _addons;
    map['packageamount'] = _packageamount;
    map['quantity'] = _quantity;
    map['addonsamount'] = _addonsamount;
    map['paymenttype'] = _paymenttype;
    map['paidamount'] = _paidamount;
    map['finalamount'] = _finalamount;
    map['discounttype'] = _discounttype;
    map['discountvalue'] = _discountvalue;
    map['discountamount'] = _discountamount;
    map['totalamount'] = _totalamount;
    map['balanceamount'] = _balanceamount;
    map['paymentmode'] = _paymentmode;
    if (_paymentdetails != null) {
      map['paymentdetails'] = _paymentdetails?.map((v) => v.toJson()).toList();
    }
    map['createdBy'] = _createdBy;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
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
