import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class CateringEvent {}

class CateringBooking extends CateringEvent {
  String search;
  String locationId;
  String cusId;
  String fromDate;
  String toDate;
  int offset;
  int limit;

  CateringBooking(
      this.search,
      this.locationId,
      this.cusId,
      this.fromDate,
      this.toDate,
      this.offset,
      this.limit,
      );
}

class CateringLocation extends CateringEvent {}

class CateringCustomer extends CateringEvent {
  String locationId;
  CateringCustomer(this.locationId);
}

class CateringPackage extends CateringEvent {
  String locationId;
  CateringPackage(this.locationId);
}

class CateringItemAddons extends CateringEvent {
  String packageId;
  CateringItemAddons(this.packageId);
}

class SaveCatering extends CateringEvent {
  final String orderPayloadJson;
  SaveCatering(this.orderPayloadJson);
}

class CateringById extends CateringEvent {
  String cateringId;
  CateringById(this.cateringId);
}

class UpdateCatering extends CateringEvent {
  final String orderPayloadJson;
  String? cateringId;
  UpdateCatering(this.orderPayloadJson, this.cateringId);
}

class DeleteCatering extends CateringEvent {
  String? cateringId;
  DeleteCatering(this.cateringId);
}

class CateringBloc extends Bloc<CateringEvent, dynamic> {
  CateringBloc() : super(dynamic) {
    on<CateringBooking>((event, emit) async {
      await ApiProvider()
          .cateringListAPI(event.search, event.locationId, event.cusId,
          event.fromDate, event.toDate, event.offset, event.limit)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<CateringLocation>((event, emit) async {
      await ApiProvider().getLocationAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<CateringCustomer>((event, emit) async {
      await ApiProvider().getCustomerAPI(event.locationId).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<CateringPackage>((event, emit) async {
      await ApiProvider().getPackageAPI(event.locationId).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<CateringItemAddons>((event, emit) async {
      await ApiProvider().getItemAddonsAPI(event.packageId).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<SaveCatering>((event, emit) async {
      await ApiProvider()
          .postSaveCateringAPI(event.orderPayloadJson)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<CateringById>((event, emit) async {
      await ApiProvider().getSingleCateringAPI(event.cateringId).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<UpdateCatering>((event, emit) async {
      await ApiProvider()
          .putCateringBookingAPI(event.orderPayloadJson, event.cateringId)
          .then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<DeleteCatering>((event, emit) async {
      await ApiProvider().deleteCateringAPI(event.cateringId).then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
  }
}
