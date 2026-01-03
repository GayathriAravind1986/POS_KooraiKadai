import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../Api/apiProvider.dart';
import '../Hive_helper/localStorageHelper/hive_service.dart';

class BackgroundSyncService with WidgetsBindingObserver {
  static final BackgroundSyncService _instance =
  BackgroundSyncService._internal();

  factory BackgroundSyncService() => _instance;

  BackgroundSyncService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Timer? _periodicTimer;
  bool _isSyncing = false;

  late ApiProvider _apiProvider;

  Future<void> init(ApiProvider apiProvider) async {
    _apiProvider = apiProvider;

    WidgetsBinding.instance.addObserver(this);

    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    _periodicTimer = Timer.periodic(
      const Duration(seconds: 60),
          (_) => _trySync(),
    );

    await _trySync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _trySync();
    }
  }

  Future<void> _onConnectivityChanged(
      List<ConnectivityResult> results) async {
    final isOnline = results.any(
          (r) =>
      r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );

    if (isOnline) {
      await HiveService.setOfflineMode(false);
      await HiveService.saveLastOnlineTimestamp();
      await _trySync();
    } else {
      await HiveService.setOfflineMode(true);
    }
  }

  Future<void> _trySync() async {
    if (_isSyncing) return;

    try {
      final isOffline = await HiveService.isLikelyOffline();
      if (isOffline) return;

      _isSyncing = true;
      await HiveService.syncPendingOrders(_apiProvider);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _connectivitySub?.cancel();
    _periodicTimer?.cancel();
  }
}
