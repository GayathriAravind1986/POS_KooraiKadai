import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:simple/Bloc/observer/observer.dart';
import 'package:simple/Bloc/theme_cubit.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/UI/SplashScreen/splash_screen.dart';

import 'Api/apiProvider.dart';
import 'Offline/sync/background_sync_service.dart';

// Hive models
import 'Offline/Hive_helper/LocalClass/Home/category_model.dart';
import 'Offline/Hive_helper/LocalClass/Home/product_model.dart';
import 'Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';
import 'Offline/Hive_helper/LocalClass/Home/hive_order_model.dart';
import 'Offline/Hive_helper/LocalClass/Home/hive_billing_session_model.dart';
import 'Offline/Hive_helper/LocalClass/Home/hive_stock_model.dart';
import 'Offline/Hive_helper/LocalClass/Home/hive_table_model.dart';
import 'Offline/Hive_helper/LocalClass/Home/hive_waiter_model.dart';
import 'Offline/Hive_helper/LocalClass/Home/hive_user_model.dart';
import 'Offline/Hive_helper/LocalClass/Order/hive_pending_delete.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===============================
  // 1️⃣ SYSTEM CONFIG
  // ===============================
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Bloc.observer = AppBlocObserver();

  // ===============================
  // 2️⃣ INIT HIVE PATH
  // ===============================
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  // ===============================
  // 3️⃣ REGISTER HIVE ADAPTERS
  // ⚠️ BEFORE openBox()
  // ===============================
  Hive.registerAdapter(HiveCategoryAdapter());
  Hive.registerAdapter(HiveProductAdapter());
  Hive.registerAdapter(HiveAddonAdapter());
  Hive.registerAdapter(HiveCartItemAdapter());
  Hive.registerAdapter(HiveOrderAdapter());
  Hive.registerAdapter(HiveBillingSessionAdapter());
  Hive.registerAdapter(HiveStockMaintenanceAdapter());
  Hive.registerAdapter(HiveTableAdapter());
  Hive.registerAdapter(PendingDeleteAdapter());
  Hive.registerAdapter(HiveWaiterAdapter());
  Hive.registerAdapter(HiveUserAdapter());

  // ===============================
  // 4️⃣ OPEN HIVE BOXES (ONCE)
  // ===============================
  await Hive.openBox('app_state');
  await Hive.openBox('appConfigBox');

  await Hive.openBox<HiveCategory>('categories');
  await Hive.openBox<HiveCartItem>('cart_items');
  await Hive.openBox<HiveOrder>('orders');
  await Hive.openBox<HiveBillingSession>('billing_session');
  await Hive.openBox<HiveStockMaintenance>('stock_maintenance');
  await Hive.openBox<HiveTable>('tables');
  await Hive.openBox<HiveProduct>('products_box');
  await Hive.openBox<HiveWaiter>('waiters_box');
  await Hive.openBox<HiveUser>('users_box');

  // ===============================
  // 5️⃣ INIT API PROVIDER
  // ===============================
  final apiProvider = ApiProvider();

  // ===============================
  // 6️⃣ START BACKGROUND SYNC (ONCE)
  // ===============================
  await BackgroundSyncService().init(apiProvider);

  // ===============================
  // 7️⃣ RUN APP (LAST STEP)
  // ===============================
  runApp(const App());
}

// =======================================================
// APP WIDGETS (UNCHANGED)
// =======================================================

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (_, theme) {
        return OverlaySupport.global(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Koorai Kadai',
            theme: ThemeData(
              primaryColor: appPrimaryColor,
              unselectedWidgetColor: appPrimaryColor,
              fontFamily: "Poppins",
            ),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: child!,
                ),
              );
            },
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    return child;
  }
}
