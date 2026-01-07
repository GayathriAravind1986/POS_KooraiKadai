import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NetworkEvent {}

class NetworkObserveEvent extends NetworkEvent {}

class NetworkNotifyEvent extends NetworkEvent {
  final bool isDeviceConnected;
  NetworkNotifyEvent({required this.isDeviceConnected});
}

class NetworkCheckEvent extends NetworkEvent {}

class NetworkBloc extends Bloc<NetworkEvent, dynamic> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _debounceTimer;
  Timer? _internetCheckTimer;

  bool _isDeviceConnected = true;
  bool _hasInternetAccess = true;

  NetworkBloc() : super(null) {
    on<NetworkObserveEvent>(_onObserve);
    on<NetworkNotifyEvent>(_onNotify);
    on<NetworkCheckEvent>(_onCheck);
  }

  Future<void> _onObserve(NetworkObserveEvent event, Emitter emit) async {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      add(NetworkNotifyEvent(isDeviceConnected: isConnected));
    });

    await _checkInternetAndEmit(emit);
    _startPeriodicInternetCheck(emit);
  }

  Future<void> _onNotify(NetworkNotifyEvent event, Emitter emit) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      _isDeviceConnected = event.isDeviceConnected;
      await _checkInternetAndEmit(emit);
    });
  }

  Future<void> _onCheck(NetworkCheckEvent event, Emitter emit) async {
    await _checkInternetAndEmit(emit);
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkInternetAndEmit(Emitter<dynamic> emit) async {
    final previousInternetAccess = _hasInternetAccess;

    if (!_isDeviceConnected) {
      _hasInternetAccess = false;
    } else {
      _hasInternetAccess = await _hasRealInternet();
    }

    // Always emit current status
    emit({
      'type': 'network_status',
      'isConnected': _isDeviceConnected,
      'hasInternetAccess': _hasInternetAccess,
      'message': _getStatusMessage(),
    });

    // Emit notification only on change
    if (previousInternetAccess != _hasInternetAccess) {
      String message;
      bool showNotification = true;

      if (_hasInternetAccess) {
        message = 'You are back online!';
      } else {
        message = 'No internet connection. Some features may be limited.';
      }

      emit({
        'type': 'network_notification',
        'hasInternetAccess': _hasInternetAccess,
        'isConnected': _isDeviceConnected,
        'message': message,
        'showNotification': showNotification,
        'shouldRefresh': !previousInternetAccess && _hasInternetAccess, // Key flag
      });
    }
  }

  String _getStatusMessage() {
    if (_hasInternetAccess) return 'Online';
    if (_isDeviceConnected) return 'Connected (No Internet)';
    return 'Offline';
  }

  void _startPeriodicInternetCheck(Emitter emit) {
    _internetCheckTimer?.cancel();
    _internetCheckTimer = Timer.periodic(const Duration(seconds: 12), (_) async {
      if (_isDeviceConnected) {
        await _checkInternetAndEmit(emit);
      }
    });
  }

  bool get isConnected => _isDeviceConnected;
  bool get hasInternetAccess => _hasInternetAccess;

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _debounceTimer?.cancel();
    _internetCheckTimer?.cancel();
    return super.close();
  }
}