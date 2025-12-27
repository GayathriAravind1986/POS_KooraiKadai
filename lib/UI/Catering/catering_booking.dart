import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Catering/catering_bloc.dart';
import 'package:simple/ModelClass/Catering/getAllCateringModel.dart';
import 'package:simple/ModelClass/Catering/getCustomerByLocation.dart';
import 'package:simple/ModelClass/Catering/getItemAddonsForPackageModel.dart';
import 'package:simple/ModelClass/Catering/getPackageModel.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:simple/UI/Order/Helper/time_formatter.dart';

class CateringView extends StatelessWidget {
  final GlobalKey<CateringViewViewState>? cateringKey;
  bool? hasRefreshedCatering;
  CateringView({
    super.key,
    this.cateringKey,
    this.hasRefreshedCatering,
  });

  @override
  Widget build(BuildContext context) {
    return CateringViewView(
        cateringKey: cateringKey, hasRefreshedCatering: hasRefreshedCatering);
  }
}

class CateringViewView extends StatefulWidget {
  final GlobalKey<CateringViewViewState>? cateringKey;
  bool? hasRefreshedCatering;
  CateringViewView({
    super.key,
    this.cateringKey,
    this.hasRefreshedCatering,
  });

  @override
  CateringViewViewState createState() => CateringViewViewState();
}

class CateringViewViewState extends State<CateringViewView> {
  GetLocationModel getLocationModel = GetLocationModel();
  GetCateringModel getCateringModel = GetCateringModel();
  GetCustomerByLocation getCustomerByLocation = GetCustomerByLocation();
  GetPackageModel getPackageModel = GetPackageModel();
  GetItemAddonsForPackageModel getItemAddonsForPackageModel =
      GetItemAddonsForPackageModel();
  String? errorMessage;
  bool cateringLoad = false;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController quantity = TextEditingController();
  final TextEditingController discountAmount = TextEditingController();
  final TextEditingController packageAmount = TextEditingController();
  final TextEditingController addonsAmount = TextEditingController();
  final TextEditingController finalAmount = TextEditingController();
  final TextEditingController balanceAmount = TextEditingController();
  final TextEditingController paidAmount = TextEditingController();
  final TextEditingController totalAmount = TextEditingController();
  final TextEditingController discountAmountCalculated =
      TextEditingController();

  List<Map<String, dynamic>> partialPayments = [];
  String? selectedPartialPaymentMode;
  final TextEditingController partialPaidAmountController =
      TextEditingController();

  String? locationId;
  bool itAddLoad = false;
  bool locLoad = false;
  DateTime selectedDate = DateTime.now();
  String? selectedLocation;
  String? packageId;
  bool saveLoad = false;
  bool editLoad = false;

  ///filter
  TextEditingController searchController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  String? selectedCustomerFilter;
  String? cusIdFilter;
  String? fromDate;
  String? toDate;

  /// pagination
  int offset = 0;
  int currentPage = 0;
  int rowsPerPage = 10;
  int totalItems = 0;
  int totalPages = 1;

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    bool isFromDate,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appPrimaryColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: appPrimaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formatted = DateFormat('yyyy-MM-dd').format(picked);
        controller.text = formatted;

        if (isFromDate) {
          fromDate = formatted;
        } else {
          toDate = formatted;
        }

        context.read<CateringBloc>().add(
              CateringBooking(
                searchController.text,
                locationId ?? "",
                cusIdFilter ?? "",
                fromDate ?? "",
                toDate ?? "",
                rowsPerPage,
                offset,
              ),
            );
      });
    }
  }

  /// save
  String? selectedCustomer;
  String? selectedPackage;
  String? selectedDiscount;
  String? selectedPaymentType;
  String? selectedPaymentMode;

  bool showCustomerError = false;
  bool showPackageError = false;
  bool showDiscountError = false;
  bool showPaymentTypeError = false;
  bool showPaymentModeError = false;
  bool canAddPartialPayment = false;

  String? customerErrorText;
  String? packageErrorText;
  String? discountErrorText;
  String? paymentTypeErrorText;
  String? paymentModeErrorText;
  String? paidAmountError;

  final List<String> discountType = ['Fixed', 'Percentage'];
  final List<String> paymentType = ['Fully Paid', 'Partially Paid'];
  final List<String> paymentMode = ['CASH', 'UPI', 'CARD', 'ONLINE'];

  List<Map<String, dynamic>> items = []; // from API
  List<Map<String, dynamic>> addons = [];

  List<Map<String, dynamic>> selectedItems = [];
  List<Map<String, dynamic>> selectedAddons = [];
  bool validateForm() {
    bool isValid = true;

    setState(() {
      // Reset all error states
      showCustomerError = false;
      showPackageError = false;
      showDiscountError = false;
      showPaymentTypeError = false;
      showPaymentModeError = false;
      customerErrorText = null;
      packageErrorText = null;
      discountErrorText = null;
      paymentTypeErrorText = null;
      paymentModeErrorText = null;
    });

    // Validate customer
    if (selectedCustomer == null || selectedCustomer!.isEmpty) {
      setState(() {
        showCustomerError = true;
        customerErrorText = 'Customer is required';
      });
      isValid = false;
    }

    // Validate package type
    if (selectedPackage == null || selectedPackage!.isEmpty) {
      setState(() {
        showPackageError = true;
        packageErrorText = 'Package is required';
      });
      isValid = false;
    }

    // Validate discount type
    if (selectedDiscount == null || selectedDiscount!.isEmpty) {
      setState(() {
        showDiscountError = true;
        discountErrorText = 'Discount Type is required';
      });
      isValid = false;
    }
    // Validate payment type
    if (selectedPaymentType == null || selectedPaymentType!.isEmpty) {
      setState(() {
        showPaymentTypeError = true;
        paymentTypeErrorText = 'Payment Type is required';
      });
      isValid = false;
    }
    // Validate payment mode
    if (selectedPaymentMode == null || selectedPaymentMode!.isEmpty) {
      setState(() {
        showPaymentModeError = true;
        paymentModeErrorText = 'Payment Mode is required';
      });
      isValid = false;
    }

    return isValid;
  }

  // Show validation message using SnackBar
  void showValidationSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showItemMultiSelect(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  children: [
                    // TITLE
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Select Items",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    const Divider(),

                    // ITEM LIST
                    Expanded(
                      child: ListView(
                        children: items.map((item) {
                          final isSelected =
                              selectedItems.any((e) => e['_id'] == item['_id']);

                          return CheckboxListTile(
                            activeColor: appPrimaryColor,
                            title: Text(item['name']),
                            value: isSelected,
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedItems.add(item);
                                } else {
                                  selectedItems.removeWhere(
                                    (e) => e['_id'] == item['_id'],
                                  );
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    // BUTTONS
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "CANCEL",
                              style: MyTextStyle.f14(appPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              setState(() {
                                calculateTotals(); // Add this
                              });
                            },
                            label: const Text("OK"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appPrimaryColor,
                              foregroundColor: whiteColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.01, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddonMultiSelect(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  children: [
                    // TITLE
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Select Addons",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    const Divider(),

                    // ITEM LIST
                    Expanded(
                      child: ListView(
                        children: addons.map((item) {
                          final isSelected = selectedAddons
                              .any((e) => e['_id'] == item['_id']);

                          return CheckboxListTile(
                            activeColor: appPrimaryColor,
                            title: Text(item['name']),
                            value: isSelected,
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedAddons.add(item);
                                } else {
                                  selectedAddons.removeWhere(
                                    (e) => e['_id'] == item['_id'],
                                  );
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    // BUTTONS
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "CANCEL",
                              style: MyTextStyle.f14(appPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              setState(() {
                                calculateTotals(); // Add this
                              });
                            },
                            label: const Text("OK"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appPrimaryColor,
                              foregroundColor: whiteColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.01, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double packagePrice = 0.0;

  void calculateTotals() {
    double packagePrice = 0.0;
    int qty = int.tryParse(quantity.text) ?? 1;

    if (selectedPackage != null && getPackageModel.data != null) {
      var pack =
          getPackageModel.data!.firstWhere((p) => p.id == selectedPackage);
      packagePrice = (pack.price ?? 0).toDouble();
    }

    // 1️⃣ Package Amount
    double packageTotal = packagePrice * qty;
    packageAmount.text = packageTotal.toStringAsFixed(0);

    // 2️⃣ Addon Amount
    double addonsPerUnit = 0;
    for (var addon in selectedAddons) {
      if (addon['isFree'] != true) {
        addonsPerUnit += (addon['price'] ?? 0).toDouble();
      }
    }
    double addonsTotal = addonsPerUnit * qty;
    addonsAmount.text = addonsTotal.toStringAsFixed(0);

    // 3️⃣ Total Amount ✅ (FIXED)
    double total = packageTotal + addonsTotal;
    totalAmount.text = total.toStringAsFixed(0);

    // 4️⃣ Discount
    double discountInput = double.tryParse(discountAmount.text) ?? 0;

    double discountValue = selectedDiscount == 'Fixed'
        ? discountInput
        : (total * discountInput) / 100;

    discountAmountCalculated.text = discountValue.toStringAsFixed(0);

    // 5️⃣ Final Amount
    double finalTotal = total - discountValue;
    finalAmount.text = finalTotal.toStringAsFixed(0);

    // 6️⃣ Payment Logic
    if (selectedPaymentType == 'Fully Paid') {
      paidAmount.text = finalTotal.toStringAsFixed(0);
      balanceAmount.text = "0";
    } else {
      double totalPaid = partialPayments.fold(
        0.0,
        (sum, p) => sum + (p['amount'] ?? 0),
      );

      paidAmount.text = totalPaid.toStringAsFixed(0);
      balanceAmount.text = (finalTotal - totalPaid).toStringAsFixed(0);
    }

    setState(() {});
  }

  void calculateTotalsWithCurrentInput() {
    double packagePrice = 0.0;
    int qty = int.tryParse(quantity.text) ?? 1;

    if (selectedPackage != null && getPackageModel.data != null) {
      var pack =
          getPackageModel.data!.firstWhere((p) => p.id == selectedPackage);
      packagePrice = (pack.price ?? 0).toDouble();
    }

    // 1️⃣ Package Amount
    double packageTotal = packagePrice * qty;
    packageAmount.text = packageTotal.toStringAsFixed(0);

    // 2️⃣ Addon Amount
    double addonsPerUnit = 0.0;
    for (var addon in selectedAddons) {
      if (addon['isFree'] != true) {
        addonsPerUnit += (addon['price'] ?? 0).toDouble();
      }
    }
    double addonsTotal = addonsPerUnit * qty;
    addonsAmount.text = addonsTotal.toStringAsFixed(0);

    // 3️⃣ Total Amount
    double total = packageTotal + addonsTotal;
    totalAmount.text = total.toStringAsFixed(0);

    // 4️⃣ Discount
    double discountInput = double.tryParse(discountAmount.text) ?? 0.0;

    double discountValue = selectedDiscount == 'Fixed'
        ? discountInput
        : (total * discountInput) / 100;

    discountAmountCalculated.text = discountValue.toStringAsFixed(0);

    // 5️⃣ Final Amount
    double finalTotal = total - discountValue;
    finalAmount.text = finalTotal.toStringAsFixed(0);

    // 6️⃣ Paid & Balance
    // 6️⃣ Paid & Balance
    if (selectedPaymentType == 'Fully Paid') {
      paidAmount.text = finalTotal.toStringAsFixed(0);
      balanceAmount.text = "0";
    } else if (selectedPaymentType == 'Partially Paid') {
      double alreadyPaid = partialPayments.fold(
        0.0,
        (sum, p) => sum + (p['amount'] ?? 0.0),
      );

      double current = double.tryParse(partialPaidAmountController.text) ?? 0.0;

      double totalPaid = alreadyPaid + current;

      if (totalPaid > finalTotal) {
        // ❌ ERROR CONDITION
        paidAmountError = "Amount exceeds final amount";

        // keep last valid values
        paidAmount.text = alreadyPaid.toStringAsFixed(0);
        balanceAmount.text = (finalTotal - alreadyPaid).toStringAsFixed(0);
      } else {
        // ✅ VALID
        paidAmountError = null;

        paidAmount.text = totalPaid.toStringAsFixed(0);
        balanceAmount.text = (finalTotal - totalPaid).toStringAsFixed(0);
      }
    }
    canAddPartialPayment = selectedPaymentType == 'Partially Paid' &&
        paidAmountError == null &&
        balanceAmount.text != "0" &&
        partialPaidAmountController.text.isNotEmpty;
    setState(() {});
  }

  void addPartialPayment() {
    if (selectedPartialPaymentMode == null ||
        selectedPartialPaymentMode!.isEmpty) {
      showValidationSnackBar('Please select payment mode');
      return;
    }

    double amount = double.tryParse(partialPaidAmountController.text) ?? 0.0;
    if (amount <= 0) {
      showValidationSnackBar('Please enter valid payment amount');
      return;
    }

    double finalAmt = double.tryParse(finalAmount.text) ?? 0.0;
    double totalPaid = 0.0;
    for (var payment in partialPayments) {
      totalPaid += payment['amount'] ?? 0.0;
    }

    if ((totalPaid + amount) > finalAmt) {
      showValidationSnackBar('Total paid amount cannot exceed final amount');
      return;
    }

    setState(() {
      partialPayments.add({
        'mode': selectedPartialPaymentMode,
        'amount': amount,
      });
      selectedPartialPaymentMode = null;
      partialPaidAmountController.clear();
      calculateTotals();
    });
  }

  void removePartialPayment(int index) {
    setState(() {
      partialPayments.removeAt(index);
      calculateTotals();
    });
  }

  void clearPartialPaymentInput() {
    setState(() {
      selectedPartialPaymentMode = null;
      partialPaidAmountController.clear();
      paidAmountError = null;

      // Recalculate paid & balance WITHOUT current typing
      double finalTotal = double.tryParse(finalAmount.text) ?? 0.0;

      double alreadyPaid = partialPayments.fold(
        0.0,
        (sum, p) => sum + (p['amount'] ?? 0.0),
      );

      paidAmount.text = alreadyPaid.toStringAsFixed(0);
      balanceAmount.text = (finalTotal - alreadyPaid).toStringAsFixed(0);

      // Re-enable add button if balance exists
      canAddPartialPayment = (finalTotal - alreadyPaid) > 0;
    });
  }

  void clearCateringForm() {
    setState(() {
      selectedCustomer = null;
      selectedPackage = null;
      selectedDiscount = null;
      selectedPaymentType = null;
      selectedPaymentMode = null;
      partialPayments.clear();
      selectedPartialPaymentMode = null;
      partialPaidAmountController.clear();
    });
  }

  String mapPaymentForApi(String? payment) {
    switch (payment) {
      case "Cash":
        return "cash";
      case "Card":
        return "card";
      case "UPI":
        return "upi";
      case "Bank Transfer":
        return "bank_transfer";
      case "Other":
        return "other";
      default:
        return "";
    }
  }

  List<String> paymentMethods = [
    "Card",
    "Cash",
    "Bank Transfer",
    "UPI",
    "Other"
  ];

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appPrimaryColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    appPrimaryColor, // OK & Cancel button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  bool expenseShowLoad = false;
  bool isEdit = false;
  String? cateringId;

  void refreshCatering() {
    if (!mounted || !context.mounted) return;
    context.read<CateringBloc>().add(CateringLocation());
    setState(() {
      locLoad = true;
    });
  }

  @override
  void initState() {
    super.initState();
    dateController.text =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    if (widget.hasRefreshedCatering == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          locLoad = true;
          cateringLoad = true;
        });
        widget.cateringKey?.currentState?.refreshCatering();
      });
    } else {
      context.read<CateringBloc>().add(CateringLocation());

      setState(() {
        locLoad = true;
      });
    }
  }

  void _refreshData() {
    setState(() {
      searchController.clear();
      fromDateController.clear();
      toDateController.clear();
      fromDate = null;
      toDate = null;
      selectedCustomerFilter = null;
      cusIdFilter = null;
      locLoad = true;
      offset = 0;
      currentPage = 0;
      rowsPerPage = 10;
      totalItems = 0;
      totalPages = 1;
    });
    context.read<CateringBloc>().add(CateringLocation());
    context.read<CateringBloc>().add(CateringBooking(
        searchController.text,
        locationId ?? "",
        cusIdFilter ?? "",
        fromDate ?? "",
        toDate ?? "",
        offset,
        rowsPerPage));
    widget.cateringKey?.currentState?.refreshCatering();
  }

  // void _refreshEditData() {
  //   setState(() {
  //     isEdit = false;
  //     selectedCategory = null;
  //     selectedPayment = null;
  //     amountController.clear();
  //     nameController.clear();
  //   });
  //   context.read<CateringBloc>().add(CateringLocation());
  //   widget.cateringKey?.currentState?.refreshCatering();
  // }

  @override
  void dispose() {
    super.dispose();
  }

  void reloadCategory() {
    offset = currentPage * rowsPerPage;

    context.read<CateringBloc>().add(CateringBooking(
        searchController.text,
        locationId ?? "",
        cusIdFilter ?? "",
        fromDate ?? "",
        toDate ?? "",
        offset,
        rowsPerPage));
  }

  double get balanceValue {
    return double.tryParse(balanceAmount.text) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildPaginationBar() {
      int start = offset + 1;
      int end = offset + rowsPerPage;

      if (end > totalItems) {
        end = totalItems;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ---- Rows Per Page Dropdown ----
          Text("Rows per page: "),
          DropdownButton<int>(
            value: rowsPerPage,
            items: [5, 10, 20, 50].map((e) {
              return DropdownMenuItem(value: e, child: Text("$e"));
            }).toList(),
            onChanged: (value) {
              setState(() {
                rowsPerPage = value!;
                currentPage = 0;
                offset = 0;
                totalPages = (totalItems / rowsPerPage).ceil();
              });

              reloadCategory();
            },
          ),

          const SizedBox(width: 20),

          // ---- Page X of Y ----
          Text("$start - $end of $totalItems"),
          // ---- Prev Button ----
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 0
                ? () {
                    setState(() {
                      currentPage--;
                      offset = currentPage * rowsPerPage;
                    });
                    reloadCategory();
                  }
                : null,
          ),

          // ---- Next Button ----
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1
                ? () {
                    setState(() {
                      currentPage++;
                      offset = currentPage * rowsPerPage;
                    });
                    reloadCategory();
                  }
                : null,
          ),
        ],
      );
    }

    Widget mainContainer() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isEdit ? "Edit Booking" : "Add Booking",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (isEdit)
                    IconButton(
                      onPressed: () {
                        //  _refreshEditData();
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: appPrimaryColor,
                        size: 28,
                      ),
                      tooltip: 'Refresh Booking',
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- Row 1 ----------------

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Date",
                        labelStyle: TextStyle(color: greyColor),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: pickDate,
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: appPrimaryColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  getLocationModel.data?.locationName != null
                      ? Expanded(
                          child: TextFormField(
                            enabled: false,
                            initialValue: getLocationModel.data!.locationName!,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              labelStyle: TextStyle(color: appPrimaryColor),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: greyColor),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: greyColor),
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),

              const SizedBox(height: 15),

              // ---------------- Row 2 ----------------
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Customer *',
                        labelStyle: TextStyle(
                            color: showCustomerError
                                ? redColor
                                : (selectedCustomer != null
                                    ? appPrimaryColor
                                    : greyColor)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: showCustomerError ? redColor : greyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: showCustomerError
                                  ? redColor
                                  : appPrimaryColor,
                              width: 2),
                        ),
                        errorText: showCustomerError ? customerErrorText : null,
                      ),
                      value: selectedCustomer,
                      items: (getCustomerByLocation.data ?? [])
                          .map<DropdownMenuItem<String>>(
                              (cus) => DropdownMenuItem<String>(
                                    value: cus.id,
                                    child: Text(cus.name ?? 'No Name'),
                                  ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCustomer = value;
                          showCustomerError = false;
                          customerErrorText = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Package *',
                        labelStyle: TextStyle(
                            color: showPackageError
                                ? redColor
                                : (selectedPackage != null
                                    ? appPrimaryColor
                                    : greyColor)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: showPackageError ? redColor : greyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  showPackageError ? redColor : appPrimaryColor,
                              width: 2),
                        ),
                        errorText: showPackageError ? packageErrorText : null,
                      ),
                      value: selectedPackage,
                      items: (getPackageModel.data ?? [])
                          .map<DropdownMenuItem<String>>(
                              (pack) => DropdownMenuItem<String>(
                                    value: pack.id,
                                    child: Text(
                                        "${pack.name} - ₹ ${pack.price}" ??
                                            'No Name'),
                                  ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPackage = value;
                          showPackageError = false;
                          packageErrorText = null;
                          quantity.text = "1";
                          packageId = value;
                          debugPrint("packageId:$packageId");
                          debugPrint("quantity:${quantity.text}");
                          context
                              .read<CateringBloc>()
                              .add(CateringItemAddons(packageId.toString()));
                          calculateTotals();
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ---------------- Row 3 ----------------
              Row(
                children: [
                  if (selectedPackage != null)
                    Expanded(
                      child: TextFormField(
                          readOnly: false,
                          controller: quantity,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: "Quantity *",
                            labelStyle: TextStyle(color: greyColor),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: appPrimaryColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: appPrimaryColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: redColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onChanged: (val) {
                            //_formKey.currentState!.validate();
                            calculateTotals();
                          },
                          validator: (value) {
                            if (value != null) {
                              if (value.isEmpty) {
                                return 'Enter Quantity';
                              } else {
                                return null;
                              }
                            }
                            return null;
                          }),
                    ),
                  if (selectedPackage != null) const SizedBox(width: 20),
                  if (selectedPackage != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showItemMultiSelect(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Items",
                            labelStyle: TextStyle(color: greyColor),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedItems.isEmpty
                                ? "Select Items"
                                : selectedItems
                                    .map((e) => e['name'])
                                    .join(', '),
                            style: TextStyle(color: greyColor),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (selectedPackage != null) const SizedBox(height: 15),
              if (selectedPackage != null)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showAddonMultiSelect(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Addons",
                            labelStyle: TextStyle(color: greyColor),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedAddons.isEmpty
                                ? "Select Addons"
                                : selectedAddons.map((e) {
                                    final price = e['price'] ?? 0;
                                    return price == 0
                                        ? "${e['name']} (Free)"
                                        : "${e['name']} (₹$price)";
                                  }).join(', '),
                            style: TextStyle(color: greyColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Discount Type *',
                          labelStyle: TextStyle(
                              color: showDiscountError
                                  ? redColor
                                  : (selectedDiscount != null
                                      ? appPrimaryColor
                                      : greyColor)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    showDiscountError ? redColor : greyColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: showDiscountError
                                    ? redColor
                                    : appPrimaryColor,
                                width: 2),
                          ),
                          errorText:
                              showDiscountError ? discountErrorText : null,
                        ),
                        value: selectedDiscount,
                        items: discountType
                            .map((tax) => DropdownMenuItem(
                                  value: tax,
                                  child: Text(tax),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDiscount = value;
                            showDiscountError = false;
                            discountErrorText = null;
                            discountAmount.clear();
                            selectedPaymentType = null;
                            selectedPaymentMode = null;
                            partialPayments.clear();
                            selectedPartialPaymentMode = null;
                            partialPaidAmountController.clear();
                            calculateTotals();
                          });
                        },
                      ),
                    ),
                    if (selectedDiscount != null) const SizedBox(width: 20),
                    if (selectedDiscount != null)
                      Expanded(
                        child: TextFormField(
                          readOnly: false,
                          controller: discountAmount,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: "Discount Amount *",
                            labelStyle: TextStyle(color: greyColor),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: appPrimaryColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: appPrimaryColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: redColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onChanged: (val) {
                            calculateTotals();
                          },
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Payment Type *',
                  labelStyle: TextStyle(
                      color: showPaymentTypeError
                          ? redColor
                          : (selectedPaymentType != null
                              ? appPrimaryColor
                              : greyColor)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: showPaymentTypeError ? redColor : greyColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            showPaymentTypeError ? redColor : appPrimaryColor,
                        width: 2),
                  ),
                  errorText: showPaymentTypeError ? paymentTypeErrorText : null,
                ),
                value: selectedPaymentType,
                items: paymentType
                    .map((tax) => DropdownMenuItem(
                          value: tax,
                          child: Text(tax),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPaymentType = value;
                    showPaymentTypeError = false;
                    paymentTypeErrorText = null;
                    calculateTotals();
                  });
                },
              ),
              // Payment Mode Section based on Payment Type
              if (selectedPaymentType == "Fully Paid") ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Payment Mode *',
                      labelStyle: TextStyle(
                          color: showPaymentModeError
                              ? redColor
                              : (selectedPaymentMode != null
                                  ? appPrimaryColor
                                  : greyColor)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: showPaymentModeError ? redColor : greyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: showPaymentModeError
                                ? redColor
                                : appPrimaryColor,
                            width: 2),
                      ),
                      errorText:
                          showPaymentModeError ? paymentModeErrorText : null,
                    ),
                    value: selectedPaymentMode,
                    items: paymentMode
                        .map((mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMode = value;
                        showPaymentModeError = false;
                        paymentModeErrorText = null;
                      });
                    },
                  ),
                ),
              ],

              // Partially Paid Section
              if (selectedPaymentType == "Partially Paid") ...[
                const SizedBox(height: 16),

                // Display existing partial payments
                ...partialPayments.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> payment = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Payment Mode Display
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Payment Mode: ',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  payment['mode'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Paid Amount Display
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Paid Amount: ',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  payment['amount'].toStringAsFixed(0),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Remove Button
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => removePartialPayment(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: redColor,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '-',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // Add new partial payment row
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Payment Mode Dropdown
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Payment Mode',
                            labelStyle: TextStyle(color: appPrimaryColor),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: appPrimaryColor, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          value: selectedPartialPaymentMode,
                          items: paymentMode
                              .map((mode) => DropdownMenuItem(
                                    value: mode,
                                    child: Text(mode),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPartialPaymentMode = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Paid Amount TextField
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: partialPaidAmountController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          onChanged: (value) {
                            calculateTotalsWithCurrentInput();
                          },
                          decoration: InputDecoration(
                            labelText: 'Paid Amount',
                            labelStyle: TextStyle(color: appPrimaryColor),
                            errorText: paidAmountError,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: appPrimaryColor, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Add Button
                      // SizedBox(
                      //   width: 50,
                      //   height: 50,
                      //   child: ElevatedButton(
                      //     onPressed: addPartialPayment,
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.green,
                      //       padding: EdgeInsets.zero,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //     child: Text(
                      //       '+',
                      //       style: TextStyle(
                      //         color: whiteColor,
                      //         fontSize: 24,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              canAddPartialPayment ? addPartialPayment : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAddPartialPayment
                                ? Colors.green
                                : Colors.grey,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '+',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Clear Button
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: clearPartialPaymentInput,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redColor,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '-',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              /// AMOUNTS ROW
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    readOnly: true,
                    controller: packageAmount,
                    decoration: InputDecoration(
                      labelText: "Package Amount",
                      labelStyle: TextStyle(color: greyColor),
                      border: const OutlineInputBorder(),
                    ),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                    readOnly: true,
                    controller: addonsAmount,
                    decoration: InputDecoration(
                      labelText: "Addon Amount",
                      labelStyle: TextStyle(color: greyColor),
                      border: const OutlineInputBorder(),
                    ),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                    readOnly: true,
                    controller: totalAmount,
                    decoration: InputDecoration(
                      labelText: "Total Amount",
                      labelStyle: TextStyle(color: greyColor),
                      border: const OutlineInputBorder(),
                    ),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                    readOnly: true,
                    controller: discountAmountCalculated,
                    decoration: InputDecoration(
                      labelText: "Discount Amount",
                      labelStyle: TextStyle(color: greyColor),
                      border: const OutlineInputBorder(),
                    ),
                  )),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                    readOnly: true,
                    controller: finalAmount,
                    decoration: InputDecoration(
                      labelText: "Final Amount",
                      labelStyle: TextStyle(color: greyColor),
                      border: const OutlineInputBorder(),
                    ),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                    readOnly: true,
                    controller: balanceAmount,
                    decoration: InputDecoration(
                      labelText: "Balance Amount",
                      labelStyle: TextStyle(color: greyColor),
                      border: const OutlineInputBorder(),
                    ),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: paidAmount,
                      decoration: InputDecoration(
                        labelText: "Paid Amount",
                        labelStyle: TextStyle(color: greyColor),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        calculateTotalsWithCurrentInput();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              isEdit == true
                  ? Center(
                      child: editLoad
                          ? SpinKitCircle(color: appPrimaryColor, size: 30)
                          : ElevatedButton(
                              onPressed: () {
                                // final parsed = DateFormat("dd/MM/yyyy")
                                //     .parse(dateController.text);
                                // final backendDate =
                                //     DateFormat("yyyy-MM-dd").format(parsed);
                                // debugPrint("date:$backendDate");
                                // if (getLocationModel.data!.locationName ==
                                //     null) {
                                //   showToast("Location not found", context,
                                //       color: false);
                                // } else if (selectedCategory == null) {
                                //   showToast("Select Category", context,
                                //       color: false);
                                // } else if (selectedPayment == null) {
                                //   showToast("Select payment method", context,
                                //       color: false);
                                // } else if (nameController.text.isEmpty) {
                                //   showToast("Enter category name", context,
                                //       color: false);
                                // } else if (amountController.text.isEmpty) {
                                //   showToast("Enter amount", context,
                                //       color: false);
                                // } else {
                                //   setState(() {
                                //     editLoad = true;
                                //     context.read<ExpenseBloc>().add(
                                //         UpdateExpense(
                                //             expenseId.toString(),
                                //             backendDate,
                                //             categoryId.toString(),
                                //             nameController.text,
                                //             selectedPayment == "Cash"
                                //                 ? "cash"
                                //                 : selectedPayment == "Card"
                                //                     ? "card"
                                //                     : selectedPayment == "UPI"
                                //                         ? "upi"
                                //                         : selectedPayment ==
                                //                                 "Bank Transfer"
                                //                             ? "bank_transfer"
                                //                             : "other",
                                //             amountController.text,
                                //             locationId.toString()));
                                //   });
                                // }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appPrimaryColor,
                                minimumSize: const Size(0, 50), // Height only
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Update Booking",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                    )
                  : Center(
                      child: saveLoad
                          ? SpinKitCircle(color: appPrimaryColor, size: 30)
                          : ElevatedButton(
                              onPressed: () {
                                final parsed = DateFormat("dd/MM/yyyy")
                                    .parse(dateController.text);
                                final backendDate =
                                    DateFormat("yyyy-MM-dd").format(parsed);
                                debugPrint("date:$backendDate");
                                // if (getLocationModel.data!.locationName ==
                                //     null) {
                                //   showToast("Location not found", context,
                                //       color: false);
                                // } else if (selectedCategory == null) {
                                //   showToast("Select Category", context,
                                //       color: false);
                                // } else if (selectedPayment == null) {
                                //   showToast("Select payment method", context,
                                //       color: false);
                                // } else if (nameController.text.isEmpty) {
                                //   showToast("Enter category name", context,
                                //       color: false);
                                // } else if (amountController.text.isEmpty) {
                                //   showToast("Enter amount", context,
                                //       color: false);
                                // } else {
                                //   setState(() {
                                //     saveLoad = true;
                                //     context.read<ExpenseBloc>().add(SaveExpense(
                                //         backendDate,
                                //         categoryId.toString(),
                                //         nameController.text,
                                //         selectedPayment == "Cash"
                                //             ? "cash"
                                //             : selectedPayment == "Card"
                                //                 ? "card"
                                //                 : selectedPayment == "UPI"
                                //                     ? "upi"
                                //                     : selectedPayment ==
                                //                             "Bank Transfer"
                                //                         ? "bank_transfer"
                                //                         : "other",
                                //         amountController.text,
                                //         locationId.toString()));
                                //   });
                                // }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appPrimaryColor,
                                minimumSize: const Size(0, 50), // Height only
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "SAVE",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                    ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Booking List",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Filters",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name...',
                        hintStyle: TextStyle(color: greyColor),
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: appPrimaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: appPrimaryColor, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        searchController
                          ..text = (value)
                          ..selection = TextSelection.collapsed(
                              offset: searchController.text.length);
                        setState(() {
                          context.read<CateringBloc>().add(CateringBooking(
                              searchController.text,
                              locationId ?? "",
                              cusIdFilter ?? "",
                              fromDate ?? "",
                              toDate ?? "",
                              offset,
                              rowsPerPage));
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (getCustomerByLocation.data?.any((item) =>
                                  item.name == selectedCustomerFilter) ??
                              false)
                          ? selectedCustomerFilter
                          : null,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appPrimaryColor,
                      ),
                      isExpanded: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: appPrimaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: appPrimaryColor, width: 2),
                        ),
                      ),
                      items: getCustomerByLocation.data?.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(
                            "${item.name}",
                            style: MyTextStyle.f14(
                              blackColor,
                              weight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCustomerFilter = newValue;
                            final selectedItem = getCustomerByLocation.data
                                ?.firstWhere((item) => item.name == newValue);
                            cusIdFilter = selectedItem?.id.toString();
                            context.read<CateringBloc>().add(CateringBooking(
                                searchController.text,
                                locationId ?? "",
                                cusIdFilter ?? "",
                                fromDate ?? "",
                                toDate ?? "",
                                offset,
                                rowsPerPage));
                          });
                        }
                      },
                      hint: Text(
                        'All Customer',
                        style: MyTextStyle.f14(
                          greyColor,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: fromDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'From Date',
                        labelStyle: TextStyle(color: greyColor),
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: appPrimaryColor, width: 2),
                        ),
                      ),
                      onTap: () =>
                          _selectDate(context, fromDateController, true),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: toDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'From Date',
                        labelStyle: TextStyle(color: greyColor),
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: appPrimaryColor, width: 2),
                        ),
                      ),
                      onTap: () =>
                          _selectDate(context, toDateController, false),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {
                      _refreshData();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        minimumSize: const Size(0, 50), // Height only
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )),
                    child: const Text(
                      "CLEAR FILTERS",
                      style: TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Replace your DataTable widget with this responsive version

              cateringLoad
                  ? Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1),
                      alignment: Alignment.center,
                      child: const SpinKitChasingDots(
                          color: appPrimaryColor, size: 30))
                  : getCateringModel.data == null ||
                          getCateringModel.data == [] ||
                          getCateringModel.data!.isEmpty
                      ? Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.1),
                          alignment: Alignment.center,
                          child: Text(
                            "No Catering Today !!!",
                            style: MyTextStyle.f16(
                              greyColor,
                              weight: FontWeight.w500,
                            ),
                          ))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth:
                                      constraints.maxWidth, // 🔥 FULL WIDTH
                                ),
                                child: Card(
                                  elevation: 2,
                                  child: Column(
                                    children: [
                                      DataTable(
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                                greyColor200),
                                        columnSpacing: 32,
                                        columns: const [
                                          DataColumn(label: Text('Date')),
                                          DataColumn(label: Text('Customer')),
                                          DataColumn(label: Text('Location')),
                                          DataColumn(label: Text('Amount')),
                                          DataColumn(
                                              label: Text('Payment Type')),
                                          DataColumn(label: Text('Balance')),
                                          DataColumn(
                                              label: Text('Payment Mode')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows:
                                            getCateringModel.data!.map((item) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(DateTime.parse(
                                                          item.date!)))),
                                              DataCell(Text(
                                                  item.customer?.name ?? "")),
                                              DataCell(Text(
                                                  item.location?.name ?? "")),
                                              DataCell(Text(item.finalamount
                                                      ?.toString() ??
                                                  "-")),
                                              DataCell(Text(
                                                  item.paymenttype.toString() ??
                                                      "")),
                                              DataCell(Text(item.balanceamount
                                                      ?.toString() ??
                                                  "-")),
                                              DataCell(
                                                Text(
                                                  (item.paymentmode != null &&
                                                          item.paymentmode!
                                                              .isNotEmpty)
                                                      ? item.paymentmode!
                                                      : item.paymentdetails !=
                                                                  null &&
                                                              item.paymentdetails!
                                                                  .isNotEmpty
                                                          ? item.paymentdetails!
                                                              .map((e) =>
                                                                  "${e.mode}")
                                                              .join(", ")
                                                          : "-",
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {},
                                                      child: const Icon(
                                                          Icons.edit,
                                                          color:
                                                              appPrimaryColor),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    InkWell(
                                                      onTap: () {},
                                                      child: const Icon(
                                                          Icons.delete,
                                                          color: redColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                      buildPaginationBar(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<CateringBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetLocationModel) {
          getLocationModel = current;
          if (getLocationModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getLocationModel.success == true) {
            locationId = getLocationModel.data?.locationId;
            debugPrint("locationId:$locationId");
            context
                .read<CateringBloc>()
                .add(CateringCustomer(locationId.toString()));
            context
                .read<CateringBloc>()
                .add(CateringPackage(locationId.toString()));
            context.read<CateringBloc>().add(CateringBooking(
                searchController.text,
                locationId ?? "",
                cusIdFilter ?? "",
                fromDate ?? "",
                toDate ?? "",
                offset,
                rowsPerPage));
            setState(() {
              locLoad = false;
              cateringLoad = true;
            });
          } else {
            debugPrint("${getLocationModel.data?.locationName}");
            setState(() {
              locLoad = false;
            });
            showToast("No Location found", context, color: false);
          }
          return true;
        }
        if (current is GetCustomerByLocation) {
          getCustomerByLocation = current;
          if (getCustomerByLocation.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getCustomerByLocation.success == true) {
            setState(() {
              locLoad = false;
            });
          } else {
            setState(() {
              locLoad = false;
            });
            showToast("No Customer for this location", context, color: false);
          }
          return true;
        }
        if (current is GetPackageModel) {
          getPackageModel = current;
          if (getPackageModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getPackageModel.success == true) {
            setState(() {
              locLoad = false;
            });
          } else {
            setState(() {
              locLoad = false;
            });
            showToast("No Package for this location", context, color: false);
          }
          return true;
        }
        if (current is GetItemAddonsForPackageModel) {
          getItemAddonsForPackageModel = current;
          if (getItemAddonsForPackageModel.errorResponse?.isUnauthorized ==
              true) {
            _handle401Error();
            return true;
          }
          if (getItemAddonsForPackageModel.success == true) {
            setState(() {
              itAddLoad = false;
              items = getItemAddonsForPackageModel.data?.items
                      ?.map((e) => {
                            '_id': e.id,
                            'name': e.name,
                          })
                      .toList() ??
                  [];
              addons = getItemAddonsForPackageModel.data?.addons
                      ?.map((e) => {
                            '_id': e.id,
                            'name': e.name,
                            'price': e.price,
                            'isFree': e.isFree,
                          })
                      .toList() ??
                  [];
            });
          } else {
            setState(() {
              itAddLoad = false;
            });
            showToast("No Item/Addons for this package", context, color: false);
          }
          return true;
        }
        if (current is GetCateringModel) {
          getCateringModel = current;
          if (getCateringModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getCateringModel.success == true) {
            setState(() {
              cateringLoad = false;
              totalItems = int.parse(getCateringModel.total.toString());
              debugPrint("totalItem:$totalItems"); // API response
              totalPages = (totalItems / rowsPerPage).ceil();
            });
          } else {
            setState(() {
              cateringLoad = false;
            });
            showToast("No Catering found", context, color: false);
          }
          return true;
        }
        return false;
      }),
      builder: (context, dynamic) {
        return mainContainer();
      },
    );
  }

  void _handle401Error() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("token");
    await sharedPreferences.clear();
    showToast("Session expired. Please login again.", context, color: false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
