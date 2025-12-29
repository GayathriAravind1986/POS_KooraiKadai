import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';
import '../Customer/customer_bloc.dart';

abstract class CreditEvent {}

class FetchCreditById extends CreditEvent {
  final String creditId;

  FetchCreditById({required this.creditId});
}

class FetchLocations extends CreditEvent {}

class FetchAllCredits extends CreditEvent {
  final String fromDate;
  final String toDate;
  final String search;
  final int limit;
  final int offset;

  FetchAllCredits({
    required this.fromDate,
    required this.toDate,
    required this.search,
    required this.limit,
    required this.offset,
  });
}

class CreateCredit extends CreditEvent {
  final String date;
  final String locationId;
  final String customerId;
  final String customerName;
  final num price;
  final String description;

  CreateCredit({
    required this.date,
    required this.locationId,
    required this.customerId,
    required this.customerName,
    required this.price,
    required this.description,
  });
}

// UPDATE CREDIT EVENT
class UpdateCredit extends CreditEvent {
  final String creditId;
  final String date;
  final String locationId;
  final String customerId;
  final String customerName;
  final num price;
  final String description;

  UpdateCredit({
    required this.creditId,
    required this.date,
    required this.locationId,
    required this.customerId,
    required this.customerName,
    required this.price,
    required this.description,
  });
}

class FetchCustomersForCredit extends CreditEvent {
  final String locationId;
  final String search;

  FetchCustomersForCredit({
    required this.locationId,
    required this.search,
  });
}

class CreditBloc extends Bloc<CreditEvent, dynamic> {
  CreditBloc() : super(null) {

    on<FetchCreditById>((event, emit) async {
      try {
        print("🔵 Fetching credit by ID: ${event.creditId}");

        final value = await ApiProvider().getCreditByIdAPI(event.creditId);

        print("🟢 Get Credit by ID API Response received");
        print("🟢 Success: ${value.success}");
        print("🟢 Credit Code: ${value.data?.creditCode}");
        print("🟢 Customer Name: ${value.data?.customerId?.name}");

        emit(value);
      } catch (error) {
        print("🔴 Error in FetchCreditById bloc: $error");
        emit(error);
      }
    });

    on<FetchLocations>((event, emit) async {
      try {
        final value = await ApiProvider().getLocationAPI();
        emit(value);
      } catch (error) {
        emit(error);
      }
    });

    on<FetchAllCredits>((event, emit) async {
      try {
        print("🔵 Fetching all credits with: fromDate=${event.fromDate}, toDate=${event.toDate}, search=${event.search}, limit=${event.limit}, offset=${event.offset}");

        final value = await ApiProvider().getAllCreditsAPI(
          event.fromDate,
          event.toDate,
          event.search,
          event.limit,
          event.offset,
        );

        print("🟢 All Credits API Response received");
        print("🟢 Success: ${value.success}");
        print("🟢 Data count: ${value.data?.length}");
        print("🟢 Total: ${value.total}");

        emit(value);
      } catch (error) {
        print("🔴 Error in FetchAllCredits bloc: $error");
        emit(error);
      }
    });

    on<CreateCredit>((event, emit) async {
      try {
        print("🔵 Creating credit with: customerId=${event.customerId}, price=${event.price}, locationId=${event.locationId}");

        final value = await ApiProvider().postCreditAPI(
          event.date,
          event.locationId,
          event.customerId,
          event.customerName,
          event.price,
          event.description,
        );

        print("🟢 Create Credit API Response received");
        print("🟢 Success: ${value.success}");
        print("🟢 Credit Code: ${value.data?.creditCode}");
        print("🟢 Credit ID: ${value.data?.id}");

        emit(value);
      } catch (error) {
        print("🔴 Error in CreateCredit bloc: $error");
        emit(error);
      }
    });

    // UPDATE CREDIT EVENT HANDLER
    on<UpdateCredit>((event, emit) async {
      try {
        print("🔄 Updating credit with ID: ${event.creditId}");
        print("🔄 Update data - date: ${event.date}, customerId: ${event.customerId}, price: ${event.price}");

        // Prepare payload
        final Map<String, dynamic> payload = {
          "date": event.date,
          "customerId": event.customerId,
          "customerName": event.customerName,
          "price": event.price,
          "description": event.description,
          "locationId": event.locationId,
        };

        print("📤 Sending payload: $payload");

        final value = await ApiProvider().updateCreditAPI(
          event.creditId,
          payload,
        );

        if (value.success == true) {
          print("✅ Credit updated successfully!");
          print("✅ Updated Credit Code: ${value.data?.creditCode}");
          print("✅ Updated Price: ${value.data?.price}");
          print("✅ Updated At: ${value.data?.updatedAt}");

          // Emit success state
          emit({
            'type': 'update_success',
            'data': value,
            'message': 'Credit updated successfully!',
          });
        } else {
          print("❌ Credit update failed!");
          print("❌ Error: ${value.combinedErrorMessage}");
          print("❌ Status Code: ${value.errorResponse?.statusCode}");

          // Emit error state
          emit({
            'type': 'update_error',
            'error': value,
            'message': value.combinedErrorMessage ?? 'Update failed',
          });
        }
      } catch (error) {
        print("🔴 Error in UpdateCredit bloc: $error");

        // Emit exception state
        emit({
          'type': 'update_exception',
          'error': error.toString(),
          'message': 'An unexpected error occurred while updating credit',
        });
      }
    });

    on<FetchCustomersForCredit>((event, emit) async {
      try {
        print("🔵 Fetching customers for credit with: locationId=${event.locationId}, search=${event.search}");

        final value = await ApiProvider().getCustomersForCreditsAPI(
          event.locationId,
          event.search,
        );

        print("🟢 Fetch Customers API Response received");
        print("🟢 Success: ${value.success}");
        print("🟢 Data count: ${value.data?.length}");
        print("🟢 Total: ${value.total}");

        emit(value);
      } catch (error) {
        print("🔴 Error in FetchCustomersForCredit bloc: $error");
        emit(error);
      }
    });
  }
}