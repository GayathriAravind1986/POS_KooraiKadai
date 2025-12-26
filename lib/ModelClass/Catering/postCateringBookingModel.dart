import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"locationId":"689097eb8f2278af1da6b97d","date":"2025-12-23T00:00:00.000Z","customerId":"694534c47ac0ecf2c38c8753","packageId":"694648d49ca4384d315f93be","items":["688b3053f2e80392e2cd37b2","688b31b0f2e80392e2cd38e1"],"addons":["69466f6beeae7ae2a8622f0e","69466f77eeae7ae2a8622f17"],"packageamount":500,"quantity":2,"addonsamount":100,"paymenttype":"PARTIALLY","paidamount":100,"finalamount":600,"discounttype":"FIXED","discountvalue":10,"discountamount":50,"totalamount":500,"balanceamount":500,"paymentmode":"CASH","paymentdetails":[{"mode":"CASH","amount":100},{"mode":"UPI","amount":100}],"createdBy":"68874a73138aa2dcca66347c","_id":"694e33c31d157e1ae7738fdc","createdAt":"2025-12-26T07:05:39.717Z","updatedAt":"2025-12-26T07:05:39.717Z","__v":0}

class PostCateringBookingModel {
  PostCateringBookingModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
  }

  PostCateringBookingModel.fromJson(dynamic json) {
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
  PostCateringBookingModel copyWith({
    bool? success,
    Data? data,
  }) =>
      PostCateringBookingModel(
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

/// locationId : "689097eb8f2278af1da6b97d"
/// date : "2025-12-23T00:00:00.000Z"
/// customerId : "694534c47ac0ecf2c38c8753"
/// packageId : "694648d49ca4384d315f93be"
/// items : ["688b3053f2e80392e2cd37b2","688b31b0f2e80392e2cd38e1"]
/// addons : ["69466f6beeae7ae2a8622f0e","69466f77eeae7ae2a8622f17"]
/// packageamount : 500
/// quantity : 2
/// addonsamount : 100
/// paymenttype : "PARTIALLY"
/// paidamount : 100
/// finalamount : 600
/// discounttype : "FIXED"
/// discountvalue : 10
/// discountamount : 50
/// totalamount : 500
/// balanceamount : 500
/// paymentmode : "CASH"
/// paymentdetails : [{"mode":"CASH","amount":100},{"mode":"UPI","amount":100}]
/// createdBy : "68874a73138aa2dcca66347c"
/// _id : "694e33c31d157e1ae7738fdc"
/// createdAt : "2025-12-26T07:05:39.717Z"
/// updatedAt : "2025-12-26T07:05:39.717Z"
/// __v : 0

class Data {
  Data({
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
    String? id,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
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
    _id = id;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Data.fromJson(dynamic json) {
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
    _id = json['_id'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
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
  String? _id;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Data copyWith({
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
    String? id,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      Data(
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
        id: id ?? _id,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
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
  String? get id => _id;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
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
    map['_id'] = _id;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// mode : "CASH"
/// amount : 100

class Paymentdetails {
  Paymentdetails({
    String? mode,
    num? amount,
  }) {
    _mode = mode;
    _amount = amount;
  }

  Paymentdetails.fromJson(dynamic json) {
    _mode = json['mode'];
    _amount = json['amount'];
  }
  String? _mode;
  num? _amount;
  Paymentdetails copyWith({
    String? mode,
    num? amount,
  }) =>
      Paymentdetails(
        mode: mode ?? _mode,
        amount: amount ?? _amount,
      );
  String? get mode => _mode;
  num? get amount => _amount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['mode'] = _mode;
    map['amount'] = _amount;
    return map;
  }
}
