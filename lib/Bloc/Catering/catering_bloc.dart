import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class CateringEvent {}

class CateringBooking extends CateringEvent {}
class CateringLocation extends CateringEvent {}
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
  }
}
