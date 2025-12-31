import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Api/apiProvider.dart';

abstract class ReportEvent {}

class FetchReturnReport extends ReportEvent {
  final String fromDate;
  final String toDate;
  final String search;
  final int limit;
  final int offset;
  final String locid;

  FetchReturnReport({
    required this.fromDate,
    required this.toDate,
    required this.search,
    required this.limit,
    required this.offset,
    required this.locid,
  });
}

class ReportBloc extends Bloc<ReportEvent, dynamic> {
  ReportBloc() : super(null) {
    on<FetchReturnReport>((event, emit) async {
      try {
        final value = await ApiProvider().getReturnReportAPI(
          event.fromDate,
          event.toDate,
          event.search,
          event.limit,
          event.offset,
          event.locid
        );

        emit(value);
      } catch (error) {
        emit(error);
      }
    });
  }
}
