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
  bool _wasOffline = false;

  late ApiProvider _apiProvider;

  /// Initialize the background sync service
  /// Call this once when your app starts, typically in main() or initState()
  Future<void> init(ApiProvider apiProvider) async {
    _apiProvider = apiProvider;

    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Check initial connectivity state
    final initialResults = await _connectivity.checkConnectivity();
    await _onConnectivityChanged(initialResults);

    // Listen to connectivity changes
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    // Periodic sync every 60 seconds (backup mechanism)
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 60),
          (_) => _trySync(),
    );

    // Initial sync attempt
    await _trySync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground, trigger sync
      _trySync();
    }
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(
      List<ConnectivityResult> results) async {
    final isOnline = results.any(
          (r) =>
      r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );

    if (isOnline) {
      // User is back online
      await HiveService.setOfflineMode(false);
      await HiveService.saveLastOnlineTimestamp();

      // If user was previously offline, trigger immediate sync
      if (_wasOffline) {
        print('🌐 Connection restored. Starting sync...');
        await _trySync();
      }

      _wasOffline = false;
    } else {
      // User went offline
      print('📵 Connection lost. Entering offline mode...');
      await HiveService.setOfflineMode(true);
      _wasOffline = true;
    }
  }

  /// Attempt to sync pending orders
  Future<void> _trySync() async {
    // Prevent concurrent sync operations
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    try {
      final isOffline = await HiveService.isLikelyOffline();
      if (isOffline) {
        print('📵 Device is offline, skipping sync');
        return;
      }

      _isSyncing = true;
      print('🔄 Starting sync operation...');

      await HiveService.syncPendingOrders(_apiProvider);

      print('✅ Sync completed successfully');
    } catch (e, stackTrace) {
      print('❌ Sync failed: $e');
      print('Stack trace: $stackTrace');

      // Optionally log to a crash reporting service
      // FirebaseCrashlytics.instance.recordError(e, stackTrace);
    } finally {
      _isSyncing = false;
    }
  }

  /// Manually trigger a sync (useful for pull-to-refresh, etc.)
  Future<void> manualSync() async {
    print('🔄 Manual sync triggered');
    await _trySync();
  }

  /// Check current connectivity status
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any(
          (r) =>
      r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }


  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _connectivitySub?.cancel();
    _periodicTimer?.cancel();
    _connectivitySub = null;
    _periodicTimer = null;
    // print('🛑 BackgroundSyncService disposed');
  }
}