// Update your dashboard.dart file
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
import 'package:simple/UI/Accounts/credit_screen.dart';
import 'package:simple/UI/Catering/catering_booking.dart';
import 'package:simple/UI/CustomAppBar/custom_appbar.dart';
import 'package:simple/UI/Customer/customer.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/UI/Order/order_list.dart';
import 'package:simple/UI/Order/order_tab_page.dart';
import 'package:simple/UI/StockIn/stock_in.dart';
import '../../Bloc/Report/accounts_report_bloc.dart';
import '../Accounts/accounts_report.dart';
import '../Accounts/return_screen.dart';
import '../Report/report_order.dart';
import 'package:simple/Bloc/Accounts/credit_bloc.dart';
import 'package:simple/Bloc/Accounts/return_bloc.dart';
import 'package:simple/Bloc/Network/network_bloc.dart';

class DashBoardScreen extends StatelessWidget {
  final int? selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;

  const DashBoardScreen({
    super.key,
    this.selectTab,
    this.existingOrder,
    this.isEditingOrder
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DemoBloc()),
        BlocProvider(
          create: (_) => NetworkBloc()..add(NetworkObserveEvent()),
          lazy: false,
        ),
      ],
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
  final GlobalKey<CreditViewViewState> creditKey =
  GlobalKey<CreditViewViewState>();
  final GlobalKey<ReturnViewViewState> returnKey =
  GlobalKey<ReturnViewViewState>();

  int selectedIndex = 0;
  bool orderLoad = false;
  bool hasRefreshedOrder = false;
  bool hasRefreshedReport = false;
  bool hasRefreshedStock = false;
  bool hasRefreshedCatering = false;
  bool hasRefreshedCustomer = false;
  bool hasRefreshedCateringBooking = false;
  bool hasRefreshedReturnReport = false;
  bool hasRefreshedCredit = false;
  bool hasRefreshedReturn = false;

  bool _isOnline = true;
  bool _hasInternetAccess = true;
  bool _showNetworkBanner = false;
  String _networkMessage = '';

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

  void _refreshCredit() {
    final creditKeyState = creditKey.currentState;
    if (creditKeyState != null) {
      creditKeyState.refreshCredit();
    }
  }

  void _refreshReturn() {
    final returnKeyState = returnKey.currentState;
    if (returnKeyState != null) {
      returnKeyState.refreshReturn();
    }
  }

  void _refreshCurrentTab() {
    // Only refresh if we have actual internet access (not just connected to WiFi)
    if (!_isOnline || !_hasInternetAccess) return;

    switch (selectedIndex) {
      case 0:
        _refreshHome();
        break;
      case 1:
        _refreshOrders();
        _resetOrderTab();
        break;
      case 2:
        _refreshReport();
        break;
      case 3:
        _refreshStock();
        break;
      case 4:
        _refreshCustomer();
        break;
      case 5:
        _refreshCateringBooking();
        break;
      case 6:
        _refreshCredit();
        break;
      case 7:
        _refreshReturn();
        break;
      case 8:
        _refreshReturnReport();
        break;
    }
  }

  void _handleNetworkNotification(Map<String, dynamic> state) {
    if (state['type'] == 'network_notification' && state['showNotification'] == true) {
      final bool wasOnline = _isOnline && _hasInternetAccess;

      setState(() {
        _showNetworkBanner = true;
        _networkMessage = state['message'];
        _isOnline = state['isConnected'] ?? false;
        _hasInternetAccess = state['hasInternetAccess'] ?? false;
      });

      // Auto hide banner after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showNetworkBanner = false;
          });
        }
      });

      // Refresh current tab when internet access is restored
      final bool isNowOnline = _isOnline && _hasInternetAccess;
      if (!wasOnline && isNowOnline) {
        // User now has internet access (either reconnected or internet restored)
        _refreshCurrentTab();
      }
    }
  }

  Widget _buildNetworkBanner() {
    if (!_showNetworkBanner) return const SizedBox.shrink();

    Color bannerColor;
    IconData bannerIcon;

    if (_isOnline && _hasInternetAccess) {
      // Connected with internet
      bannerColor = Colors.green;
      bannerIcon = Icons.wifi;
    } else if (_isOnline && !_hasInternetAccess) {
      // Connected but no internet
      bannerColor = Colors.orange;
      bannerIcon = Icons.wifi_off;
    } else {
      // Not connected at all
      bannerColor = Colors.red;
      bannerIcon = Icons.signal_wifi_off;
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: bannerColor,
        child: Row(
          children: [
            Icon(
              bannerIcon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _networkMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  _showNetworkBanner = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget mainContainer() {
    return BlocListener<NetworkBloc, dynamic>(
      listener: (context, state) {
        if (state is Map<String, dynamic>) {
          if (state['type'] == 'network_status') {
            setState(() {
              _isOnline = state['isConnected'] ?? true;
              _hasInternetAccess = state['hasInternetAccess'] ?? true;
            });
          } else if (state['type'] == 'network_notification') {
            _handleNetworkNotification(state);
          }
        }
      },
      child: Stack(
        children: [
          SafeArea(
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
                  hasRefreshedCredit = false;
                  hasRefreshedReturn = false;

                  // Set the appropriate flag and trigger refresh
                  switch (index) {
                    case 0:
                      hasRefreshedOrder = true;
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _refreshHome());
                      break;
                    case 1:
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _refreshOrders();
                        _resetOrderTab();
                      });
                      break;
                    case 2:
                      hasRefreshedReport = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _refreshReport();
                      });
                      break;
                    case 3:
                      hasRefreshedStock = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _refreshStock();
                      });
                      break;
                    case 4:
                      hasRefreshedCustomer = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _refreshCustomer();
                      });
                      break;
                    case 5:
                      hasRefreshedCateringBooking = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _refreshCateringBooking();
                      });
                      break;
                    case 6:
                      hasRefreshedCredit = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _refreshCredit();
                      });
                      break;
                    case 7:
                      hasRefreshedReturn = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _refreshReturn();
                      });
                      break;
                    case 8:
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

                  // Index 4: Customers
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

                  // Index 5: Catering Booking
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

                  // Index 6: Credit
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

                  // Index 7: Return
                  hasRefreshedReturn == true
                      ? BlocProvider(
                      create: (_) => ReturnBloc(),
                      child: ReturnViewView(
                        key: returnKey,
                        hasRefreshedCredit: hasRefreshedReturn,
                      ))
                      : BlocProvider(
                    create: (_) => ReturnBloc(),
                    child: ReturnView(
                      key: returnKey,
                      hasRefreshedReturn: hasRefreshedReturn,
                    ),
                  ),

                  // Index 8: Credit & Return Report
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
          ),
          _buildNetworkBanner(),
        ],
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