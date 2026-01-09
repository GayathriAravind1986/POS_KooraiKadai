import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  Stream<bool> get onInternetRestored => _internetStream.where((hasInternet) => hasInternet);

  late Stream<bool> _internetStream;
  StreamSubscription? _subscription;
  bool _previousHasInternet = true;

  void init(void Function() onRestoredCallback) {
    _internetStream = _connectivity.onConnectivityChanged.asyncMap((result) async {
      if (result == ConnectivityResult.none) {
        return false;
      }
      return await _internetChecker.hasInternetAccess;
    }).asBroadcastStream();

    _subscription = _internetStream.listen((hasInternet) {
      if (!_previousHasInternet && hasInternet) {
        onRestoredCallback();
      }
      _previousHasInternet = hasInternet;
    });

    // Initial check
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    _previousHasInternet = await _internetChecker.hasInternetAccess;
  }

  void dispose() {
    _subscription?.cancel();
  }
}