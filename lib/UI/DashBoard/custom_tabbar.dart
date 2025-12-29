import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Alertbox/AlertDialogBox.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/Bloc/Catering/catering_bloc.dart';
import 'package:simple/Bloc/Report/report_bloc.dart';
import 'package:simple/Bloc/StockIn/stock_in_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/Bloc/Customer/customer_bloc.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/UI/Catering/catering_booking.dart';
import 'package:simple/UI/CustomAppBar/custom_appbar.dart';
import 'package:simple/UI/Customer/customer.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/UI/Order/order_list.dart';
import 'package:simple/UI/Order/order_tab_page.dart';
import 'package:simple/UI/StockIn/stock_in.dart';
import '../../Bloc/Report/accounts_report_bloc.dart';
import '../Accounts/accounts_report.dart';
import '../Report/report_order.dart';
import 'package:simple/Bloc/Accounts/credit_bloc.dart';
import 'package:simple/UI/Accounts/credit_screen.dart';

class DashBoardScreen extends StatelessWidget {
  final int? selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;
  const DashBoardScreen(
      {super.key, this.selectTab, this.existingOrder, this.isEditingOrder});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
      child: DashBoard(
        selectTab: selectTab,
        existingOrder: existingOrder,
        isEditingOrder: isEditingOrder,
      ),
    );
  }
}

class DashBoard extends StatefulWidget {
  final int? selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;

  const DashBoard({
    super.key,
    this.selectTab,
    this.existingOrder,
    this.isEditingOrder,
  });

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final GlobalKey<OrderViewViewState> orderAllTabKey =
  GlobalKey<OrderViewViewState>();
  final GlobalKey<FoodOrderingScreenViewState> foodKey =
  GlobalKey<FoodOrderingScreenViewState>();
  final GlobalKey<ReportViewViewState> reportKey =
  GlobalKey<ReportViewViewState>();
  final GlobalKey<StockViewViewState> stockKey =
  GlobalKey<StockViewViewState>();
  final GlobalKey<OrderTabViewViewState> orderTabKey =
  GlobalKey<OrderTabViewViewState>();
  final GlobalKey<CateringViewViewState> cateringKey =
  GlobalKey<CateringViewViewState>();
  final GlobalKey<CustomerViewViewState> customerKey =
  GlobalKey<CustomerViewViewState>();
  final GlobalKey<CateringViewViewState> cateringBookingKey =
  GlobalKey<CateringViewViewState>();
  final GlobalKey<ReturnReportViewState> returnReportKey =
  GlobalKey<ReturnReportViewState>();
  // Add Credit key
  final GlobalKey<CreditViewViewState> creditKey =
  GlobalKey<CreditViewViewState>();

  int selectedIndex = 0;
  bool orderLoad = false;
  bool hasRefreshedOrder = false;
  bool hasRefreshedReport = false;
  bool hasRefreshedStock = false;
  bool hasRefreshedCatering = false;
  bool hasRefreshedCustomer = false;
  bool hasRefreshedCateringBooking = false;
  bool hasRefreshedReturnReport = false;
  bool hasRefreshedCredit = false; // Add this

  @override
  void initState() {
    super.initState();
    if (widget.selectTab != null) {
      selectedIndex = widget.selectTab!;
    }
  }

  void _resetOrderTab() {
    final orderTabState = orderTabKey.currentState;
    if (orderTabState != null) {
      orderTabState.resetSelections();
    }
  }

  void _refreshOrders() {
    final orderAllTabState = orderAllTabKey.currentState;
    if (orderAllTabState != null) {
      orderAllTabState.refreshOrders();
    }
  }

  void _refreshHome() {
    final foodKeyState = foodKey.currentState;
    if (foodKeyState != null) {
      foodKeyState.refreshHome();
    }
  }

  void _refreshReport() {
    final reportKeyState = reportKey.currentState;
    if (reportKeyState != null) {
      reportKeyState.refreshReport();
    }
  }

  void _refreshStock() {
    final stockKeyState = stockKey.currentState;
    if (stockKeyState != null) {
      stockKeyState.refreshStock();
    }
  }

  void _refreshCatering() {
    final cateringKeyState = cateringKey.currentState;
    if (cateringKeyState != null) {
      cateringKeyState.refreshCatering();
    }
  }

  void _refreshCustomer() {
    final customerKeyState = customerKey.currentState;
    if (customerKeyState != null) {
      customerKeyState.refreshCustomer();
    }
  }

  void _refreshCateringBooking() {
    final cateringBookingKeyState = cateringBookingKey.currentState;
    if (cateringBookingKeyState != null) {
      cateringBookingKeyState.refreshCatering();
    }
  }

  void _refreshReturnReport() {
    final returnReportKeyState = returnReportKey.currentState;
    if (returnReportKeyState != null) {
      returnReportKeyState.refreshReturnReport();
    }
  }

  // Add this function for Credit
  void _refreshCredit() {
    final creditKeyState = creditKey.currentState;
    if (creditKeyState != null) {
      creditKeyState.refreshCredit();
    }
  }

  Widget mainContainer() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          selectedIndex: selectedIndex,
          onTabSelected: (index) {
            setState(() {
              selectedIndex = index;
            });

            // Reset all refresh flags
            hasRefreshedOrder = false;
            hasRefreshedReport = false;
            hasRefreshedStock = false;
            hasRefreshedCatering = false;
            hasRefreshedCustomer = false;
            hasRefreshedCateringBooking = false;
            hasRefreshedReturnReport = false;
            hasRefreshedCredit = false; // Reset credit flag

            // Set the appropriate flag and trigger refresh
            switch (index) {
              case 0: // Home
                hasRefreshedOrder = true;
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _refreshHome());
                break;
              case 1: // Orders
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshOrders();
                  _resetOrderTab();
                });
                break;
              case 2: // Report
                hasRefreshedReport = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshReport();
                });
                break;
              case 3: // Stockin
                hasRefreshedStock = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshStock();
                });
                break;
              case 4: // Catering (Main Catering page)
                hasRefreshedCatering = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshCatering();
                });
                break;
              case 5: // Customers
                hasRefreshedCustomer = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshCustomer();
                });
                break;
              case 6: // Catering Booking
                hasRefreshedCateringBooking = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshCateringBooking();
                });
                break;
              case 7: // Credit
                hasRefreshedCredit = true; // Set credit flag
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshCredit();
                });
                break;
              case 8: // Return
              // TODO: Implement Return page
                break;
              case 9: // Credit & Return Report
                hasRefreshedReturnReport = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshReturnReport();
                });
                break;
            }
          },
          onLogout: () {
            showLogoutDialog(context);
          },
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: [
            // Index 0: Home
            hasRefreshedOrder == true
                ? BlocProvider(
                create: (_) => FoodCategoryBloc(),
                child: FoodOrderingScreenView(
                  key: foodKey,
                  existingOrder: widget.existingOrder,
                  isEditingOrder: widget.isEditingOrder,
                  hasRefreshedOrder: hasRefreshedOrder,
                ))
                : BlocProvider(
              create: (_) => FoodCategoryBloc(),
              child: FoodOrderingScreen(
                key: foodKey,
                existingOrder: widget.existingOrder,
                isEditingOrder: widget.isEditingOrder,
                hasRefreshedOrder: hasRefreshedOrder,
              ),
            ),

            // Index 1: Orders
            OrdersTabbedScreen(
              key: PageStorageKey('OrdersTabbedScreen'),
              orderAllKey: orderAllTabKey,
              orderResetKey: orderTabKey,
            ),

            // Index 2: Report
            hasRefreshedReport == true
                ? BlocProvider(
                create: (_) => ReportTodayBloc(),
                child: ReportViewView(
                  key: reportKey,
                  hasRefreshedReport: hasRefreshedReport,
                ))
                : BlocProvider(
              create: (_) => ReportTodayBloc(),
              child: ReportView(
                key: reportKey,
                hasRefreshedReport: hasRefreshedReport,
              ),
            ),

            // Index 3: Stockin
            hasRefreshedStock == true
                ? BlocProvider(
                create: (_) => StockInBloc(),
                child: StockViewView(
                  key: stockKey,
                  hasRefreshedStock: hasRefreshedStock,
                ))
                : BlocProvider(
              create: (_) => StockInBloc(),
              child: StockView(
                key: stockKey,
                hasRefreshedStock: hasRefreshedStock,
              ),
            ),

            // Index 4: Catering (Main page)
            hasRefreshedCatering == true
                ? BlocProvider(
                create: (_) => CateringBloc(),
                child: CateringViewView(
                  key: cateringKey,
                  hasRefreshedCatering: hasRefreshedCatering,
                ))
                : BlocProvider(
              create: (_) => CateringBloc(),
              child: CateringView(
                key: cateringKey,
                hasRefreshedCatering: hasRefreshedCatering,
              ),
            ),

            // Index 5: Customers
            hasRefreshedCustomer == true
                ? BlocProvider(
                create: (_) => CustomerBloc(),
                child: CustomerViewView(
                  key: customerKey,
                  hasRefreshedCustomer: hasRefreshedCustomer,
                ))
                : BlocProvider(
              create: (_) => CustomerBloc(),
              child: CustomerView(
                key: customerKey,
                hasRefreshedCustomer: hasRefreshedCustomer,
              ),
            ),

            // Index 6: Catering Booking
            hasRefreshedCateringBooking == true
                ? BlocProvider(
                create: (_) => CateringBloc(),
                child: CateringViewView(
                  key: cateringBookingKey,
                  hasRefreshedCatering: hasRefreshedCateringBooking,
                ))
                : BlocProvider(
              create: (_) => CateringBloc(),
              child: CateringView(
                key: cateringBookingKey,
                hasRefreshedCatering: hasRefreshedCateringBooking,
              ),
            ),

            // Index 7: Credit
            hasRefreshedCredit == true
                ? BlocProvider(
                create: (_) => CreditBloc(),
                child: CreditViewView(
                  key: creditKey,
                  hasRefreshedCredit: hasRefreshedCredit,
                ))
                : BlocProvider(
              create: (_) => CreditBloc(),
              child: CreditView(
                key: creditKey,
                hasRefreshedCredit: hasRefreshedCredit,
              ),
            ),

            // Index 8: Return (Placeholder)
            const Center(
              child: Text(
                "Return Page - Coming Soon",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Index 9: Credit & Return Report
            hasRefreshedReturnReport == true
                ? BlocProvider(
                create: (_) => ReportBloc(),
                child: ReturnReportView(
                  key: returnReportKey,
                ))
                : BlocProvider(
              create: (_) => ReportBloc(),
              child: ReturnReportView(
                key: returnReportKey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DemoBloc, dynamic>(
      buildWhen: (previous, current) {
        return false;
      },
      builder: (context, state) {
        return mainContainer();
      },
    );
  }
}