import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart'
as category;
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_table_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_waiter_model.dart';
import 'package:simple/UI/Home_screen/Helper/appconfig.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart'
as product;
import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart'
as billing;
import 'package:simple/ModelClass/Order/Post_generate_order_model.dart'
as generate;
import 'package:simple/ModelClass/Order/Update_generate_order_model.dart'
as update;
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import 'package:simple/ModelClass/Table/Get_table_model.dart';
import 'package:simple/ModelClass/Waiter/getWaiterModel.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service_table_stock.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_waiter_service.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/local_storage_helper.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/local_storage_product.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';

import '../../ModelClass/Order/Post_generate_order_model.dart';
import '../../ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import '../../Offline/Hive_helper/localStorageHelper/hive_shop_details_service.dart';

// Helper method for safe double conversion
double _safeToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is num) return value.toDouble();
  return 0.0;
}

// Helper method to check actual internet reachability
Future<bool> _hasActualInternetConnection() async {
  try {

    final response = await ApiProvider.checkInternetConnectivity();
    return response;
  } catch (e) {
    debugPrint('Internet check failed: $e');
    return false;
  }
}

abstract class FoodCategoryEvent {}

class FoodCategory extends FoodCategoryEvent {}

class FoodCategoryOffline extends FoodCategoryEvent {
  final category.GetCategoryModel offlineData;
  FoodCategoryOffline(this.offlineData);
}

class FoodProductItem extends FoodCategoryEvent {
  String catId;
  String searchKey;
  String searchCode;
  FoodProductItem(this.catId, this.searchKey, this.searchCode);
}

class FoodProductItemOffline extends FoodCategoryEvent {
  final product.GetProductByCatIdModel offlineData;
  FoodProductItemOffline(this.offlineData);
}

class AddToBilling extends FoodCategoryEvent {
  final List<Map<String, dynamic>> billingItems;
  final bool? isDiscount;
  final OrderType? orderType;
  final String? categoryId;

  AddToBilling(
      this.billingItems,
      this.isDiscount,
      this.orderType,
      this.categoryId,
      );
}

class GenerateOrder extends FoodCategoryEvent {
  final String orderPayloadJson;
  GenerateOrder(this.orderPayloadJson);
}

class UpdateOrder extends FoodCategoryEvent {
  final String orderPayloadJson;
  String? orderId;
  UpdateOrder(this.orderPayloadJson, this.orderId);
}

class TableDine extends FoodCategoryEvent {}

class WaiterDine extends FoodCategoryEvent {}

class StockDetails extends FoodCategoryEvent {}

class SyncPendingOrders extends FoodCategoryEvent {}

class LoadOfflineCart extends FoodCategoryEvent {}

class LoadShopDetails extends FoodCategoryEvent {}

class SyncCompleteState {
  final bool success;
  final String? error;

  SyncCompleteState({required this.success, this.error});
}

class FoodCategoryBloc extends Bloc<FoodCategoryEvent, dynamic> {
  FoodCategoryBloc() : super(null) {

    on<FoodCategory>((event, emit) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasConnection = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasConnection) {
          // FIXED: Don't emit loading state if we already have local data
          final localData = await loadCategoriesFromHive();

          // Emit local data first if available (for immediate UI update)
          if (localData.isNotEmpty) {
            emit(GetCategoryModel(
              success: true,
              data: localData
                  .map((cat) => category.Data(
                id: cat.id,
                name: cat.name,
                image: cat.image,
              ))
                  .toList(),
              errorResponse: null,
            ));
          } else {
            // Only show loading if no local data
            emit(GetCategoryModel(
                success: false, data: [], errorResponse: null));
          }

          try {
            final value = await ApiProvider.getCategoryAPI();

            if (value.success == true && value.data != null) {
              // FIXED: Check if data actually changed before saving/emitting
              final currentData = localData.map((cat) => cat.id).toSet();
              final newData = value.data!.map((cat) => cat.id).toSet();

              if (!setEquals(currentData, newData)) {
                // Save categories to Hive only if data changed
                await saveCategoriesToHive(value.data!);
              }
            }
            // Always emit the latest API response
            emit(value);
          } catch (error) {
            debugPrint('API error, keeping local data: $error');
            // Don't emit error if we already have local data displayed
            if (localData.isEmpty) {
              emit(GetCategoryModel(
                success: false,
                data: [],
                errorResponse:
                ErrorResponse(message: error.toString(), statusCode: 500),
              ));
            }
          }
        } else {
          // Offline: load from Hive directly
          final localData = await loadCategoriesFromHive();
          debugPrint('Offline data count: ${localData.length}');

          emit(GetCategoryModel(
            success: true,
            data: localData
                .map((cat) => category.Data(
              id: cat.id,
              name: cat.name,
              image: cat.image,
            ))
                .toList(),
            errorResponse: null,
          ));
        }
      } catch (e) {
        debugPrint('Error in FoodCategory event: $e');
        // Fallback logic remains the same
        final localData = await loadCategoriesFromHive();
        if (localData.isNotEmpty) {
          emit(GetCategoryModel(
            success: true,
            data: localData
                .map((cat) => category.Data(
              id: cat.id,
              name: cat.name,
              image: cat.image,
            ))
                .toList(),
            errorResponse: null,
          ));
        }
      }
    });
    on<FoodCategoryOffline>((event, emit) async {
      emit(event.offlineData);
    });

    on<FoodProductItem>((event, emit) async {
      try {
        debugPrint('🔄 Loading products for category: ${event.catId}');

        final localProducts = await loadProductsFromHive(event.catId,
            searchKey: event.searchKey ?? "",
            searchCode: event.searchCode ?? "");

        debugPrint('📁 Found ${localProducts.length} cached products');

        if (localProducts.isNotEmpty) {
          final filteredProducts = localProducts.where((p) {
            if ((event.searchKey?.isEmpty ?? true) &&
                (event.searchCode?.isEmpty ?? true)) {
              return true;
            }

            bool matches = false;
            if (event.searchKey?.isNotEmpty ?? false) {
              matches = p.name
                  ?.toLowerCase()
                  .contains(event.searchKey!.toLowerCase()) ??
                  false;
            }
            if (event.searchCode?.isNotEmpty ?? false) {
              matches = matches ||
                  (p.shortCode
                      ?.toLowerCase()
                      .contains(event.searchCode!.toLowerCase()) ??
                      false);
            }
            return matches;
          }).toList();

          final offlineProducts = filteredProducts
              .map((p) => product.Rows(
            id: p.id,
            name: p.name,
            image: p.image,
            basePrice: p.basePrice,
            availableQuantity: p.availableQuantity,
            isStock: p.isStock ?? false,
            shortCode: p.shortCode,
            parcelPrice: p.parcelPrice,
            acPrice: p.acPrice,
            swiggyPrice: p.swiggyPrice,
            hdPrice: p.hdPrice,
            addons: p.addons
                ?.map((a) => product.Addons(
              id: a.id,
              name: a.name,
              price: a.price,
              isFree: a.isFree,
              maxQuantity: a.maxQuantity,
              isAvailable: a.isAvailable,
              quantity: 0,
              isSelected: false,
            ))
                .toList() ??
                [],
            counter: 0,
          ))
              .toList();

          emit(product.GetProductByCatIdModel(
            success: true,
            rows: offlineProducts,
            stockMaintenance: true,
            errorResponse: null,
          ));
        } else {
          // Show loading state if no cached data
          emit(product.GetProductByCatIdModel(
            success: false,
            rows: [],
            stockMaintenance: false,
            errorResponse: null,
          ));
        }

        // Step 3: Check network connectivity
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasNetworkConnectivity = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasNetworkConnectivity) {
          // Step 4: Check actual internet reachability
          final hasActualInternet = await _hasActualInternetConnection();

          if (hasActualInternet) {
            try {
              debugPrint('🌐 Fetching fresh products from API...');
              final value = await ApiProvider.getProductItemAPI(
                  event.catId, event.searchKey, event.searchCode);

              if (value.success == true && value.rows != null) {
                await saveProductsToHive(event.catId, value.rows!);
                debugPrint('💾 Saved fresh products to cache');
                emit(value);
              }
            } catch (error) {
              debugPrint('❌ API call failed: $error');
              // API failed, stay with cached data
              if (localProducts.isEmpty) {
                emit(product.GetProductByCatIdModel(
                  success: false,
                  rows: [],
                  stockMaintenance: false,
                  errorResponse: ErrorResponse(
                      message: error.toString(), statusCode: 500),
                ));
              }
            }
          } else {
            debugPrint('⚠️ Network connected but no internet access');
            // No actual internet - stay with cached data
            if (localProducts.isEmpty) {
              emit(product.GetProductByCatIdModel(
                success: false,
                rows: [],
                stockMaintenance: false,
                errorResponse: ErrorResponse(
                  message: 'Network connected but no internet access',
                  statusCode: 503,
                ),
              ));
            }
          }
        } else {
          debugPrint('📶 No network connection');
          // No network - stay with cached data
          if (localProducts.isEmpty) {
            emit(product.GetProductByCatIdModel(
              success: false,
              rows: [],
              stockMaintenance: false,
              errorResponse: ErrorResponse(
                message: 'No network connection and no cached products',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        debugPrint("❌ Error in FoodProductItem event: $e");
        // Final fallback
        try {
          final localProducts = await loadProductsFromHive(event.catId,
              searchKey: event.searchKey ?? "",
              searchCode: event.searchCode ?? "");

          if (localProducts.isNotEmpty) {
            final offlineProducts = localProducts
                .map((p) => product.Rows(
              id: p.id,
              name: p.name,
              image: p.image,
              basePrice: p.basePrice,
              availableQuantity: p.availableQuantity,
              isStock: p.isStock ?? false,
              shortCode: p.shortCode,
              parcelPrice: p.parcelPrice,
              acPrice: p.acPrice,
              swiggyPrice: p.swiggyPrice,
              hdPrice: p.hdPrice,
              addons: p.addons
                  ?.map((a) => product.Addons(
                id: a.id,
                name: a.name,
                price: a.price,
                isFree: a.isFree,
                maxQuantity: a.maxQuantity,
                isAvailable: a.isAvailable,
                quantity: 0,
                isSelected: false,
              ))
                  .toList() ??
                  [],
              counter: 0,
            ))
                .toList();

            emit(product.GetProductByCatIdModel(
              success: true,
              rows: offlineProducts,
              stockMaintenance: true,
              errorResponse: null,
            ));
          } else {
            emit(product.GetProductByCatIdModel(
              success: false,
              rows: [],
              stockMaintenance: false,
              errorResponse:
              ErrorResponse(message: e.toString(), statusCode: 500),
            ));
          }
        } catch (cacheError) {
          emit(product.GetProductByCatIdModel(
            success: false,
            rows: [],
            stockMaintenance: false,
            errorResponse:
            ErrorResponse(message: e.toString(), statusCode: 500),
          ));
        }
      }
    });

    on<AddToBilling>((event, emit) async {
      try {
        // Always save locally first
        if (event.orderType != null) {
          await HiveService.saveOrderType(event.orderType!.apiValue);
        }
        if (event.categoryId != null) {
          await HiveService.saveCartItems(event.billingItems, event.categoryId);
        } else {
          await HiveService.saveCartItems(event.billingItems);
        }

        final billingSession = await HiveService.calculateBillingTotals(
          event.billingItems,
          event.isDiscount ?? false,
          orderType: event.orderType?.apiValue,
          categoryId: event.categoryId,
        );
        await HiveService.saveBillingSession(billingSession);

        // Check if we can sync to server
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasNetworkConnectivity = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasNetworkConnectivity) {
          final hasActualInternet = await _hasActualInternetConnection();

          if (hasActualInternet) {
            try {
              debugPrint('🌐 Syncing billing to server...');
              final value = await ApiProvider().postAddToBillingAPI(
                event.billingItems,
                event.isDiscount,
                event.orderType?.apiValue,
              );

              await HiveService.saveLastOnlineTimestamp();
              emit(value);
              return; // Exit early on success
            } catch (error) {
              debugPrint('❌ Online sync failed, using offline mode: $error');
            }
          } else {
            debugPrint('⚠️ Network connected but no internet, using offline');
          }
        } else {
          debugPrint('📶 No network, using offline mode');
        }

        // If we reach here, use offline response
        await _handleOfflineBilling(event, emit);

      } catch (e) {
        debugPrint('💥 Error in AddToBilling event: $e');
        await _handleOfflineBilling(event, emit);
      }
    });

    on<GenerateOrder>((event, emit) async {
      try {
        // Parse order data
        final orderData = jsonDecode(event.orderPayloadJson);
        final billingSession = await HiveService.getBillingSession();

        if (billingSession == null) {
          throw Exception('No billing session found');
        }

        // Check connectivity
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasNetworkConnectivity = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        bool shouldGoOffline = true;

        if (hasNetworkConnectivity) {
          final hasActualInternet = await _hasActualInternetConnection();

          if (hasActualInternet) {
            try {
              debugPrint('🌐 Creating order via API...');
              final value = await ApiProvider()
                  .postGenerateOrderAPI(event.orderPayloadJson);
              await HiveService.clearCart();
              await HiveService.clearBillingSession();
              await HiveService.saveLastOnlineTimestamp();
              emit(value);
              shouldGoOffline = false;
            } catch (error) {
              debugPrint('❌ API order creation failed: $error');
            }
          } else {
            debugPrint('⚠️ Network connected but no internet');
          }
        } else {
          debugPrint('📶 No network connection');
        }

        // If online failed or no connection, save offline
        if (shouldGoOffline) {
          debugPrint('💾 Saving order offline...');
          await _handleOfflineOrderCreation(event, emit);
        }
      } catch (e) {
        debugPrint('💥 Error in GenerateOrder event: $e');
        await _handleOfflineOrderCreation(event, emit);
      }
    });

    on<UpdateOrder>((event, emit) async {
      try {
        // Check connectivity
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasNetworkConnectivity = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        bool shouldGoOffline = true;

        if (hasNetworkConnectivity) {
          final hasActualInternet = await _hasActualInternetConnection();

          if (hasActualInternet) {
            try {
              debugPrint('🌐 Updating order via API...');
              final value = await ApiProvider()
                  .updateGenerateOrderAPI(event.orderPayloadJson, event.orderId);

              await HiveService.clearCart();
              await HiveService.clearBillingSession();
              await HiveService.saveLastOnlineTimestamp();
              emit(value);
              shouldGoOffline = false;
            } catch (error) {
              debugPrint('❌ API order update failed: $error');
            }
          } else {
            debugPrint('⚠️ Network connected but no internet');
          }
        } else {
          debugPrint('📶 No network connection');
        }

        // If online failed or no connection, save offline
        if (shouldGoOffline) {
          debugPrint('💾 Saving order update offline...');
          await _handleOfflineOrderUpdate(event, emit);
        }
      } catch (e) {
        debugPrint('💥 Error in UpdateOrder event: $e');
        await _handleOfflineOrderUpdate(event, emit);
      }
    });

    on<SyncPendingOrders>((event, emit) async {
      try {
        debugPrint('🔄 Syncing pending orders...');
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasNetworkConnectivity = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasNetworkConnectivity) {
          final hasActualInternet = await _hasActualInternetConnection();

          if (hasActualInternet) {
            await HiveService.syncPendingOrders(ApiProvider());
            emit(SyncCompleteState(success: true));
          } else {
            emit(SyncCompleteState(
                success: false, error: 'No internet access'));
          }
        } else {
          emit(SyncCompleteState(
              success: false, error: 'No network connection'));
        }
      } catch (e) {
        debugPrint('❌ Error syncing orders: $e');
        emit(SyncCompleteState(success: false, error: e.toString()));
      }
    });

    on<TableDine>((event, emit) async {
      try {
        debugPrint('🪑 Loading tables...');

        // Load from cache first
        final offlineTables = await HiveStockTableService.getTablesAsApiFormat();

        if (offlineTables.isNotEmpty) {
          debugPrint('📁 Found ${offlineTables.length} cached tables');
          final offlineResponse = GetTableModel(
            success: true,
            data: offlineTables,
            errorResponse: null,
          );
          emit(offlineResponse);
        } else {
          emit(GetTableModel(
            success: false,
            data: [],
            errorResponse: null,
          ));
        }

        // Check for fresh data
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasNetworkConnectivity = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasNetworkConnectivity) {
          final hasActualInternet = await _hasActualInternetConnection();

          if (hasActualInternet) {
            try {
              debugPrint('🌐 Fetching fresh tables from API...');
              final value = await ApiProvider().getTableAPI();

              if (value.success == true && value.data != null) {
                await HiveStockTableService.saveTables(value.data!);
                debugPrint('💾 Saved fresh tables to cache');
                emit(value);
              }
            } catch (error) {
              debugPrint('❌ API error: $error');
              // Stay with cached data
              if (offlineTables.isEmpty) {
                emit(GetTableModel(
                  success: false,
                  errorResponse: ErrorResponse(
                    message: error.toString(),
                    statusCode: 500,
                  ),
                ));
              }
            }
          } else {
            debugPrint('⚠️ Network connected but no internet access');
            // Stay with cached data
            if (offlineTables.isEmpty) {
              emit(GetTableModel(
                success: false,
                data: [],
                errorResponse: ErrorResponse(
                  message: 'Network connected but no internet access',
                  statusCode: 503,
                ),
              ));
            }
          }
        } else {
          debugPrint('📶 No network connection');
          // Stay with cached data
          if (offlineTables.isEmpty) {
            emit(GetTableModel(
              success: false,
              data: [],
              errorResponse: ErrorResponse(
                message: 'No network connection and no cached tables',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        debugPrint('💥 Error in TableDine event: $e');
        // Final fallback
        final offlineTables = await HiveStockTableService.getTablesAsApiFormat();
        if (offlineTables.isNotEmpty) {
          final offlineResponse = GetTableModel(
            success: true,
            data: offlineTables,
            errorResponse: null,
          );
          emit(offlineResponse);
        } else {
          emit(GetTableModel(
            success: false,
            data: [],
            errorResponse: ErrorResponse(
              message: e.toString(),
              statusCode: 500,
            ),
          ));
        }
      }
    });

    on<WaiterDine>((event, emit) async {
      try {
        debugPrint('🧑‍🍳 Loading waiters...');

        // Load from cache first
        final offlineWaiters = await HiveWaiterService.getWaitersAsApiFormat();

        if (offlineWaiters.isNotEmpty) {
          debugPrint('📁 Found ${offlineWaiters.length} cached waiters');
          final offlineResponse = GetWaiterModel(
            success: true,
            data: offlineWaiters,
            totalCount: offlineWaiters.length,
            errorResponse: null,
          );
          emit(offlineResponse);
        } else {
          emit(GetWaiterModel(
            success: false,
            data: [],
            totalCount: 0,
            errorResponse: null,
          ));
        }

        // Check for fresh data
        final connectivityResult = await Connectivity().checkConnectivity();
        bool hasNetworkConnectivity = connectivityResult != ConnectivityResult.none;

        if (hasNetworkConnectivity) {
          final hasActualInternet = await _hasActualInternetConnection();

          if (hasActualInternet) {
            try {
              debugPrint('🌐 Fetching fresh waiters from API...');
              final value = await ApiProvider().getWaiterAPI();

              if (value.success == true && value.data != null) {
                await HiveWaiterService.saveWaiters(value.data!);
                debugPrint('💾 Saved fresh waiters to cache');
                emit(value);
              }
            } catch (error) {
              debugPrint('❌ API error: $error');
              // Stay with cached data
              if (offlineWaiters.isEmpty) {
                emit(GetWaiterModel(
                  success: false,
                  errorResponse: ErrorResponse(
                    message: error.toString(),
                    statusCode: 500,
                  ),
                ));
              }
            }
          } else {
            debugPrint('⚠️ Network connected but no internet access');
            // Stay with cached data
            if (offlineWaiters.isEmpty) {
              emit(GetWaiterModel(
                success: false,
                data: [],
                totalCount: 0,
                errorResponse: ErrorResponse(
                  message: 'Network connected but no internet access',
                  statusCode: 503,
                ),
              ));
            }
          }
        } else {
          debugPrint('📶 No network connection');
          // Stay with cached data
          if (offlineWaiters.isEmpty) {
            emit(GetWaiterModel(
              success: false,
              data: [],
              totalCount: 0,
              errorResponse: ErrorResponse(
                message: 'No network connection and no cached waiters',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        debugPrint('💥 Error in WaiterDine event: $e');
        // Final fallback
        final offlineWaiters = await HiveWaiterService.getWaitersAsApiFormat();
        if (offlineWaiters.isNotEmpty) {
          final offlineResponse = GetWaiterModel(
            success: true,
            data: offlineWaiters,
            totalCount: offlineWaiters.length,
            errorResponse: null,
          );
          emit(offlineResponse);
        } else {
          emit(GetWaiterModel(
            success: false,
            data: [],
            totalCount: 0,
            errorResponse: ErrorResponse(
              message: e.toString(),
              statusCode: 500,
            ),
          ));
        }
      }
    });

    on<StockDetails>((event, emit) async {
      try {
        debugPrint('📊 Loading stock details...');

        // Load from cache first
        final offlineStock = await HiveStockTableService.getStockMaintenanceAsApiModel();

        if (offlineStock != null) {
          debugPrint('📁 Found cached stock details');
          emit(offlineStock);
        } else {
          emit(GetStockMaintanencesModel(
            success: false,
            errorResponse: null,
          ));
        }

        // Check for fresh data
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasNetworkConnectivity = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasNetworkConnectivity) {
          final hasActualInternet = await _hasActualInternetConnection();

          if (hasActualInternet) {
            try {
              debugPrint('🌐 Fetching fresh stock details from API...');
              final value = await ApiProvider().getStockDetailsAPI();

              if (value.success == true) {
                await HiveStockTableService.saveStockMaintenance(value);
                debugPrint('💾 Saved fresh stock details to cache');
                emit(value);
              }
            } catch (error) {
              debugPrint('❌ API error: $error');
              // Stay with cached data
              if (offlineStock == null) {
                emit(GetStockMaintanencesModel(
                  success: false,
                  errorResponse: ErrorResponse(
                    message: error.toString(),
                    statusCode: 500,
                  ),
                ));
              }
            }
          } else {
            debugPrint('⚠️ Network connected but no internet access');
            // Stay with cached data
            if (offlineStock == null) {
              emit(GetStockMaintanencesModel(
                success: false,
                errorResponse: ErrorResponse(
                  message: 'Network connected but no internet access',
                  statusCode: 503,
                ),
              ));
            }
          }
        } else {
          debugPrint('📶 No network connection');
          // Stay with cached data
          if (offlineStock == null) {
            emit(GetStockMaintanencesModel(
              success: false,
              errorResponse: ErrorResponse(
                message: 'No network connection and no cached stock data',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        debugPrint('💥 Error in StockDetails event: $e');
        // Final fallback
        final offlineStock = await HiveStockTableService.getStockMaintenanceAsApiModel();
        if (offlineStock != null) {
          emit(offlineStock);
        } else {
          emit(GetStockMaintanencesModel(
            success: false,
            errorResponse: ErrorResponse(
              message: e.toString(),
              statusCode: 500,
            ),
          ));
        }
      }
    });

    on<LoadShopDetails>((event, emit) async {
      try {
        // Load from cache first
        final offlineShop = await HiveShopDetailsService.getShopDetailsAsApiModel();

        if (offlineShop != null) {
          emit(offlineShop);
        }

        // Check for fresh data
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasNetworkConnectivity = connectivityResult
            .any((result) => result != ConnectivityResult.none);

        if (hasNetworkConnectivity) {
          final hasActualInternet = await _hasActualInternetConnection();

          if (hasActualInternet) {
            try {
              final value = await ApiProvider().getShopDetailsAPI();

              if (value.success == true) {
                await HiveShopDetailsService.saveShopDetails(value);
                emit(value);
              }
            } catch (error) {
              // Stay with cached data
              if (offlineShop == null) {
                emit(GetStockMaintanencesModel(
                  success: false,
                  errorResponse: ErrorResponse(
                    message: error.toString(),
                    statusCode: 500,
                  ),
                ));
              }
            }
          } else {
            // Stay with cached data
            if (offlineShop == null) {
              emit(GetStockMaintanencesModel(
                success: false,
                errorResponse: ErrorResponse(
                  message: 'Network connected but no internet access',
                  statusCode: 503,
                ),
              ));
            }
          }
        } else {
          // Stay with cached data
          if (offlineShop == null) {
            emit(GetStockMaintanencesModel(
              success: false,
              errorResponse: ErrorResponse(
                message: 'No network connection and no cached shop data',
                statusCode: 503,
              ),
            ));
          }
        }
      } catch (e) {
        // Final fallback
        final offlineShop = await HiveShopDetailsService.getShopDetailsAsApiModel();
        if (offlineShop != null) {
          emit(offlineShop);
        } else {
          emit(GetStockMaintanencesModel(
            success: false,
            errorResponse: ErrorResponse(
              message: e.toString(),
              statusCode: 500,
            ),
          ));
        }
      }
    });
  }

  // ========== HELPER METHODS ==========

  String _getShopDetail(String? hiveValue, String fallbackValue) {
    if (hiveValue != null && hiveValue.trim().isNotEmpty) {
      return hiveValue.trim();
    }
    return fallbackValue;
  }

  bool setEquals<T>(Set<T> set1, Set<T> set2) {
    return set1.length == set2.length && set1.containsAll(set2);
  }

  Future<void> _handleOfflineBilling(AddToBilling event, Emitter emit) async {
    try {
      if (event.orderType != null) {
        await HiveService.saveOrderType(event.orderType!.apiValue);
      }
      if (event.categoryId != null) {
        await HiveService.saveCartItems(event.billingItems, event.categoryId);
      } else {
        await HiveService.saveCartItems(event.billingItems);
      }

      final billingSession = await HiveService.calculateBillingTotals(
        event.billingItems,
        event.isDiscount ?? false,
        orderType: event.orderType?.apiValue,
        categoryId: event.categoryId,
      );
      await HiveService.saveBillingSession(billingSession);

      final offlineResponse = billing.PostAddToBillingModel(
        subtotal: double.parse(billingSession.subtotal!.toStringAsFixed(2)),
        totalTax: double.parse(billingSession.totalTax!.toStringAsFixed(2)),
        total: double.parse(billingSession.total!.toStringAsFixed(2)),
        totalDiscount: billingSession.totalDiscount,
        items: billingSession.items?.map((hiveItem) {
          double itemPrice =
          hiveItem.getPriceByOrderType(event.orderType?.apiValue);
          List<billing.SelectedAddons>? convertedAddons;
          if (hiveItem.selectedAddons != null &&
              hiveItem.selectedAddons!.isNotEmpty) {
            convertedAddons = hiveItem.selectedAddons!
                .map((addon) => billing.SelectedAddons(
              id: addon['_id']?.toString(),
              name: addon['name']?.toString(),
              price: (addon['price'] ?? 0.0).toDouble(),
              quantity: addon['quantity'] ?? 0,
              isAvailable: addon['isAvailable'] ?? true,
              isFree: addon['isFree'] ?? false,
            ))
                .toList();
          }

          double addonTotal = 0.0;
          if (hiveItem.selectedAddons != null) {
            for (var addon in hiveItem.selectedAddons!) {
              if (!(addon['isFree'] ?? false)) {
                double addonPrice = (addon['price'] ?? 0.0).toDouble();
                int addonQty = addon['quantity'] ?? 0;
                addonTotal += (addonPrice * addonQty);
              }
            }
          }

          return billing.Items(
            id: hiveItem.product,
            name: hiveItem.name,
            image: hiveItem.image,
            basePrice: itemPrice,
            qty: hiveItem.quantity,
            availableQuantity: hiveItem.quantity,
            selectedAddons: convertedAddons,
            addonTotal: addonTotal,
          );
        }).toList(),
        errorResponse: null,
      );

      emit(offlineResponse);
    } catch (e, stackTrace) {
      emit(billing.PostAddToBillingModel(
        errorResponse: ErrorResponse(
          message: 'Offline billing calculation failed: $e',
          statusCode: 500,
        ),
      ));
    }
  }


  // ========== FIXED OFFLINE ORDER CREATION ==========
  Future<void> _handleOfflineOrderCreation(
      GenerateOrder event, Emitter emit) async {
    try {
      print("🛒 ========== OFFLINE ORDER CREATION STARTED ==========");

      final orderData = jsonDecode(event.orderPayloadJson);
      final billingSession = await HiveService.getBillingSession();

      if (billingSession == null) {
        throw Exception('No billing session found');
      }

      // Get shop details from Hive
      final shopDetails =
      await HiveShopDetailsService.getShopDetailsAsApiModel();
      final shopData = shopDetails?.data;

      final businessName = _getShopDetail(shopData?.name, 'Alagu Drive In');
      final address = _getShopDetail(shopData?.address,
          'Tenkasi main road, Alangualam, Tamil Nadu 627851');
      final phone = _getShopDetail(shopData?.contactNumber, '+91 04676967245');
      final gstNumber = _getShopDetail(shopData?.gstNumber, '00000000000');
      final thermalIp = shopData?.thermalIp ?? '';

      debugPrint("\n📦 USING SHOP DETAILS:");
      debugPrint("   - businessName: '$businessName'");
      debugPrint("   - address: '$address'");
      debugPrint("   - phone: '$phone'");
      debugPrint("   - gstNumber: '$gstNumber'");
      debugPrint("   - thermalIp: '$thermalIp'");

      final String tableId =
          orderData['tableNo']?.toString() ??
              orderData['tableId']?.toString() ??
              '';

      final String waiterId = orderData['waiter']?.toString() ?? '';

      debugPrint("🔍 Raw tableId from orderData: '$tableId'");
      debugPrint("🔍 Raw waiterId from orderData: '$waiterId'");

      final HiveTable? hiveTable =
      tableId.isNotEmpty
          ? await HiveStockTableService.getTableById(tableId)
          : null;

      final HiveWaiter? hiveWaiter =
      waiterId.isNotEmpty
          ? await HiveWaiterService.getWaiterById(waiterId)
          : null;

      final String tableName =
      hiveTable?.name?.isNotEmpty == true
          ? hiveTable!.name!
          : tableId.isNotEmpty ? "Table $tableId" : 'N/A';

      final String waiterName =
      hiveWaiter?.name?.toString().isNotEmpty == true
          ? hiveWaiter!.name!
          : waiterId.isNotEmpty ? "Waiter $waiterId" : 'N/A';

      debugPrint("🪑 TABLE - ID: '$tableId', NAME: '$tableName'");
      debugPrint("🧑‍🍳 WAITER - ID: '$waiterId', NAME: '$waiterName'");

      final normalizedItems = billingSession.items?.map((item) {
        final map = item.toMap();
        return {
          "product": map["_id"] ?? map["product"] ?? 'unknown_product',
          "name": map["name"]?.toString() ?? 'Unknown Item',
          "image": map["image"]?.toString() ?? '',
          "quantity": map["qty"] ?? map["quantity"] ?? 1,
          "unitPrice":
          _safeToDouble(map["unitPrice"] ?? map["basePrice"] ?? 0),
          "subtotal": _safeToDouble(((map["qty"] ?? map["quantity"] ?? 1) *
              (map["unitPrice"] ?? map["basePrice"] ?? 0))),
        };
      }).toList() ??
          [];

      // Generate order number for offline use
      final orderNumber = 'OFF-${DateTime.now().millisecondsSinceEpoch}';

      // Create KOT items from billing session with null safety
      final kotItems = billingSession.items?.map((item) {
        return {
          "name": item.name?.toString() ?? 'Unknown Item',
          "quantity": item.quantity ?? 1,
        };
      }).toList() ??
          [];

      final taxAmount = billingSession.totalTax ?? 0.0;
      final subtotal = billingSession.subtotal ?? 0.0;
      final taxPercentage = subtotal > 0 ? (taxAmount / subtotal) * 100 : 0.0;

      final finalTax = [
        {
          "name": "GST",
          "percentage": taxPercentage,
          "amt": taxAmount,
        }
      ];

      final currentTime = DateTime.now();
      final createdAt = currentTime.toIso8601String();
      final formattedDate =
          "${currentTime.day}/${currentTime.month}/${currentTime.year}, ${currentTime.hour}:${currentTime.minute}:${currentTime.second}";

      final Map<String, dynamic> hiveOrderData = {
        ...orderData,
        "items": normalizedItems,
        "orderStatus": orderData['orderStatus'] ?? 'PENDING_SYNC',
        "orderType": orderData['orderType'] ?? 'DINE-IN',
        "tableId": tableId,
        "tableNo": tableId,
        "tableName": tableName,
        "waiter": waiterId,
        "waiterName": waiterName,
        "payments": orderData['payments'] ??
            [
              {
                "method": orderData['payments']?[0]?['method'] ?? 'CASH',
                "amount": billingSession.total ?? 0.0
              }
            ],
      };

      debugPrint("💾 Saving to Hive - tableNo: '$tableId', tableName: '$tableName'");
      debugPrint("💾 Saving to Hive - waiter: '$waiterId', waiterName: '$waiterName'");

      // Save order for later sync with all required fields
      final orderId = await HiveService.saveOfflineOrder(
        orderPayloadJson: jsonEncode(hiveOrderData),
        orderStatus: orderData['orderStatus'] ?? 'PENDING_SYNC',
        orderType: orderData['orderType'] ?? 'DINE-IN',
        tableId: tableId, // Save table ID
        total: billingSession.total ?? 0.0,
        items: normalizedItems,
        syncAction: 'CREATE',
        businessName: businessName,
        address: address,
        gst: gstNumber,
        taxPercent: taxPercentage,
        paymentMethod: orderData['payments']?[0]?['method'] ?? 'CASH',
        phone: phone,
        waiterName: waiterName, // Use waiter name for display
        waiterId: waiterId, // Also save waiter ID for syncing
        orderNumber: orderNumber,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: billingSession.totalDiscount ?? 0.0,
        kotItems: kotItems,
        finalTaxes: finalTax,
        tableName: tableName, // Use table name for display
      );

      // Clear cart/session
      await HiveService.clearCart();
      await HiveService.clearBillingSession();

      // Create complete offline response
      final offlineResponse = PostGenerateOrderModel(
        message: 'Order saved offline. Will sync when connection is restored.',
        order: Order(
          id: orderId,
          orderNumber: orderNumber,
          items: normalizedItems
              .map((item) => Items(
            product: item['product']?.toString() ?? 'unknown',
            name: item['name']?.toString() ?? 'Unknown Item',
            quantity: item['quantity'] ?? 1,
            unitPrice: _safeToDouble(item['unitPrice']),
            subtotal: _safeToDouble(item['subtotal']),
            addons: [],
            tax: 0,
            id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
          ))
              .toList(),
          subtotal: subtotal,
          orderType: orderData['orderType'] ?? 'DINE-IN',
          tax: taxAmount,
          total: billingSession.total ?? 0.0,
          createdAt: createdAt,
        ),
        invoice: Invoice(
          businessName: businessName,
          address: address,
          phone: phone,
          gstNumber: gstNumber,
          currencySymbol: '₹',
          printType: 'imin',
          subtotal: subtotal,
          salesTax: taxAmount,
          total: billingSession.total ?? 0.0,
          orderNumber: orderNumber,
          orderStatus: 'PENDING_SYNC',
          date: formattedDate,
          paidBy: orderData['payments']?[0]?['method'] ?? 'CASH',
          transactionId: 'TXN-OFF-${DateTime.now().millisecondsSinceEpoch}',
          tableNum: tableName, // Display table name instead of ID
          tableName: tableName, // Display table name instead of ID
          waiterName: waiterName, // Display waiter name instead of ID
          orderType: orderData['orderType'] ?? 'DINE-IN',
          tipAmount: 0,
        ),
        payments: [
          Payments(
            order: orderId,
            paymentMethod: orderData['payments']?[0]?['method'] ?? 'CASH',
            amount: billingSession.total ?? 0.0,
            balanceAmount: 0.0,
            status: 'COMPLETED',
            createdAt: createdAt,
            id: 'pay_offline_${DateTime.now().millisecondsSinceEpoch}',
          )
        ],
      );

      debugPrint("✅ Offline order created successfully with ID: $orderId");
      debugPrint("🏪 Business: '$businessName'");
      debugPrint("🪑 Table: '$tableName' (ID: $tableId)");
      debugPrint("🧑‍🍳 Waiter: '$waiterName' (ID: $waiterId)");
      debugPrint("✅ ========== OFFLINE ORDER CREATION COMPLETED ==========\n");

      emit(offlineResponse);
    } catch (e, stackTrace) {
      debugPrint("❌ Failed to save offline order: $e");
      debugPrint("❌ Stack trace: $stackTrace");
      emit(PostGenerateOrderModel(
        errorResponse: ErrorResponse(
          message: 'Failed to save offline order: $e',
          statusCode: 500,
        ),
      ));
    }
  }


  Future<void> _handleOfflineOrderUpdate(
      UpdateOrder event, Emitter emit) async {
    try {
      debugPrint('💾 Starting offline order update...');

      final orderData = jsonDecode(event.orderPayloadJson);
      final billingSession = await HiveService.getBillingSession();

      if (billingSession == null) {
        throw Exception('No billing session found');
      }

      final shopDetails =
      await HiveShopDetailsService.getShopDetailsAsApiModel();
      final shopData = shopDetails?.data;

      final businessName = _getShopDetail(shopData?.name, 'Alagu Drive In');
      final address = _getShopDetail(shopData?.address,
          'Tenkasi main road, Alangualam, Tamil Nadu 627851');
      final phone = _getShopDetail(shopData?.contactNumber, '+91 0000000000');
      final gstNumber = _getShopDetail(shopData?.gstNumber, '00000000000');

      final normalizedItems = billingSession.items?.map((item) {
        final map = item.toMap();
        return {
          "product": map["_id"] ?? map["product"] ?? 'unknown_product',
          "name": map["name"]?.toString() ?? 'Unknown Item',
          "image": map["image"]?.toString() ?? '',
          "quantity": map["qty"] ?? map["quantity"] ?? 1,
          "unitPrice":
          _safeToDouble(map["unitPrice"] ?? map["basePrice"] ?? 0),
          "subtotal": _safeToDouble(((map["qty"] ?? map["quantity"] ?? 1) *
              (map["unitPrice"] ?? map["basePrice"] ?? 0))),
        };
      }).toList() ??
          [];

      final kotItems = billingSession.items?.map((item) {
        return {
          "name": item.name?.toString() ?? 'Unknown Item',
          "quantity": item.quantity ?? 1,
        };
      }).toList() ??
          [];

      final taxAmount = billingSession.totalTax ?? 0.0;
      final subtotal = billingSession.subtotal ?? 0.0;
      final taxPercentage = subtotal > 0 ? (taxAmount / subtotal) * 100 : 0.0;

      final finalTax = [
        {
          "name": "GST",
          "percentage": taxPercentage,
          "amt": taxAmount,
        }
      ];

      final currentTime = DateTime.now();
      final createdAt = currentTime.toIso8601String();
      final formattedDate =
          "${currentTime.day}/${currentTime.month}/${currentTime.year}, ${currentTime.hour}:${currentTime.minute}:${currentTime.second}";

      final Map<String, dynamic> hiveOrderData = {
        ...orderData,
        "items": normalizedItems,
        "orderStatus": 'PENDING_SYNC',
        "orderType": orderData['orderType'] ?? 'DINE-IN',
        "tableId": orderData['tableId'],
        "tableNo": orderData['tableNo']?.toString() ?? "",
        "waiter": orderData['waiter']?.toString() ?? "",
        "payments": orderData['payments'] ??
            [
              {
                "method": orderData['payments']?[0]?['method'] ?? 'CASH',
                "amount": billingSession.total ?? 0.0
              }
            ],
      };

      final orderId = await HiveService.saveOfflineOrder(
        orderPayloadJson: jsonEncode(hiveOrderData),
        orderStatus: 'PENDING_SYNC',
        orderType: orderData['orderType'] ?? 'DINE-IN',
        tableId: orderData['tableId'],
        total: billingSession.total ?? 0.0,
        items: normalizedItems,
        syncAction: 'UPDATE',
        existingOrderId: event.orderId,
        businessName: businessName,
        address: address,
        gst: gstNumber,
        taxPercent: taxPercentage,
        paymentMethod: orderData['payments']?[0]?['method'] ?? 'CASH',
        phone: phone,
        waiterName: orderData['waiter']?.toString() ?? "",
        orderNumber: 'UPD-${DateTime.now().millisecondsSinceEpoch}',
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: billingSession.totalDiscount ?? 0.0,
        kotItems: kotItems,
        finalTaxes: finalTax,
        tableName: orderData['tableNo']?.toString() ?? "",
      );

      await HiveService.clearCart();
      await HiveService.clearBillingSession();

      final offlineResponse = update.UpdateGenerateOrderModel(
        message:
        'Order update saved offline. Will sync when connection is restored.',
        order: update.Order(
          id: event.orderId,
          orderNumber: orderData['orderNumber'] ??
              'UPD-${DateTime.now().millisecondsSinceEpoch}',
          items: normalizedItems
              .map((item) => update.Items(
            product: item['product']?.toString() ?? 'unknown',
            name: item['name']?.toString() ?? 'Unknown Item',
            quantity: item['quantity'] ?? 1,
            unitPrice: _safeToDouble(item['unitPrice']),
            subtotal: _safeToDouble(item['subtotal']),
            addons: [],
            tax: 0,
            id: 'update_offline_${DateTime.now().millisecondsSinceEpoch}',
          ))
              .toList(),
          subtotal: subtotal,
          orderType: orderData['orderType'] ?? 'DINE-IN',
          tax: taxAmount,
          total: billingSession.total ?? 0.0,
        ),
        invoice: update.Invoice(
          businessName: businessName,
          address: address,
          phone: phone,
          gstNumber: gstNumber,
          currencySymbol: '₹',
          printType: 'imin',
          subtotal: subtotal,
          salesTax: taxAmount,
          total: billingSession.total ?? 0.0,
          orderNumber: orderData['orderNumber'] ??
              'UPD-${DateTime.now().millisecondsSinceEpoch}',
          orderStatus: 'PENDING_SYNC',
          date: formattedDate,
          paidBy: orderData['payments']?[0]?['method'] ?? 'CASH',
          transactionId: 'TXN-UPD-OFF-${DateTime.now().millisecondsSinceEpoch}',
          tableName: orderData['tableNo']?.toString() ?? "",
          waiterName: orderData['waiter']?.toString() ?? "",
          orderType: orderData['orderType'] ?? 'DINE-IN',
          tipAmount: 0,
        ),
        payments: [
          update.Payments(
            order: event.orderId,
            paymentMethod: orderData['payments']?[0]?['method'] ?? 'CASH',
            amount: billingSession.total ?? 0.0,
            balanceAmount: 0.0,
            status: 'COMPLETED',
            createdAt: createdAt,
            id: 'pay_update_offline_${DateTime.now().millisecondsSinceEpoch}',
          )
        ],
      );

      debugPrint('✅ Offline order update saved');
      emit(offlineResponse);
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to save offline order update: $e');
      emit(update.UpdateGenerateOrderModel(
        errorResponse: ErrorResponse(
          message: 'Failed to save offline order update: $e',
          statusCode: 500,
        ),
      ));
    }
  }
}