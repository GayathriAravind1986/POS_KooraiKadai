import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class ReturnEvent {}

class FetchLocations extends ReturnEvent {}

class FetchCustomersForReturn extends ReturnEvent {
  final String locationId;
  final String search;

  FetchCustomersForReturn({
    required this.locationId,
    required this.search,
  });
}

class FetchReturnById extends ReturnEvent {
  final String returnId;
  FetchReturnById({required this.returnId});
}

class UpdateReturn extends ReturnEvent {
  final String returnId;
  final String date;
  final String locationId;
  final String customerId;
  final String creditEntryId;
  final num amount;
  final String description;

  UpdateReturn({
    required this.returnId,
    required this.date,
    required this.locationId,
    required this.customerId,
    required this.creditEntryId,
    required this.amount,
    required this.description,
  });
}

class FetchAllReturns extends ReturnEvent {
  final String fromDate;
  final String toDate;
  final String search;
  final int limit;
  final int offset;

  FetchAllReturns({
    required this.fromDate,
    required this.toDate,
    required this.search,
    required this.limit,
    required this.offset,
  });
}

class FetchCustomerBalance extends ReturnEvent {
  final String customerId;

  FetchCustomerBalance({
    required this.customerId,
  });
}

class CreateReturn extends ReturnEvent {
  final String date;
  final String locationId;
  final String customerId;
  final String creditId;
  final num price;
  final String description;

  CreateReturn({
    required this.date,
    required this.locationId,
    required this.customerId,
    required this.creditId,
    required this.price,
    required this.description,
  });
}

class ReturnBloc extends Bloc<ReturnEvent, dynamic> {
  ReturnBloc() : super(null) {

    // Fetch Locations
    on<FetchLocations>((event, emit) async {
      try {
        print("🔵 Fetching locations for returns...");

        final value = await ApiProvider().getLocationAPI();

        print("🟢 Get Location API Response received");
        print("🟢 Success: ${value.success}");
        print("🟢 Location: ${value.data?.locationName}");

        emit(value);
      } catch (error) {
        print("🔴 Error in FetchLocations bloc: $error");
        emit(error);
      }
    });

    // Fetch Customers for Returns
    on<FetchCustomersForReturn>((event, emit) async {
      try {
        print("🔵 Fetching customers for returns with: locationId=${event.locationId}, search=${event.search}");

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
        print("🔴 Error in FetchCustomersForReturn bloc: $error");
        emit(error);
      }
    });

    // Fetch All Returns
    on<FetchAllReturns>((event, emit) async {
      try {
        print("🔵 Fetching all returns with: fromDate=${event.fromDate}, toDate=${event.toDate}, search=${event.search}, limit=${event.limit}, offset=${event.offset}");

        final value = await ApiProvider().getAllReturnsAPI(
          event.fromDate,
          event.toDate,
          event.search,
          event.limit,
          event.offset,
        );

        print("🟢 All Returns API Response received");
        print("🟢 Success: ${value.success}");
        print("🟢 Data count: ${value.data?.length}");
        print("🟢 Total: ${value.total}");

        if (value.data != null && value.data!.isNotEmpty) {
          print("🟢 First return - Return Code: ${value.data?[0].returnCode}");
          print("🟢 First return - Price: ${value.data?[0].price}");
          print("🟢 First return - Customer: ${value.data?[0].customer?.name}");
        }

        emit(value);
      } catch (error) {
        print("🔴 Error in FetchAllReturns bloc: $error");
        emit(error);
      }
    });

    // Fetch Customer Balance
    on<FetchCustomerBalance>((event, emit) async {
      try {
        print("🔵 Fetching balance for customer: ${event.customerId}");

        final value = await ApiProvider().getBalanceAPIWithFilters(event.customerId);

        print("🟢 Get Customer Balance API Response received");
        print("🟢 Success: ${value.success}");
        print("🟢 Balance Records: ${value.data?.length}");

        if (value.data != null && value.data!.isNotEmpty) {
          print("🟢 First record - Credit Code: ${value.data?[0].creditCode}");
          print("🟢 First record - Total Credit: ${value.data?[0].totalCredit}");
          print("🟢 First record - Used Amount: ${value.data?[0].usedAmount}");
          print("🟢 First record - Balance Amount: ${value.data?[0].balanceAmount}");
        }

        emit(value);
      } catch (error) {
        print("🔴 Error in FetchCustomerBalance bloc: $error");
        emit(error);
      }
    });

    // Create Return
    on<CreateReturn>((event, emit) async {
      try {
        print("🔄 Creating return with:");
        print("🔄 Date: ${event.date}");
        print("🔄 Customer ID: ${event.customerId}");
        print("🔄 Credit ID: ${event.creditId}");
        print("🔄 Price: ${event.price}");
        print("🔄 Location ID: ${event.locationId}");

        final value = await ApiProvider().postReturnAPI(
          event.date,
          event.locationId,
          event.customerId,
          event.creditId,
          event.price,
          event.description,
        );

        if (value.success == true) {
          print("✅ Return created successfully!");
          print("✅ Return Code: ${value.data?.returnCode}");
          print("✅ Return ID: ${value.data?.id}");
          print("✅ Amount: ${value.data?.price}");
          print("✅ Created At: ${value.data?.createdAt}");

          // Emit success state
          emit({
            'type': 'return_success',
            'data': value,
            'message': 'Return created successfully!',
          });
        } else {
          print("❌ Return creation failed!");
          print("❌ Error: ${value.combinedErrorMessage}");
          print("❌ Status Code: ${value.errorResponse?.statusCode}");

          // Emit error state
          emit({
            'type': 'return_error',
            'error': value,
            'message': value.combinedErrorMessage ?? 'Return creation failed',
          });
        }
      } catch (error) {
        print("🔴 Error in CreateReturn bloc: $error");

        // Emit exception state
        emit({
          'type': 'return_exception',
          'error': error.toString(),
          'message': 'An unexpected error occurred while creating return',
        });
      }
    });
  }
}