import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : [{"id":"6948f15018768350f3a24893","name":"Raja","price":123,"image":"https://res.cloudinary.com/dm6wrm7vf/image/upload/v1766388714/packages/eixf6yb5btlk7bnkynch.jpg","sortOrder":0,"location":{"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"},"addons":[{"_id":"69466f77eeae7ae2a8622f17","name":"Payasam","isFree":true,"price":0,"isActive":true},{"_id":"69466f6beeae7ae2a8622f0e","name":"Leaf","isFree":false,"price":10,"isActive":true}],"items":[{"_id":"6896dd1e34000a85304985bd","name":"juice"},{"_id":"688b31b0f2e80392e2cd38e1","name":"chocolate"},{"_id":"688c51380e035b08f8f1564a","name":"Food"},{"_id":"688b0a60fc5ac9c09f2e3b69","name":"Special product"}],"createdBy":"Saranya","createdAt":"2025-12-22","updatedAt":"2025-12-22T10:16:05.995Z"}]
/// total : 1

class GetPackageModel {
  GetPackageModel({
    bool? success,
    List<Data>? data,
    num? total,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
    _total = total;
  }

  GetPackageModel.fromJson(dynamic json) {
    _success = json['success'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
    _total = json['total'];
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  bool? _success;
  List<Data>? _data;
  num? _total;
  ErrorResponse? errorResponse;
  GetPackageModel copyWith({
    bool? success,
    List<Data>? data,
    num? total,
  }) =>
      GetPackageModel(
        success: success ?? _success,
        data: data ?? _data,
        total: total ?? _total,
      );
  bool? get success => _success;
  List<Data>? get data => _data;
  num? get total => _total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['total'] = _total;
    if (errorResponse != null) {
      map['errors'] = errorResponse!.toJson();
    }
    return map;
  }
}

/// id : "6948f15018768350f3a24893"
/// name : "Raja"
/// price : 123
/// image : "https://res.cloudinary.com/dm6wrm7vf/image/upload/v1766388714/packages/eixf6yb5btlk7bnkynch.jpg"
/// sortOrder : 0
/// location : {"id":"68c8ef05e42b9d827aeb4af3","name":"TUTY"}
/// addons : [{"_id":"69466f77eeae7ae2a8622f17","name":"Payasam","isFree":true,"price":0,"isActive":true},{"_id":"69466f6beeae7ae2a8622f0e","name":"Leaf","isFree":false,"price":10,"isActive":true}]
/// items : [{"_id":"6896dd1e34000a85304985bd","name":"juice"},{"_id":"688b31b0f2e80392e2cd38e1","name":"chocolate"},{"_id":"688c51380e035b08f8f1564a","name":"Food"},{"_id":"688b0a60fc5ac9c09f2e3b69","name":"Special product"}]
/// createdBy : "Saranya"
/// createdAt : "2025-12-22"
/// updatedAt : "2025-12-22T10:16:05.995Z"

class Data {
  Data({
    String? id,
    String? name,
    num? price,
    String? image,
    num? sortOrder,
    Location? location,
    List<Addons>? addons,
    List<Items>? items,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _name = name;
    _price = price;
    _image = image;
    _sortOrder = sortOrder;
    _location = location;
    _addons = addons;
    _items = items;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _price = json['price'];
    _image = json['image'];
    _sortOrder = json['sortOrder'];
    _location =
    json['location'] != null ? Location.fromJson(json['location']) : null;
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
    _createdBy = json['createdBy'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  String? _id;
  String? _name;
  num? _price;
  String? _image;
  num? _sortOrder;
  Location? _location;
  List<Addons>? _addons;
  List<Items>? _items;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  Data copyWith({
    String? id,
    String? name,
    num? price,
    String? image,
    num? sortOrder,
    Location? location,
    List<Addons>? addons,
    List<Items>? items,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        name: name ?? _name,
        price: price ?? _price,
        image: image ?? _image,
        sortOrder: sortOrder ?? _sortOrder,
        location: location ?? _location,
        addons: addons ?? _addons,
        items: items ?? _items,
        createdBy: createdBy ?? _createdBy,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  String? get id => _id;
  String? get name => _name;
  num? get price => _price;
  String? get image => _image;
  num? get sortOrder => _sortOrder;
  Location? get location => _location;
  List<Addons>? get addons => _addons;
  List<Items>? get items => _items;
  String? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['price'] = _price;
    map['image'] = _image;
    map['sortOrder'] = _sortOrder;
    if (_location != null) {
      map['location'] = _location?.toJson();
    }
    if (_addons != null) {
      map['addons'] = _addons?.map((v) => v.toJson()).toList();
    }
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    map['createdBy'] = _createdBy;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
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

/// id : "68c8ef05e42b9d827aeb4af3"
/// name : "TUTY"

class Location {
  Location({
    String? id,
    String? name,
  }) {
    _id = id;
    _name = name;
  }

  Location.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
  }
  String? _id;
  String? _name;
  Location copyWith({
    String? id,
    String? name,
  }) =>
      Location(
        id: id ?? _id,
        name: name ?? _name,
      );
  String? get id => _id;
  String? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    return map;
  }
}
