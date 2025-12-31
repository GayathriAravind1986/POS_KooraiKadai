import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class CustomerEvent {}

class FetchLocations extends CustomerEvent {}

class FetchAllCustomers extends CustomerEvent {
  final String search;
  final String locId;
   int limit;
  final int offset;
  final String fromdate;
  final String todate;

  FetchAllCustomers(this.search, this.locId, this.limit, this.offset,this.fromdate, this.todate);
}

class SaveCustomer extends CustomerEvent {
  final String name;
  final String phone;
  final String email;
  final String address;
  final String locId;

  SaveCustomer(this.name, this.phone, this.email, this.address, this.locId);
}

class FetchCustomerById extends CustomerEvent {
  final String customerId;

  FetchCustomerById(this.customerId);
}

class UpdateCustomer extends CustomerEvent {
  final String customerId;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String locId;

  UpdateCustomer(this.customerId, this.name, this.phone, this.email, this.address, this.locId);
}

class CustomerBloc extends Bloc<CustomerEvent, dynamic> {
  CustomerBloc() : super(null) {
    on<FetchLocations>((event, emit) async {
      try {
        final value = await ApiProvider().getLocationAPI();
        emit(value);
      } catch (error) {
        emit(error);
      }
    });

    on<FetchAllCustomers>((event, emit) async {
      try {
        final value = await ApiProvider().getAllCustomerAPI(
            event.search,
            event.locId,
            event.limit,
            event.offset,
            event.fromdate,
            event.todate
        );
        emit(value);
      } catch (error) {
        emit(error);
      }
    });

    on<SaveCustomer>((event, emit) async {
      try {
        final value = await ApiProvider().postCustomerAPI(
            event.name,
            event.phone,
            event.email,
            event.address,
            event.locId
        );
        emit(value);
      } catch (error) {
        emit(error);
      }
    });

    on<FetchCustomerById>((event, emit) async {
      try {
        final value = await ApiProvider().getCustomerByIdAPI(event.customerId);
        emit(value);
      } catch (error) {
        emit(error);
      }
    });

    on<UpdateCustomer>((event, emit) async {
      try {
        final value = await ApiProvider().putCustomerAPI(
            event.customerId,
            event.name,
            event.phone,
            event.email,
            event.address,
            event.locId
        );
        emit(value);
      } catch (error) {
        emit(error);
      }
    });
  }
}