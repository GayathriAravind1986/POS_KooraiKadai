import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/Authentication/Post_login_model.dart';
import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart';
import 'package:simple/ModelClass/Catering/getAllCateringModel.dart';
import 'package:simple/ModelClass/Catering/getCustomerByLocation.dart';
import 'package:simple/ModelClass/Catering/getItemAddonsForPackageModel.dart';
import 'package:simple/ModelClass/Catering/getPackageModel.dart';
import 'package:simple/ModelClass/Catering/getSingleCateringDetailsModel.dart';
import 'package:simple/ModelClass/Catering/postCateringBookingModel.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart';
import 'package:simple/ModelClass/Order/Delete_order_model.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/ModelClass/Order/Post_generate_order_model.dart';
import 'package:simple/ModelClass/Order/Update_generate_order_model.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/ModelClass/Report/Get_report_model.dart';
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart';
import 'package:simple/ModelClass/StockIn/getSupplierLocationModel.dart';
import 'package:simple/ModelClass/StockIn/get_add_product_model.dart';
import 'package:simple/ModelClass/StockIn/saveStockInModel.dart';
import 'package:simple/ModelClass/User/getUserModel.dart';
import 'package:simple/ModelClass/Waiter/getWaiterModel.dart';
import 'package:simple/Reusable/constant.dart';

import '../ModelClass/Customer/GetCustomerByIdModel.dart';
import '../ModelClass/Customer/GetCustomerModel.dart';
import '../ModelClass/Customer/PostCustomerModel.dart';
import '../ModelClass/Customer/PutCustomerByIdModel.dart';
import '../ModelClass/Customer/getCategoryByLocationModel.dart';
import '../ModelClass/Accounts/GetReportModel.dart';
import '../ModelClass/Table/Get_table_model.dart';

/// All API Integration in ApiProvider
class ApiProvider {
  late Dio _dio;

  /// dio use ApiProvider
  ApiProvider() {
    final options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    );
    _dio = Dio(options);
  }

  /// LoginWithOTP API Integration
  Future<PostLoginModel> loginAPI(
    String email,
    String password,
  ) async {
    try {
      final dataMap = {"email": email, "password": password};
      var data = json.encode(dataMap);
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}auth/users/login'.trim(),
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          PostLoginModel postLoginResponse =
              PostLoginModel.fromJson(response.data);
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(
            "token",
            postLoginResponse.token.toString(),
          );
          sharedPreferences.setString(
            "role",
            postLoginResponse.user!.role.toString(),
          );
          sharedPreferences.setString(
            "userId",
            postLoginResponse.user!.id.toString(),
          );
          return postLoginResponse;
        }
      }
      return PostLoginModel()
        ..errorResponse = ErrorResponse(message: "Unexpected error occurred.");
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return PostLoginModel()..errorResponse = errorResponse;
    } catch (error) {
      return PostLoginModel()..errorResponse = handleError(error);
    }
  }

  /// Category - Fetch API Integration
  Future<GetCategoryModel> getCategoryAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    var userId = sharedPreferences.getString("userId");
    debugPrint("userId:$userId");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/categories/name',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetCategoryModel getCategoryResponse =
              GetCategoryModel.fromJson(response.data);
          return getCategoryResponse;
        }
      } else {
        return GetCategoryModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetCategoryModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetCategoryModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetCategoryModel()..errorResponse = errorResponse;
    }
  }

  /// product - Fetch API Integration
  Future<GetProductByCatIdModel> getProductItemAPI(
      String? catId,
      String? searchKey,
      String? searchCode,
      String? limit,
      String? offset) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint(
        "baseUrlProdOrder:${Constants.baseUrl}api/products/pos/category-products?categoryId=$catId&search=$searchKey&searchcode=$searchCode&limit=$limit&offset=$offset");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/products/pos/category-products?categoryId=$catId&search=$searchKey&searchcode=$searchCode&limit=$limit&offset=$offset',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetProductByCatIdModel getProductByCatIdResponse =
              GetProductByCatIdModel.fromJson(response.data);
          return getProductByCatIdResponse;
        }
      } else {
        return GetProductByCatIdModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetProductByCatIdModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetProductByCatIdModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetProductByCatIdModel()..errorResponse = handleError(error);
    }
  }

  /// Table - Fetch API Integration
  Future<GetTableModel> getTableAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/tables?isDefault=true',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetTableModel getTableResponse =
              GetTableModel.fromJson(response.data);
          return getTableResponse;
        }
      } else {
        return GetTableModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetTableModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetTableModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetTableModel()..errorResponse = handleError(error);
    }
  }

  /// Waiter Details -Fetch API Integration
  Future<GetWaiterModel> getWaiterAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/waiter?isAvailable=true&isSupplier=false',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetWaiterModel getWaiterResponse =
              GetWaiterModel.fromJson(response.data);
          return getWaiterResponse;
        }
      } else {
        return GetWaiterModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetWaiterModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetWaiterModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetWaiterModel()..errorResponse = handleError(error);
    }
  }

  /// userDetails - Fetch API Integration
  Future<GetUserModel> getUserDetailsAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}auth/users',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetUserModel getUserResponse = GetUserModel.fromJson(response.data);
          return getUserResponse;
        }
      } else {
        return GetUserModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetUserModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetUserModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetUserModel()..errorResponse = handleError(error);
    }
  }

  /// Stock Details - Fetch API Integration
  Future<GetStockMaintanencesModel> getStockDetailsAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/shops',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetStockMaintanencesModel getShopDetailsResponse =
              GetStockMaintanencesModel.fromJson(response.data);
          return getShopDetailsResponse;
        }
      } else {
        return GetStockMaintanencesModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetStockMaintanencesModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetStockMaintanencesModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetStockMaintanencesModel()..errorResponse = handleError(error);
    }
  }

  /// Add to Billing - Post API Integration
  Future<PostAddToBillingModel> postAddToBillingAPI(
      List<Map<String, dynamic>> billingItems,
      bool? isDiscount,
      String? orderType) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      final dataMap = {
        "items": billingItems,
        "isApplicableDiscount": isDiscount,
        "orderType": orderType
      };
      var data = json.encode(dataMap);
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/billing/calculate',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        try {
          PostAddToBillingModel postAddToBillingResponse =
              PostAddToBillingModel.fromJson(response.data);
          return postAddToBillingResponse;
        } catch (e) {
          return PostAddToBillingModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return PostAddToBillingModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return PostAddToBillingModel()..errorResponse = errorResponse;
    } catch (error) {
      return PostAddToBillingModel()..errorResponse = handleError(error);
    }
  }

  /// orderToday - Fetch API Integration
  Future<GetOrderListTodayModel> getOrderTodayAPI(
      String? fromDate,
      String? toDate,
      String? tableId,
      String? waiterId,
      String? operator) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint(
        "baseUrlOrder:${Constants.baseUrl}api/generate-order?from_date=$fromDate&to_date=$toDate&tableNo=$tableId&waiter=$waiterId&operator=$operator");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order?from_date=$fromDate&to_date=$toDate&tableNo=$tableId&waiter=$waiterId&operator=$operator',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetOrderListTodayModel getOrderListTodayResponse =
              GetOrderListTodayModel.fromJson(response.data);
          return getOrderListTodayResponse;
        }
      } else {
        return GetOrderListTodayModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetOrderListTodayModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetOrderListTodayModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetOrderListTodayModel()..errorResponse = handleError(error);
    }
  }

  /// ReportToday - Fetch API Integration
  Future<GetReportModel> getReportTodayAPI(String? fromDate, String? toDate,
      String? tableId, String? waiterId, String? operatorId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint(
        "baseUrlReport:'${Constants.baseUrl}api/generate-order/sales-report?from_date=$fromDate&to_date=$toDate&limit=200&tableNo=$tableId&waiter=$waiterId&operator=$operatorId");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/sales-report?from_date=$fromDate&to_date=$toDate&limit=200&tableNo=$tableId&waiter=$waiterId&operator=$operatorId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetReportModel getReportListTodayResponse =
              GetReportModel.fromJson(response.data);
          return getReportListTodayResponse;
        }
      } else {
        return GetReportModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetReportModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetReportModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetReportModel()..errorResponse = handleError(error);
    }
  }

  /// Generate Order - Post API Integration
  Future<PostGenerateOrderModel> postGenerateOrderAPI(
      final String orderPayloadJson) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var data = orderPayloadJson;
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        try {
          PostGenerateOrderModel postGenerateOrderResponse =
              PostGenerateOrderModel.fromJson(response.data);
          return postGenerateOrderResponse;
        } catch (e) {
          return PostGenerateOrderModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return PostGenerateOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return PostGenerateOrderModel()..errorResponse = errorResponse;
    } catch (error) {
      return PostGenerateOrderModel()..errorResponse = handleError(error);
    }
  }

  /// Delete Order - Fetch API Integration
  Future<DeleteOrderModel> deleteOrderAPI(String? orderId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order/$orderId',
        options: Options(
          method: 'DELETE',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          DeleteOrderModel deleteOrderResponse =
              DeleteOrderModel.fromJson(response.data);
          return deleteOrderResponse;
        }
      } else {
        return DeleteOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return DeleteOrderModel()..errorResponse = errorResponse;
    } catch (error) {
      return DeleteOrderModel()..errorResponse = handleError(error);
    }
  }

  /// View Order - Fetch API Integration
  Future<GetViewOrderModel> viewOrderAPI(String? orderId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/$orderId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetViewOrderModel getViewOrderResponse =
              GetViewOrderModel.fromJson(response.data);
          return getViewOrderResponse;
        }
      } else {
        return GetViewOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetViewOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetViewOrderModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetViewOrderModel()..errorResponse = handleError(error);
    }
  }

  /// Update Generate Order - Post API Integration
  Future<UpdateGenerateOrderModel> updateGenerateOrderAPI(
      final String orderPayloadJson, String? orderId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      var data = orderPayloadJson;
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order/$orderId',
        options: Options(
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        try {
          UpdateGenerateOrderModel updateGenerateOrderResponse =
              UpdateGenerateOrderModel.fromJson(response.data);
          return updateGenerateOrderResponse;
        } catch (e) {
          return UpdateGenerateOrderModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return UpdateGenerateOrderModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return UpdateGenerateOrderModel()..errorResponse = errorResponse;
    } catch (error) {
      return UpdateGenerateOrderModel()..errorResponse = handleError(error);
    }
  }

  /// Get Return Report with Search API Integration
  Future<ReturnReportModel> getReturnReportAPI(
      String fromDate,
      String toDate,
      String search,
      int limit,
      int offset) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/accounts/return/report?limit=$limit&offset=$offset&from_date=$fromDate&to_date=$toDate&search=$search',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint("📥 API Response Status: ${response.statusCode}");
      debugPrint("📥 API Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          ReturnReportModel getReportResponse =
          ReturnReportModel.fromJson(response.data);
          return getReportResponse;
        }
      }

      return ReturnReportModel()
        ..errorResponse = ErrorResponse(
          message: "Error: ${response.data['message'] ?? 'Unknown error'}",
          statusCode: response.statusCode,
        );
    } on DioException catch (dioError) {
      debugPrint("❌ DioException: $dioError");
      final errorResponse = handleError(dioError);
      return ReturnReportModel()..errorResponse = errorResponse;
    } catch (error) {
      debugPrint("❌ General Error: $error");
      final errorResponse = handleError(error);
      return ReturnReportModel()..errorResponse = errorResponse;
    }
  }

  // /// Category By Location API Integration
  Future<GetCategoryByLocationModel> getCategoryByLocationAPI(
      String? locationId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/expensescategory?locationId=$locationId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetCategoryByLocationModel getCategoryByLocationResponse =
              GetCategoryByLocationModel.fromJson(response.data);
          return getCategoryByLocationResponse;
        }
      } else {
        return GetCategoryByLocationModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetCategoryByLocationModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetCategoryByLocationModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetCategoryByLocationModel()..errorResponse = errorResponse;
    }
  }

  /// Get All Customers API Integration
  Future<GetCustomerModel> getAllCustomerAPI(String search) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    final url =
        '${Constants.baseUrl}api/catering/customer?limit=100&offset=0&search=';
    debugPrint("📡 Customer API URL: $url");

    try {
      var dio = Dio();
      var response = await dio.request(
        url,
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // ✅ Debug the response
      debugPrint("📥 Customer API Status: ${response.statusCode}");
      debugPrint("📥 Customer API Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final model = GetCustomerModel.fromJson(response.data);
        debugPrint("✅ Model Success: ${model.success}");
        debugPrint("✅ Model Data Count: ${model.data?.length}");
        debugPrint("✅ Model Total: ${model.total}");
        return model;
      } else {
        return GetCustomerModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      debugPrint("❌ DioException: ${dioError.message}");
      debugPrint("❌ Response: ${dioError.response?.data}");
      return GetCustomerModel()..errorResponse = handleError(dioError);
    } catch (error) {
      debugPrint("❌ Error: $error");
      return GetCustomerModel()..errorResponse = handleError(error);
    }
  }

  /// Get Customer By ID API Integration
  Future<GetCustomerByIdModel> getCustomerByIdAPI(String? customerId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/catering/customer/$customerId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return GetCustomerByIdModel.fromJson(response.data);
      } else {
        return GetCustomerByIdModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      return GetCustomerByIdModel()..errorResponse = handleError(dioError);
    } catch (error) {
      return GetCustomerByIdModel()..errorResponse = handleError(error);
    }
  }

  Future<PostCustomerModel> postCustomerAPI(
    String name,
    String phone,
    String email,
    String address,
    String locId,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    try {
      final dataMap = {
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "locationId": locId
      };

      // Add debugging
      print("📤 POST /api/catering/customer");
      print("📤 Token: ${token != null ? 'Present' : 'Missing'}");
      print("📤 Request Data: $dataMap");

      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/catering/customer',
        options: Options(
          method: 'POST',
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // ✅ ADD THIS
          },
        ),
        data: json.encode(dataMap),
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return PostCustomerModel.fromJson(response.data);
      } else {
        return PostCustomerModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      print("❌ Dio Error: ${dioError.message}");
      print("❌ Dio Error Response: ${dioError.response?.data}");
      print("❌ Dio Error Status: ${dioError.response?.statusCode}");
      return PostCustomerModel()..errorResponse = handleError(dioError);
    } catch (error) {
      print("❌ General Error: $error");
      return PostCustomerModel()..errorResponse = handleError(error);
    }
  }

  /// Update Customer (PUT) API Integration
  Future<PutCustomerByIdModel> putCustomerAPI(
    String customerId,
    String name,
    String phone,
    String email,
    String address,
    String locId,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    try {
      final dataMap = {
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "locationId": locId
      };
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/catering/customer/$customerId',
        options: Options(
          method: 'PUT',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: json.encode(dataMap),
      );

      if (response.statusCode == 200 && response.data != null) {
        return PutCustomerByIdModel.fromJson(response.data);
      } else {
        return PutCustomerByIdModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      return PutCustomerByIdModel()..errorResponse = handleError(dioError);
    } catch (error) {
      return PutCustomerByIdModel()..errorResponse = handleError(error);
    }
  }

  /***** Stock_In*****/
  /// Location - fetch API Integration
  Future<GetLocationModel> getLocationAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}auth/users/bylocation',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetLocationModel getLocationResponse =
              GetLocationModel.fromJson(response.data);
          return getLocationResponse;
        }
      } else {
        return GetLocationModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetLocationModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetLocationModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetLocationModel()..errorResponse = errorResponse;
    }
  }

  /// Supplier - fetch API Integration
  Future<GetSupplierLocationModel> getSupplierAPI(String? locationId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/supplier?isDefault=true&filter=false&locationId=$locationId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetSupplierLocationModel getSupplierResponse =
              GetSupplierLocationModel.fromJson(response.data);
          return getSupplierResponse;
        }
      } else {
        return GetSupplierLocationModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetSupplierLocationModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetSupplierLocationModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetSupplierLocationModel()..errorResponse = errorResponse;
    }
  }

  /// Add Product - fetch API Integration
  Future<GetAddProductModel> getAddProductAPI(String? locationId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/products?isStock=true&filter=false&locationId=$locationId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetAddProductModel getAddProductResponse =
              GetAddProductModel.fromJson(response.data);
          return getAddProductResponse;
        }
      } else {
        return GetAddProductModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetAddProductModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetAddProductModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetAddProductModel()..errorResponse = errorResponse;
    }
  }

  /// Save StockIn - Post API Integration

  Future<SaveStockInModel> postSaveStockInAPI(
      final String stockInPayloadJson) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("payload:$stockInPayloadJson");
    try {
      var data = stockInPayloadJson;
      debugPrint("data:$data");
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/stock',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        try {
          SaveStockInModel postGenerateOrderResponse =
              SaveStockInModel.fromJson(response.data);
          return postGenerateOrderResponse;
        } catch (e) {
          return SaveStockInModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return SaveStockInModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return SaveStockInModel()..errorResponse = errorResponse;
    } catch (error) {
      return SaveStockInModel()..errorResponse = handleError(error);
    }
  }

  /// catering
  /// catering List - API Integration
  Future<GetCateringModel> cateringListAPI(
      String search,
      String locId,
      String cusId,
      String fromDate,
      String toDate,
      int offset,
      int limit) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint(
        "cateringBooking:${Constants.baseUrl}api/catering/booking?limit=$limit&offset=$offset&search=$search&locationId=$locId&customerId=$cusId&from_date=$fromDate&to_date=$toDate");
    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/catering/booking?limit=$limit&offset=$offset&search=$search&customerId=$cusId&from_date=$fromDate&to_date=$toDate',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetCateringModel getCateringResponse =
              GetCateringModel.fromJson(response.data);
          return getCateringResponse;
        }
      } else {
        return GetCateringModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetCateringModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetCateringModel()..errorResponse = errorResponse;
    } catch (error) {
      return GetCateringModel()..errorResponse = handleError(error);
    }
  }

  /// get customer by location API - Integration
  Future<GetCustomerByLocation> getCustomerAPI(String? locationId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/catering/customer?locationId=$locationId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetCustomerByLocation getCustomerByLocationResponse =
              GetCustomerByLocation.fromJson(response.data);
          return getCustomerByLocationResponse;
        }
      } else {
        return GetCustomerByLocation()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetCustomerByLocation()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetCustomerByLocation()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetCustomerByLocation()..errorResponse = errorResponse;
    }
  }

  /// get Package by location API - Integration
  Future<GetPackageModel> getPackageAPI(String? locationId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/catering/package?locationId=$locationId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetPackageModel getPackageResponse =
              GetPackageModel.fromJson(response.data);
          return getPackageResponse;
        }
      } else {
        return GetPackageModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetPackageModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetPackageModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetPackageModel()..errorResponse = errorResponse;
    }
  }

  /// get Item-Addons by package API - Integration
  Future<GetItemAddonsForPackageModel> getItemAddonsAPI(
      String? packageId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/catering/package/$packageId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetItemAddonsForPackageModel getItemAddonsForPackageResponse =
              GetItemAddonsForPackageModel.fromJson(response.data);
          return getItemAddonsForPackageResponse;
        }
      } else {
        return GetItemAddonsForPackageModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetItemAddonsForPackageModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetItemAddonsForPackageModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetItemAddonsForPackageModel()..errorResponse = errorResponse;
    }
  }

  /// Save Catering - Post API Integration

  Future<PostCateringBookingModel> postSaveCateringAPI(
      final String cateringPayloadJson) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("payload:$cateringPayloadJson");
    try {
      var data = cateringPayloadJson;
      debugPrint("data:$data");
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/catering/booking',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        try {
          PostCateringBookingModel postCateringBookingResponse =
              PostCateringBookingModel.fromJson(response.data);
          return postCateringBookingResponse;
        } catch (e) {
          return PostCateringBookingModel()
            ..errorResponse = ErrorResponse(
              message: "Failed to parse response: $e",
            );
        }
      } else {
        return PostCateringBookingModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return PostCateringBookingModel()..errorResponse = errorResponse;
    } catch (error) {
      return PostCateringBookingModel()..errorResponse = handleError(error);
    }
  }

  /// Single Catering - API Integration
  Future<GetSingleCateringDetailsModel> getSingleCateringAPI(
      String? cateringId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    debugPrint("token:$token");

    try {
      var dio = Dio();
      var response = await dio.request(
        '${Constants.baseUrl}api/catering/booking/$cateringId',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          GetSingleCateringDetailsModel getSingleCateringResponse =
              GetSingleCateringDetailsModel.fromJson(response.data);
          return getSingleCateringResponse;
        }
      } else {
        return GetSingleCateringDetailsModel()
          ..errorResponse = ErrorResponse(
            message: "Error: ${response.data['message'] ?? 'Unknown error'}",
            statusCode: response.statusCode,
          );
      }
      return GetSingleCateringDetailsModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error occurred.",
          statusCode: 500,
        );
    } on DioException catch (dioError) {
      final errorResponse = handleError(dioError);
      return GetSingleCateringDetailsModel()..errorResponse = errorResponse;
    } catch (error) {
      final errorResponse = handleError(error);
      return GetSingleCateringDetailsModel()..errorResponse = errorResponse;
    }
  }

  /// handle Error Response
  ErrorResponse handleError(Object error) {
    ErrorResponse errorResponse = ErrorResponse();
    Errors errorDescription = Errors();

    if (error is DioException) {
      DioException dioException = error;

      switch (dioException.type) {
        case DioExceptionType.cancel:
          errorDescription.code = "0";
          errorDescription.message = "Request Cancelled";
          errorResponse.statusCode = 0;
          break;

        case DioExceptionType.connectionTimeout:
          errorDescription.code = "522";
          errorDescription.message = "Connection Timeout";
          errorResponse.statusCode = 522;
          break;

        case DioExceptionType.sendTimeout:
          errorDescription.code = "408";
          errorDescription.message = "Send Timeout";
          errorResponse.statusCode = 408;
          break;

        case DioExceptionType.receiveTimeout:
          errorDescription.code = "408";
          errorDescription.message = "Receive Timeout";
          errorResponse.statusCode = 408;
          break;

        case DioExceptionType.badResponse:
          if (dioException.response != null) {
            final statusCode = dioException.response!.statusCode!;
            errorDescription.code = statusCode.toString();
            errorResponse.statusCode = statusCode;

            if (statusCode == 401) {
              try {
                final message = dioException.response!.data["message"] ??
                    dioException.response!.data["error"] ??
                    dioException.response!.data["errors"]?[0]?["message"];

                if (message != null &&
                    (message.toLowerCase().contains("token") ||
                        message.toLowerCase().contains("expired"))) {
                  errorDescription.message =
                      "Session expired. Please login again.";
                  errorResponse.message =
                      "Session expired. Please login again.";
                } else if (message != null &&
                    (message.toLowerCase().contains("invalid credentials") ||
                        message.toLowerCase().contains("unauthorized") ||
                        message.toLowerCase().contains("incorrect"))) {
                  errorDescription.message =
                      "Invalid credentials. Please try again.";
                  errorResponse.message =
                      "Invalid credentials. Please try again.";
                } else {
                  errorDescription.message = message;
                  errorResponse.message = message;
                }
              } catch (_) {
                errorDescription.message = "Unauthorized access";
                errorResponse.message = "Unauthorized access";
              }
            } else if (statusCode == 403) {
              errorDescription.message = "Access forbidden";
              errorResponse.message = "Access forbidden";
            } else if (statusCode == 404) {
              errorDescription.message = "Resource not found";
              errorResponse.message = "Resource not found";
            } else if (statusCode == 500) {
              errorDescription.message = "Internal Server Error";
              errorResponse.message = "Internal Server Error";
            } else if (statusCode >= 400 && statusCode < 500) {
              // Client errors - try to get API message
              try {
                final apiMessage = dioException.response!.data["message"] ??
                    dioException.response!.data["errors"]?[0]?["message"];
                errorDescription.message =
                    apiMessage ?? "Client error occurred";
                errorResponse.message = apiMessage ?? "Client error occurred";
              } catch (_) {
                errorDescription.message = "Client error occurred";
                errorResponse.message = "Client error occurred";
              }
            } else if (statusCode >= 500) {
              // Server errors
              errorDescription.message = "Server error occurred";
              errorResponse.message = "Server error occurred";
            } else {
              // Other status codes - fallback to API-provided message
              try {
                final message = dioException.response!.data["message"] ??
                    dioException.response!.data["errors"]?[0]?["message"];
                errorDescription.message = message ?? "Something went wrong";
                errorResponse.message = message ?? "Something went wrong";
              } catch (_) {
                errorDescription.message = "Unexpected error response";
                errorResponse.message = "Unexpected error response";
              }
            }
          } else {
            errorDescription.code = "500";
            errorDescription.message = "Internal Server Error";
            errorResponse.statusCode = 500;
            errorResponse.message = "Internal Server Error";
          }
          break;

        case DioExceptionType.unknown:
          errorDescription.code = "500";
          errorDescription.message = "Unknown error occurred";
          errorResponse.statusCode = 500;
          errorResponse.message = "Unknown error occurred";
          break;

        case DioExceptionType.badCertificate:
          errorDescription.code = "495";
          errorDescription.message = "Bad SSL Certificate";
          errorResponse.statusCode = 495;
          errorResponse.message = "Bad SSL Certificate";
          break;

        case DioExceptionType.connectionError:
          errorDescription.code = "500";
          errorDescription.message = "Connection error occurred";
          errorResponse.statusCode = 500;
          errorResponse.message = "Connection error occurred";
          break;
      }
    } else {
      errorDescription.code = "500";
      errorDescription.message = "An unexpected error occurred";
      errorResponse.statusCode = 500;
      errorResponse.message = "An unexpected error occurred";
    }

    errorResponse.errors = [errorDescription];
    return errorResponse;
  }
}
