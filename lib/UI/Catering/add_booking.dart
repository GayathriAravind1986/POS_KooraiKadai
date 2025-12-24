import 'package:intl/intl.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Catering/catering_bloc.dart';
import 'package:simple/ModelClass/Catering/getCustomerByLocation.dart';
import 'package:simple/ModelClass/Catering/getItemAddonsForPackageModel.dart';
import 'package:simple/ModelClass/Catering/getPackageModel.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/customTextfield.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBooking extends StatelessWidget {
  final String from;
  final bool isTablet;
  const AddBooking({super.key, required this.isTablet, required this.from});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CateringBloc(),
      child: AddBookingView(isTablet: isTablet, from: from),
    );
  }
}

class AddBookingView extends StatefulWidget {
  final String from;
  final bool isTablet;
  const AddBookingView({
    super.key,
    required this.isTablet,
    required this.from,
  });

  @override
  State<AddBookingView> createState() => _AddBookingViewState();
}

class _AddBookingViewState extends State<AddBookingView> {
  GetLocationModel getLocationModel = GetLocationModel();
  GetCustomerByLocation getCustomerByLocation = GetCustomerByLocation();
  GetPackageModel getPackageModel = GetPackageModel();
  GetItemAddonsForPackageModel getItemAddonsForPackageModel =
      GetItemAddonsForPackageModel();
  final _formKey = GlobalKey<FormState>();
  final quantity = TextEditingController();
  final discountAmount = TextEditingController();
  final packageAmount = TextEditingController();
  final addonsAmount = TextEditingController();
  final finalAmount = TextEditingController();
  final balanceAmount = TextEditingController();

  List<Map<String, dynamic>> partialPayments = [];
  String? selectedPartialPaymentMode;
  final TextEditingController partialPaidAmountController =
      TextEditingController();

  bool isActive = true;
  bool itAddLoad = false;
  bool locLoad = false;
  bool saveLoad = false;
  DateTime selectedDate = DateTime.now();
  String? selectedLocation;
  String? locationId;
  String? packageId;

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

  String? customerErrorText;
  String? packageErrorText;
  String? discountErrorText;
  String? paymentTypeErrorText;
  String? paymentModeErrorText;

  final List<String> discountType = ['Fixed', 'Percentage'];
  final List<String> paymentType = ['Fully Paid', 'Partially Paid'];
  final List<String> paymentMode = ['CASH', 'UPI', 'CARD', 'ONLINE'];
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
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

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool validateForm() {
    bool isValid = true;

    setState(() {
      // Reset all error states
      showCustomerError = false;
      showPackageError = false;
      // showProductError = false;
      customerErrorText = null;
      packageErrorText = null;
      // productErrorText = null;
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
    // else {
    //   // Validate individual product fields
    //   for (int i = 0; i < selectedProducts.length; i++) {
    //     ProductRowModel product = selectedProducts[i];
    //
    //     if (product.qty <= 0) {
    //       showValidationSnackBar(
    //           'Product "${product.name}" quantity must be greater than 0');
    //       isValid = false;
    //       break;
    //     }
    //
    //     if (product.amount <= 0) {
    //       showValidationSnackBar(
    //           'Product "${product.name}" amount must be greater than 0');
    //       isValid = false;
    //       break;
    //     }
    //   }
    // }

    // Validate final amount
    // double finalAmount = double.tryParse(finalController.text) ?? 0.0;
    // if (finalAmount <= 0) {
    //   showValidationSnackBar('Final amount must be greater than 0');
    //   isValid = false;
    // }

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

  double packagePrice = 0.0;

  void calculateTotals() {
    // Get package price and quantity
    double packagePrice = 0.0;
    int qty = int.tryParse(quantity.text) ?? 1;

    if (selectedPackage != null && getPackageModel.data != null) {
      var selectedPack = getPackageModel.data!.firstWhere(
        (pack) => pack.id == selectedPackage,
        orElse: () => getPackageModel.data!.first,
      );
      packagePrice = (selectedPack.price ?? 0).toDouble();
    }

    // Calculate package amount (price * quantity)
    double packageTotal = packagePrice * qty;
    packageAmount.text = packageTotal.toStringAsFixed(2);

    // Calculate addons amount (only paid addons) * quantity
    double addonsPricePerUnit = 0.0;
    for (var addon in selectedAddons) {
      if (addon['isFree'] != true) {
        addonsPricePerUnit += (addon['price'] ?? 0).toDouble();
      }
    }
    // Multiply addons by quantity
    double addonsTotal = addonsPricePerUnit * qty;
    addonsAmount.text = addonsTotal.toStringAsFixed(2);

    // Calculate subtotal (package + addons)
    double subtotal = packageTotal + addonsTotal;

    // Calculate discount
    double discountValue = 0.0;
    double discountAmt = double.tryParse(discountAmount.text) ?? 0.0;

    if (selectedDiscount == 'Fixed') {
      // Fixed discount
      discountValue = discountAmt;
    } else if (selectedDiscount == 'Percentage') {
      // Percentage discount
      discountValue = (subtotal * discountAmt) / 100;
    }

    // Calculate final amount
    double finalTotal = subtotal - discountValue;
    finalAmount.text = finalTotal.toStringAsFixed(2);

    // Calculate balance amount based on payment type
    if (selectedPaymentType == 'Fully Paid') {
      balanceAmount.text = "0";
    } else if (selectedPaymentType == 'Partially Paid') {
      // Calculate total paid amount from partial payments
      double totalPaid = 0.0;
      for (var payment in partialPayments) {
        totalPaid += payment['amount'] ?? 0.0;
      }
      double balance = finalTotal - totalPaid;
      balanceAmount.text = balance.toStringAsFixed(2);
    } else {
      balanceAmount.text = finalTotal.toStringAsFixed(2);
    }

    setState(() {});
  }

  void calculateTotalsWithCurrentInput() {
    double packagePrice = 0.0;
    int qty = int.tryParse(quantity.text) ?? 1;

    if (selectedPackage != null && getPackageModel.data != null) {
      var selectedPack = getPackageModel.data!.firstWhere(
        (pack) => pack.id == selectedPackage,
        orElse: () => getPackageModel.data!.first,
      );
      packagePrice = (selectedPack.price ?? 0).toDouble();
    }

    // Calculate package amount (price * quantity)
    double packageTotal = packagePrice * qty;
    packageAmount.text = packageTotal.toStringAsFixed(2);

    // Calculate addons amount (only paid addons) * quantity
    double addonsPricePerUnit = 0.0;
    for (var addon in selectedAddons) {
      if (addon['isFree'] != true) {
        addonsPricePerUnit += (addon['price'] ?? 0).toDouble();
      }
    }
    double addonsTotal = addonsPricePerUnit * qty;
    addonsAmount.text = addonsTotal.toStringAsFixed(2);

    // Calculate subtotal (package + addons)
    double subtotal = packageTotal + addonsTotal;

    // Calculate discount
    double discountValue = 0.0;
    double discountAmt = double.tryParse(discountAmount.text) ?? 0.0;

    if (selectedDiscount == 'Fixed') {
      discountValue = discountAmt;
    } else if (selectedDiscount == 'Percentage') {
      discountValue = (subtotal * discountAmt) / 100;
    }

    // Calculate final amount
    double finalTotal = subtotal - discountValue;
    finalAmount.text = finalTotal.toStringAsFixed(2);

    // Calculate balance amount including current input
    if (selectedPaymentType == 'Fully Paid') {
      balanceAmount.text = "0";
    } else if (selectedPaymentType == 'Partially Paid') {
      // Calculate total paid from already added payments
      double totalPaid = 0.0;
      for (var payment in partialPayments) {
        totalPaid += payment['amount'] ?? 0.0;
      }

      // Add the current input amount (even if not yet added to the list)
      double currentInputAmount =
          double.tryParse(partialPaidAmountController.text) ?? 0.0;
      totalPaid += currentInputAmount;

      double balance = finalTotal - totalPaid;
      balanceAmount.text = balance.toStringAsFixed(2);
    } else {
      balanceAmount.text = finalTotal.toStringAsFixed(2);
    }

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

  @override
  void initState() {
    super.initState();
    context.read<CateringBloc>().add(CateringLocation());
    setState(() {
      locLoad = true;
      debugPrint("selectedDiscount:$selectedDiscount");
    });
  }

  List<Map<String, dynamic>> items = []; // from API
  List<Map<String, dynamic>> addons = [];

  List<Map<String, dynamic>> selectedItems = [];
  List<Map<String, dynamic>> selectedAddons = [];

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

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );

    Widget mainContainer() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Add Booking",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  /// BODY
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          /// DATE
                          GestureDetector(
                            onTap: _pickDate,
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  labelStyle: TextStyle(color: appPrimaryColor),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: greyColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: appPrimaryColor, width: 2),
                                  ),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                controller: TextEditingController(
                                  text: DateFormat('dd/MM/yyyy')
                                      .format(selectedDate),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: getLocationModel.data?.locationName != null
                                ? TextFormField(
                                    enabled: false,
                                    initialValue:
                                        getLocationModel.data!.locationName!,
                                    decoration: InputDecoration(
                                      labelText: 'Location',
                                      labelStyle:
                                          TextStyle(color: appPrimaryColor),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: greyColor),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: greyColor),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
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
                                      color: showCustomerError
                                          ? redColor
                                          : greyColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: showCustomerError
                                          ? redColor
                                          : appPrimaryColor,
                                      width: 2),
                                ),
                                errorText: showCustomerError
                                    ? customerErrorText
                                    : null,
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
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
                                      color: showPackageError
                                          ? redColor
                                          : greyColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: showPackageError
                                          ? redColor
                                          : appPrimaryColor,
                                      width: 2),
                                ),
                                errorText:
                                    showPackageError ? packageErrorText : null,
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
                                  context.read<CateringBloc>().add(
                                      CateringItemAddons(packageId.toString()));
                                  calculateTotals();
                                });
                              },
                            ),
                          ),
                          if (selectedPackage != null)
                            TextFormField(
                                readOnly: false,
                                controller: quantity,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: InputDecoration(
                                  labelText: "Quantity *",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: greyColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: appPrimaryColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: appPrimaryColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: redColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onChanged: (val) {
                                  _formKey.currentState!.validate();
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
                          Padding(
                            padding: EdgeInsets.only(
                                top: selectedPackage != null ? 16 : 0,
                                bottom: 16),
                            child: GestureDetector(
                              onTap: () => _showItemMultiSelect(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Items",
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  selectedItems.isEmpty
                                      ? "Select Items"
                                      : selectedItems
                                          .map((e) => e['name'])
                                          .join(', '),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () => _showAddonMultiSelect(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Addons",
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
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
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
                                      color: showDiscountError
                                          ? redColor
                                          : greyColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: showDiscountError
                                          ? redColor
                                          : appPrimaryColor,
                                      width: 2),
                                ),
                                errorText: showDiscountError
                                    ? discountErrorText
                                    : null,
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
                                  calculateTotals();
                                });
                              },
                            ),
                          ),
                          if (selectedDiscount != null)
                            TextFormField(
                              readOnly: false,
                              controller: discountAmount,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                labelText: "Discount Amount *",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: greyColor),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: appPrimaryColor),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: appPrimaryColor),
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
                          Padding(
                            padding: EdgeInsets.only(
                                top: selectedDiscount != null ? 16 : 0,
                                bottom: 16),
                            child: DropdownButtonFormField<String>(
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
                                      color: showPaymentTypeError
                                          ? redColor
                                          : greyColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: showPaymentTypeError
                                          ? redColor
                                          : appPrimaryColor,
                                      width: 2),
                                ),
                                errorText: showPaymentTypeError
                                    ? paymentTypeErrorText
                                    : null,
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
                                        color: showPaymentModeError
                                            ? redColor
                                            : greyColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: showPaymentModeError
                                            ? redColor
                                            : appPrimaryColor,
                                        width: 2),
                                  ),
                                  errorText: showPaymentModeError
                                      ? paymentModeErrorText
                                      : null,
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
                                  border:
                                      Border.all(color: Colors.grey.shade300),
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
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                              payment['amount']
                                                  .toStringAsFixed(0),
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
                                        onPressed: () =>
                                            removePartialPayment(index),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: redColor,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                                        labelStyle:
                                            TextStyle(color: appPrimaryColor),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: greyColor),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: greyColor),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appPrimaryColor, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      onChanged: (value) {
                                        calculateTotalsWithCurrentInput();
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Paid Amount',
                                        labelStyle:
                                            TextStyle(color: appPrimaryColor),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: greyColor),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: greyColor),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appPrimaryColor, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Add Button
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: addPartialPayment,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                  border: const OutlineInputBorder(),
                                ),
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: TextFormField(
                                readOnly: true,
                                controller: finalAmount,
                                decoration: InputDecoration(
                                  labelText: "Final Amount",
                                  border: const OutlineInputBorder(),
                                ),
                              )),
                            ],
                          ),

                          const SizedBox(height: 16),
                          TextFormField(
                            readOnly: true,
                            controller: balanceAmount,
                            decoration: InputDecoration(
                              labelText: "Balance Amount",
                              border: const OutlineInputBorder(),
                            ),
                          )
                        ],
                      ), // 👇 Form widget
                    ),
                  ),

                  /// FOOTER BUTTONS
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (!validateForm()) {
                              return; // Stop if validation fails
                            }
                          },
                          label: const Text("SAVE"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appPrimaryColor,
                            foregroundColor: whiteColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.1, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: whiteColor,
      body: BlocBuilder<CateringBloc, dynamic>(
        buildWhen: (previous, current) {
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
              setState(() {
                locLoad = false;
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
              showToast("No Item/Addons for this package", context,
                  color: false);
            }
            return true;
          }
          return false;
        },
        builder: (context, state) {
          return mainContainer();
        },
      ),
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
