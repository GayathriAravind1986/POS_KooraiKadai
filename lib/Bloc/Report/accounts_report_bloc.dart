import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class ReportEvent {}

class FetchReturnReport extends ReportEvent {
  final String fromDate;
  final String toDate;
  final String search;
  final int limit;
  final int offset;

  FetchReturnReport({
    required this.fromDate,
    required this.toDate,
    required this.search,
    required this.limit,
    required this.offset,
  });
}

class ReportBloc extends Bloc<ReportEvent, dynamic> {
  ReportBloc() : super(null) {

    on<FetchReturnReport>((event, emit) async {
      try {
        print("🔵 Fetching report with: fromDate=${event.fromDate}, toDate=${event.toDate}, limit=${event.limit}, offset=${event.offset}");

        final value = await ApiProvider().getReturnReportAPI(
          event.fromDate,
          event.toDate,
          event.search,
          event.limit,
          event.offset,
        );

        print("🟢 API Response received: ${value.toJson()}");
        print("🟢 Success: ${value.success}");
        print("🟢 Data count: ${value.data?.length}");
        // print("🟢 Total count: ${value.totalCount}");

        emit(value);
      } catch (error) {
        print("🔴 Error in bloc: $error");
        emit(error);
      }
    });

  }
}