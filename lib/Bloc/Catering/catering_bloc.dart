import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class CateringEvent {}

class CateringBooking extends CateringEvent {}

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

class CateringBloc extends Bloc<CateringEvent, dynamic> {
  CateringBloc() : super(dynamic) {
    on<CateringBooking>((event, emit) async {
      await ApiProvider().cateringListAPI().then((value) {
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
  }
}
