import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"_id":"6948f15018768350f3a24893","name":"Raja","price":123,"sortOrder":0,"locationId":{"_id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"addons":[{"_id":"69466f77eeae7ae2a8622f17","name":"Payasam","isFree":true,"price":0,"isActive":true},{"_id":"69466f6beeae7ae2a8622f0e","name":"Leaf","isFree":false,"price":10,"isActive":true}],"items":[{"_id":"6896dd1e34000a85304985bd","name":"juice"},{"_id":"688b31b0f2e80392e2cd38e1","name":"chocolate"},{"_id":"688c51380e035b08f8f1564a","name":"Food"},{"_id":"688b0a60fc5ac9c09f2e3b69","name":"Special product"}],"isActive":true,"createdBy":{"_id":"6878971f0bc550868fe1b34b","name":"Saranya"},"createdAt":"2025-12-22T07:20:48.495Z","updatedAt":"2025-12-22T10:16:05.995Z","__v":0,"image":"https://res.cloudinary.com/dm6wrm7vf/image/upload/v1766388714/packages/eixf6yb5btlk7bnkynch.jpg"}

class GetItemAddonsForPackageModel {
  GetItemAddonsForPackageModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
  }

  GetItemAddonsForPackageModel.fromJson(dynamic json) {
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
  GetItemAddonsForPackageModel copyWith({
    bool? success,
    Data? data,
  }) =>
      GetItemAddonsForPackageModel(
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

/// _id : "6948f15018768350f3a24893"
/// name : "Raja"
/// price : 123
/// sortOrder : 0
/// locationId : {"_id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"}
/// addons : [{"_id":"69466f77eeae7ae2a8622f17","name":"Payasam","isFree":true,"price":0,"isActive":true},{"_id":"69466f6beeae7ae2a8622f0e","name":"Leaf","isFree":false,"price":10,"isActive":true}]
/// items : [{"_id":"6896dd1e34000a85304985bd","name":"juice"},{"_id":"688b31b0f2e80392e2cd38e1","name":"chocolate"},{"_id":"688c51380e035b08f8f1564a","name":"Food"},{"_id":"688b0a60fc5ac9c09f2e3b69","name":"Special product"}]
/// isActive : true
/// createdBy : {"_id":"6878971f0bc550868fe1b34b","name":"Saranya"}
/// createdAt : "2025-12-22T07:20:48.495Z"
/// updatedAt : "2025-12-22T10:16:05.995Z"
/// __v : 0
/// image : "https://res.cloudinary.com/dm6wrm7vf/image/upload/v1766388714/packages/eixf6yb5btlk7bnkynch.jpg"

class Data {
  Data({
    String? id,
    String? name,
    num? price,
    num? sortOrder,
    LocationId? locationId,
    List<Addons>? addons,
    List<Items>? items,
    bool? isActive,
    CreatedBy? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
    String? image,
  }) {
    _id = id;
    _name = name;
    _price = price;
    _sortOrder = sortOrder;
    _locationId = locationId;
    _addons = addons;
    _items = items;
    _isActive = isActive;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
    _image = image;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _price = json['price'];
    _sortOrder = json['sortOrder'];
    _locationId = json['locationId'] != null
        ? LocationId.fromJson(json['locationId'])
        : null;
    if (json['addons'] != null) {
      _addons = [];
      json['addons'].forEach((v) {
        _addons?.add(Addons.fromJson(v));
      });
    }
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(Items.fromJson(v));
      });
    }
    _isActive = json['isActive'];
    _createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy'])
        : null;
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
    _image = json['image'];
  }
  String? _id;
  String? _name;
  num? _price;
  num? _sortOrder;
  LocationId? _locationId;
  List<Addons>? _addons;
  List<Items>? _items;
  bool? _isActive;
  CreatedBy? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  String? _image;
  Data copyWith({
    String? id,
    String? name,
    num? price,
    num? sortOrder,
    LocationId? locationId,
    List<Addons>? addons,
    List<Items>? items,
    bool? isActive,
    CreatedBy? createdBy,
    String? createdAt,
    String? updatedAt,
    num? v,
    String? image,
  }) =>
      Data(
        id: id ?? _id,
        name: name ?? _name,
        price: price ?? _price,
        sortOrder: sortOrder ?? _sortOrder,
        locationId: locationId ?? _locationId,
        addons: addons ?? _addons,
        items: items ?? _items,
        isActive: isActive ?? _isActive,
        createdBy: createdBy ?? _createdBy,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
        image: image ?? _image,
      );
  String? get id => _id;
  String? get name => _name;
  num? get price => _price;
  num? get sortOrder => _sortOrder;
  LocationId? get locationId => _locationId;
  List<Addons>? get addons => _addons;
  List<Items>? get items => _items;
  bool? get isActive => _isActive;
  CreatedBy? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;
  String? get image => _image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['price'] = _price;
    map['sortOrder'] = _sortOrder;
    if (_locationId != null) {
      map['locationId'] = _locationId?.toJson();
    }
    if (_addons != null) {
      map['addons'] = _addons?.map((v) => v.toJson()).toList();
    }
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    map['isActive'] = _isActive;
    if (_createdBy != null) {
      map['createdBy'] = _createdBy?.toJson();
    }
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    map['image'] = _image;
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

/// _id : "69466f77eeae7ae2a8622f17"
/// name : "Payasam"
/// isFree : true
/// price : 0
/// isActive : true

class Addons {
  Addons({
    String? id,
    String? name,
    bool? isFree,
    num? price,
    bool? isActive,
  }) {
    _id = id;
    _name = name;
    _isFree = isFree;
    _price = price;
    _isActive = isActive;
  }

  Addons.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _isFree = json['isFree'];
    _price = json['price'];
    _isActive = json['isActive'];
  }
  String? _id;
  String? _name;
  bool? _isFree;
  num? _price;
  bool? _isActive;
  Addons copyWith({
    String? id,
    String? name,
    bool? isFree,
    num? price,
    bool? isActive,
  }) =>
      Addons(
        id: id ?? _id,
        name: name ?? _name,
        isFree: isFree ?? _isFree,
        price: price ?? _price,
        isActive: isActive ?? _isActive,
      );
  String? get id => _id;
  String? get name => _name;
  bool? get isFree => _isFree;
  num? get price => _price;
  bool? get isActive => _isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['isFree'] = _isFree;
    map['price'] = _price;
    map['isActive'] = _isActive;
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
