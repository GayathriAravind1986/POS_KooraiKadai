import 'package:intl/intl.dart';

class BookingPayloadHelper {
  static Map<String, dynamic> buildCommonPayload({
    required String locationId,
    required String customerId,
    required String packageId,
    required String date,
    required int quantity,
    required List<Map<String, dynamic>> selectedItems,
    required List<Map<String, dynamic>> selectedAddons,
    required String selectedDiscount,
    required String packageAmount,
    required String addonsAmount,
    required String totalAmount,
    required String discountInput,
    required String discountCalculated,
    required String finalAmount,
    required String paidAmount,
    required String balanceAmount,
  }) {
    final parsedDate = DateFormat("dd/MM/yyyy").parse(date);
    final backendDate = DateFormat("yyyy-MM-dd").format(parsedDate);

    return {
      "locationId": locationId,
      "date": backendDate,
      "customerId": customerId,
      "packageId": packageId,
      "quantity": quantity,
      "items": selectedItems.map((e) => e['_id']).toList(),
      "addons": selectedAddons.map((e) => e['_id']).toList(),
      "packageamount": double.tryParse(packageAmount) ?? 0,
      "addonsamount": double.tryParse(addonsAmount) ?? 0,
      "totalamount": double.tryParse(totalAmount) ?? 0,
      "discounttype": selectedDiscount,
      "discountvalue": double.tryParse(discountInput) ?? 0,
      "discountamount": double.tryParse(discountCalculated) ?? 0,
      "finalamount": double.tryParse(finalAmount) ?? 0,
      "paidamount": double.tryParse(paidAmount) ?? 0,
      "balanceamount": double.tryParse(balanceAmount) ?? 0,
    };
  }

  static Map<String, dynamic> buildFinalPayload({
    required Map<String, dynamic> basePayload,
    required String paymentType,
    String? paymentMode,
    List<Map<String, dynamic>>? partialPayments,
  }) {
    final payload = Map<String, dynamic>.from(basePayload);

    if (paymentType == "Partially Paid") {
      payload.addAll({
        "paymenttype": "PARTIALLY",
        "paymentdetails": partialPayments
                ?.map((p) => {
                      "mode": p['mode'],
                      "amount": p['amount'],
                    })
                .toList() ??
            [],
      });
    } else {
      payload.addAll({
        "paymenttype": "FULLY",
        "paymentmode": paymentMode,
      });
    }

    return payload;
  }
}
