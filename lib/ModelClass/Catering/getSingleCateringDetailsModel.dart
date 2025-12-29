import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"_id":"694e1e6ae96f8018b5d5f8ef","locationId":{"_id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"date":"2025-12-26T05:33:33.593Z","customerId":{"_id":"69463bd0d85a3f7ede0c6c1e","name":"phone","phone":"9965784466"},"packageId":{"_id":"6948f15018768350f3a24893","name":"Raja","price":123},"items":[{"_id":"6896dd1e34000a85304985bd","name":"juice"},{"_id":"688b31b0f2e80392e2cd38e1","name":"chocolate"}],"addons":[{"_id":"69466f77eeae7ae2a8622f17","name":"Payasam","price":0},{"_id":"69466f6beeae7ae2a8622f0e","name":"Leaf","price":10}],"packageamount":369,"quantity":3,"addonsamount":30,"paymenttype":"FULLY","paidamount":339,"finalamount":339,"discounttype":"PERCENTAGE","discountvalue":15,"discountamount":60,"totalamount":399,"balanceamount":0,"paymentmode":"UPI","paymentdetails":[{"mode":"CASH","amount":100},{"mode":"UPI","amount":100}],"createdBy":{"_id":"6878971f0bc550868fe1b34b","name":"Saranya"},"createdAt":"2025-12-26T05:34:34.950Z","updatedAt":"2025-12-26T05:34:34.950Z","__v":0}

class GetSingleCateringDetailsModel {
  GetSingleCateringDetailsModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
  }

  GetSingleCateringDetailsModel.fromJson(dynamic json) {
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
  GetSingleCateringDetailsModel copyWith({
    bool? success,
    Data? data,
  }) =>
      GetSingleCateringDetailsModel(
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

/// _id : "694e1e6ae96f8018b5d5f8ef"
/// locationId : {"_id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"}
/// date : "2025-12-26T05:33:33.593Z"
/// customerId : {"_id":"69463bd0d85a3f7ede0c6c1e","name":"phone","phone":"9965784466"}
/// packageId : {"_id":"6948f15018768350f3a24893","name":"Raja","price":123}
/// items : [{"_id":"6896dd1e34000a85304985bd","name":"juice"},{"_id":"688b31b0f2e80392e2cd38e1","name":"chocolate"}]
/// addons : [{"_id":"69466f77eeae7ae2a8622f17","name":"Payasam","price":0},{"_id":"69466f6beeae7ae2a8622f0e","name":"Leaf","price":10}]
/// packageamount : 369
/// quantity : 3
/// addonsamount : 30
/// paymenttype : "FULLY"
/// paidamount : 339
/// finalamount : 339
/// discounttype : "PERCENTAGE"
/// discountvalue : 15
/// discountamount : 60
/// totalamount : 399
/// balanceamount : 0
/// paymentmode : "UPI"
/// paymentdetails : [{"mode":"CASH","amount":100},{"mode":"UPI","amount":100}]
/// createdBy : {"_id":"6878971f0bc550868fe1b34b","name":"Saranya"}
/// createdAt : "2025-12-26T05:34:34.950Z"
/// updatedAt : "2025-12-26T05:34:34.950Z"
/// __v : 0

class Data {
  Data({
    String? id,
    LocationId? locationId,
    String? date,
    CustomerId? customerId,
    PackageId? packageId,
    List<Items>? items,
    List<Addons>? addons,
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
    CreatedBy? createdBy,
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
    _locationId = json['locationId'] != null
        ? LocationId.fromJson(json['locationId'])
        : null;
    _date = json['date'];
    _customerId = json['customerId'] != null
        ? CustomerId.fromJson(json['customerId'])
        : null;
    _packageId = json['packageId'] != null
        ? PackageId.fromJson(json['packageId'])
        : null;
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(Items.fromJson(v));
      });
    }
    if (json['addons'] != null) {
      _addons = [];
      json['addons'].forEach((v) {
        _addons?.add(Addons.fromJson(v));
      });
    }
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
    _createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy'])
        : null;
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  LocationId? _locationId;
  String? _date;
  CustomerId? _customerId;
  PackageId? _packageId;
  List<Items>? _items;
  List<Addons>? _addons;
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
  CreatedBy? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Data copyWith({
    String? id,
    LocationId? locationId,
    String? date,
    CustomerId? customerId,
    PackageId? packageId,
    List<Items>? items,
    List<Addons>? addons,
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
    CreatedBy? createdBy,
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
  LocationId? get locationId => _locationId;
  String? get date => _date;
  CustomerId? get customerId => _customerId;
  PackageId? get packageId => _packageId;
  List<Items>? get items => _items;
  List<Addons>? get addons => _addons;
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
  CreatedBy? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    if (_locationId != null) {
      map['locationId'] = _locationId?.toJson();
    }
    map['date'] = _date;
    if (_customerId != null) {
      map['customerId'] = _customerId?.toJson();
    }
    if (_packageId != null) {
      map['packageId'] = _packageId?.toJson();
    }
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    if (_addons != null) {
      map['addons'] = _addons?.map((v) => v.toJson()).toList();
    }
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
    if (_createdBy != null) {
      map['createdBy'] = _createdBy?.toJson();
    }
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// _id : "6878971f0bc550868fe1b34b"
/// name : "Saranya"

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
  }) =>
      CreatedBy(
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

/// _id : "69466f77eeae7ae2a8622f17"
/// name : "Payasam"
/// price : 0

class Addons {
  Addons({
    String? id,
    String? name,
    num? price,
  }) {
    _id = id;
    _name = name;
    _price = price;
  }

  Addons.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _price = json['price'];
  }
  String? _id;
  String? _name;
  num? _price;
  Addons copyWith({
    String? id,
    String? name,
    num? price,
  }) =>
      Addons(
        id: id ?? _id,
        name: name ?? _name,
        price: price ?? _price,
      );
  String? get id => _id;
  String? get name => _name;
  num? get price => _price;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['price'] = _price;
    return map;
  }
}

/// _id : "6896dd1e34000a85304985bd"
/// name : "juice"

class Items {
  Items({
    String? id,
    String? name,
  }) {
    _id = id;
    _name = name;
  }

  Items.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
  }
  String? _id;
  String? _name;
  Items copyWith({
    String? id,
    String? name,
  }) =>
      Items(
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

/// _id : "6948f15018768350f3a24893"
/// name : "Raja"
/// price : 123

class PackageId {
  PackageId({
    String? id,
    String? name,
    num? price,
  }) {
    _id = id;
    _name = name;
    _price = price;
  }

  PackageId.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _price = json['price'];
  }
  String? _id;
  String? _name;
  num? _price;
  PackageId copyWith({
    String? id,
    String? name,
    num? price,
  }) =>
      PackageId(
        id: id ?? _id,
        name: name ?? _name,
        price: price ?? _price,
      );
  String? get id => _id;
  String? get name => _name;
  num? get price => _price;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['price'] = _price;
    return map;
  }
}

/// _id : "69463bd0d85a3f7ede0c6c1e"
/// name : "phone"
/// phone : "9965784466"

class CustomerId {
  CustomerId({
    String? id,
    String? name,
    String? phone,
  }) {
    _id = id;
    _name = name;
    _phone = phone;
  }

  CustomerId.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _phone = json['phone'];
  }
  String? _id;
  String? _name;
  String? _phone;
  CustomerId copyWith({
    String? id,
    String? name,
    String? phone,
  }) =>
      CustomerId(
        id: id ?? _id,
        name: name ?? _name,
        phone: phone ?? _phone,
      );
  String? get id => _id;
  String? get name => _name;
  String? get phone => _phone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['phone'] = _phone;
    return map;
  }
}

/// _id : "68c8ef05e42b9d827aeb4af3"
/// name : "TUTY"

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
  }) =>
      LocationId(
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
