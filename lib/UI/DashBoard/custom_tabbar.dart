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
import 'package:simple/UI/Customer/customer.dart';
import '../Report/report_order.dart';

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
  // Fixed: Use the correct ViewState type for Customers
  final GlobalKey<CustomerViewViewState> customerKey =
  GlobalKey<CustomerViewViewState>();

  int selectedIndex = 0;
  bool orderLoad = false;
  bool hasRefreshedOrder = false;
  bool hasRefreshedReport = false;
  bool hasRefreshedStock = false;
  bool hasRefreshedCatering = false;
  bool hasRefreshedCustomer = false; // Added flag for customers

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

  // Added refresh logic for customers
  void _refreshCustomer() {
    final customerKeyState = customerKey.currentState;
    if (customerKeyState != null) {
      customerKeyState.refreshCustomer();
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
            if (index == 0 && !hasRefreshedOrder) {
              hasRefreshedOrder = true;
              hasRefreshedReport = false;
              hasRefreshedStock = false;
              hasRefreshedCatering = false;
              hasRefreshedCustomer = false;
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _refreshHome());
            }
            if (index == 1) {
              hasRefreshedOrder = false;
              hasRefreshedReport = false;
              hasRefreshedStock = false;
              hasRefreshedCatering = false;
              hasRefreshedCustomer = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshOrders();
                _resetOrderTab();
              });
            }
            if (index == 2 && !hasRefreshedReport) {
              hasRefreshedOrder = false;
              hasRefreshedReport = true;
              hasRefreshedStock = false;
              hasRefreshedCatering = false;
              hasRefreshedCustomer = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshReport();
              });
            }
            if (index == 3 && !hasRefreshedStock) {
              hasRefreshedOrder = false;
              hasRefreshedReport = false;
              hasRefreshedStock = true;
              hasRefreshedCatering = false;
              hasRefreshedCustomer = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshStock();
              });
            }
            if (index == 4 && !hasRefreshedCatering) {
              hasRefreshedOrder = false;
              hasRefreshedReport = false;
              hasRefreshedStock = false;
              hasRefreshedCatering = true;
              hasRefreshedCustomer = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshCatering();
              });
            }
            // Fixed logic for index 5 (Customers)
            if (index == 5 && !hasRefreshedCustomer) {
              hasRefreshedOrder = false;
              hasRefreshedReport = false;
              hasRefreshedStock = false;
              hasRefreshedCatering = false;
              hasRefreshedCustomer = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshCustomer();
              });
            }
          },
          onLogout: () {
            showLogoutDialog(context);
          },
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: [
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
            OrdersTabbedScreen(
              key: PageStorageKey('OrdersTabbedScreen'),
              orderAllKey: orderAllTabKey,
              orderResetKey: orderTabKey,
            ),
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
            // Fixed: Customer Tab logic (Index 5)
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