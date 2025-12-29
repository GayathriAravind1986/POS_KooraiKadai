import 'dart:convert';
/// success : true
/// data : {"date":"2025-12-29T00:00:00.000Z","locationId":"68c8ef05e42b9d827aeb4af3","customerId":"694e36fe1d157e1ae77390eb","price":3000,"description":"","createdBy":"6878971f0bc550868fe1b34b","_id":"69524963682d49ef5c7a13c0","createdAt":"2025-12-29T09:26:59.332Z","updatedAt":"2025-12-29T09:26:59.332Z","creditCode":"CRD-20251229-0006","__v":0}

PostCreditModel postCreditModelFromJson(String str) => PostCreditModel.fromJson(json.decode(str));
String postCreditModelToJson(PostCreditModel data) => json.encode(data.toJson());
class PostCreditModel {
  PostCreditModel({
      bool? success, 
      Data? data,}){
    _success = success;
    _data = data;
}

  PostCreditModel.fromJson(dynamic json) {
    _success = json['success'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _success;
  Data? _data;
  PostCreditModel copyWith({  bool? success,
  Data? data,
  }) => PostCreditModel(  success: success ?? _success,
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
    return map;
  }

}

/// date : "2025-12-29T00:00:00.000Z"
/// locationId : "68c8ef05e42b9d827aeb4af3"
/// customerId : "694e36fe1d157e1ae77390eb"
/// price : 3000
/// description : ""
/// createdBy : "6878971f0bc550868fe1b34b"
/// _id : "69524963682d49ef5c7a13c0"
/// createdAt : "2025-12-29T09:26:59.332Z"
/// updatedAt : "2025-12-29T09:26:59.332Z"
/// creditCode : "CRD-20251229-0006"
/// __v : 0

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      String? date, 
      String? locationId, 
      String? customerId, 
      num? price, 
      String? description, 
      String? createdBy, 
      String? id, 
      String? createdAt, 
      String? updatedAt, 
      String? creditCode, 
      num? v,}){
    _date = date;
    _locationId = locationId;
    _customerId = customerId;
    _price = price;
    _description = description;
    _createdBy = createdBy;
    _id = id;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _creditCode = creditCode;
    _v = v;
}

  Data.fromJson(dynamic json) {
    _date = json['date'];
    _locationId = json['locationId'];
    _customerId = json['customerId'];
    _price = json['price'];
    _description = json['description'];
    _createdBy = json['createdBy'];
    _id = json['_id'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _creditCode = json['creditCode'];
    _v = json['__v'];
  }
  String? _date;
  String? _locationId;
  String? _customerId;
  num? _price;
  String? _description;
  String? _createdBy;
  String? _id;
  String? _createdAt;
  String? _updatedAt;
  String? _creditCode;
  num? _v;
Data copyWith({  String? date,
  String? locationId,
  String? customerId,
  num? price,
  String? description,
  String? createdBy,
  String? id,
  String? createdAt,
  String? updatedAt,
  String? creditCode,
  num? v,
}) => Data(  date: date ?? _date,
  locationId: locationId ?? _locationId,
  customerId: customerId ?? _customerId,
  price: price ?? _price,
  description: description ?? _description,
  createdBy: createdBy ?? _createdBy,
  id: id ?? _id,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  creditCode: creditCode ?? _creditCode,
  v: v ?? _v,
);
  String? get date => _date;
  String? get locationId => _locationId;
  String? get customerId => _customerId;
  num? get price => _price;
  String? get description => _description;
  String? get createdBy => _createdBy;
  String? get id => _id;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get creditCode => _creditCode;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['date'] = _date;
    map['locationId'] = _locationId;
    map['customerId'] = _customerId;
    map['price'] = _price;
    map['description'] = _description;
    map['createdBy'] = _createdBy;
    map['_id'] = _id;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['creditCode'] = _creditCode;
    map['__v'] = _v;
    return map;
  }

}