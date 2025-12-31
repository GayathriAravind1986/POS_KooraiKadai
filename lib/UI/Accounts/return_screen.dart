import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Accounts/credit_bloc.dart' hide FetchLocations;
import 'package:simple/Bloc/Accounts/return_bloc.dart';
import 'package:simple/ModelClass/Accounts/GetAllCreditsModel.dart';
import 'package:simple/ModelClass/Accounts/PostCreditModel.dart' hide Data;
import 'package:simple/ModelClass/Accounts/PutCreditModel.dart' hide Data;
import 'package:simple/ModelClass/Customer/GetCustomerModel.dart' hide Data;
import 'package:simple/ModelClass/StockIn/getLocationModel.dart' hide Data;
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:simple/ModelClass/Accounts/GetCustomerByCreditIdModel.dart'
    hide Data;
import 'package:simple/ModelClass/Accounts/GetBalanceModel.dart' hide Data;
import 'package:simple/ModelClass/Accounts/GetAllReturnsModel.dart' hide Data;
import 'package:simple/ModelClass/Accounts/PostReturnModel.dart' hide Data;

class ReturnView extends StatelessWidget {
  final GlobalKey<ReturnViewViewState>? returnKey;
  bool? hasRefreshedReturn;
  ReturnView({
    super.key,
    this.returnKey,
    this.hasRefreshedReturn,
  });

  @override
  Widget build(BuildContext context) {
    return ReturnViewView(
        returnKey: returnKey, hasRefreshedCredit: hasRefreshedReturn);
  }
}

class ReturnViewView extends StatefulWidget {
  final GlobalKey<ReturnViewViewState>? returnKey;
  bool? hasRefreshedCredit;
  ReturnViewView({
    super.key,
    this.returnKey,
    this.hasRefreshedCredit,
  });

  @override
  ReturnViewViewState createState() => ReturnViewViewState();
}

class ReturnViewViewState extends State<ReturnViewView> {
  GetLocationModel getLocationModel = GetLocationModel();
  GetAllCreditsModel getAllCreditsModel = GetAllCreditsModel();
  GetAllReturnsModel getAllReturnsModel = GetAllReturnsModel();
  PostCreditModel postCreditModel = PostCreditModel();
  PostReturnModel postReturnModel = PostReturnModel();
  PutCreditModel putCreditModel = PutCreditModel();
  GetCustomerModel getCustomerModel = GetCustomerModel();
  GetCustomerByCreditIdModel getCustomerByCreditIdModel =
      GetCustomerByCreditIdModel();
  GetBalanceModel getBalanceApiWithFilterModel = GetBalanceModel();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  String? locationId;
  bool saveLoad = false;
  bool returnLoad = false;
  bool customerLoad = false;
  bool balanceLoad = false;
  String? errorMessage;
  String? selectedCustomerId;
  String? selectedCustomerName;
  String? selectedCreditEntryId;
  String? selectedCreditEntryBalance;

  int currentPage = 1;
  int rowsPerPage = 10;
  num totalItems = 0;
  int totalPages = 1;

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  DateTime? selectedReturnDate;

  List<dynamic> _getCurrentPageItems() {
    if (getAllReturnsModel.data == null || getAllReturnsModel.data!.isEmpty) {
      return [];
    }

    final startIndex = (currentPage - 1) * rowsPerPage;
    var endIndex = startIndex + rowsPerPage;

    if (endIndex > getAllReturnsModel.data!.length) {
      endIndex = getAllReturnsModel.data!.length;
    }

    if (startIndex >= getAllReturnsModel.data!.length) {
      return [];
    }

    return getAllReturnsModel.data!.sublist(startIndex, endIndex);
  }

  Widget buildPaginationBar() {
    int start = ((currentPage - 1) * rowsPerPage) + 1;
    int end = currentPage * rowsPerPage;

    if (end > totalItems) {
      end = totalItems.toInt();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Rows per page: "),
        DropdownButton<int>(
          value: rowsPerPage,
          items: [5, 10, 20, 50].map((e) {
            return DropdownMenuItem(value: e, child: Text("$e"));
          }).toList(),
          onChanged: (value) {
            setState(() {
              rowsPerPage = value!;
              currentPage = 1;
            });
            _goToPage(currentPage);
          },
        ),
        const SizedBox(width: 20),
        Text("$start - $end of $totalItems"),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () {
                  _goToPage(currentPage - 1);
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () {
                  _goToPage(currentPage + 1);
                }
              : null,
        ),
      ],
    );
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        currentPage = page;
        returnLoad = true;
      });
      String fromDate = selectedFromDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
          : '';
      String toDate = selectedToDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
          : '';

      context.read<ReturnBloc>().add(FetchAllReturns(
            fromDate: fromDate,
            toDate: toDate,
            search: searchController.text,
            limit: rowsPerPage,
            offset: (page - 1) * rowsPerPage,
            locid: locationId ?? '', // Added locid parameter
          ));
    }
  }

  void refreshCredit() {
    if (!mounted || !context.mounted) return;
    context.read<ReturnBloc>().add(FetchLocations());
    setState(() {
      returnLoad = true;
    });
  }

  void clearReturnForm() {
    setState(() {
      dateController.clear();
      amountController.clear();
      descriptionController.clear();
      selectedCustomerId = null;
      selectedCustomerName = null;
      selectedCreditEntryId = null;
      selectedCreditEntryBalance = null;
      selectedReturnDate = DateTime.now();
      dateController.text =
          DateFormat('dd-MM-yyyy').format(selectedReturnDate!);
      saveLoad = false;
    });
  }

  void _fetchBalanceWithFilter() {
    if (selectedCustomerId != null && selectedCustomerId!.isNotEmpty) {
      setState(() {
        balanceLoad = true;
      });
      context.read<ReturnBloc>().add(FetchCustomerBalance(
            customerId: selectedCustomerId!,
          ));
    } else {
      setState(() {
        getBalanceApiWithFilterModel = GetBalanceModel();
        selectedCreditEntryId = null;
        selectedCreditEntryBalance = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedFromDate = DateTime.now().subtract(const Duration(days: 30));
    selectedToDate = DateTime.now();
    selectedReturnDate = DateTime.now();

    fromDateController.text =
        DateFormat('dd-MM-yyyy').format(selectedFromDate!);
    toDateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
    dateController.text = DateFormat('dd-MM-yyyy').format(selectedReturnDate!);

    if (widget.hasRefreshedCredit == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          returnLoad = true;
        });
        widget.returnKey?.currentState?.refreshCredit();
      });
    } else {
      context.read<ReturnBloc>().add(FetchLocations());
      setState(() {
        returnLoad = true;
      });
    }
  }

  void _refreshData() {
    setState(() {
      searchController.clear();
      fromDateController.clear();
      toDateController.clear();
      selectedFromDate = DateTime.now().subtract(const Duration(days: 30));
      selectedToDate = DateTime.now();
      fromDateController.text =
          DateFormat('dd-MM-yyyy').format(selectedFromDate!);
      toDateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
      currentPage = 1;
      returnLoad = true;
      clearReturnForm();
    });

    String fromDate = selectedFromDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
        : '';
    String toDate = selectedToDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
        : '';

    context.read<ReturnBloc>().add(FetchAllReturns(
          fromDate: fromDate,
          toDate: toDate,
          search: '',
          limit: rowsPerPage,
          offset: 0,
          locid: locationId ?? '', // Added locid parameter
        ));
  }

  void refreshReturn() {
    if (!mounted || !context.mounted) return;
    context.read<ReturnBloc>().add(FetchLocations());
    setState(() {
      returnLoad = true;
    });
  }

  void _fetchCustomers() {
    if (locationId != null && locationId!.isNotEmpty) {
      context.read<ReturnBloc>().add(FetchCustomersForReturn(
            locationId: locationId!,
            search: '',
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReturnBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetLocationModel) {
          getLocationModel = current;
          if (getLocationModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getLocationModel.success == true) {
            locationId = getLocationModel.data?.locationId;
            String fromDate = selectedFromDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
                : '';
            String toDate = selectedToDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
                : '';

            context.read<ReturnBloc>().add(FetchAllReturns(
                  fromDate: fromDate,
                  toDate: toDate,
                  search: searchController.text,
                  limit: rowsPerPage,
                  offset: 0,
                  locid: locationId ?? '', // Added locid parameter
                ));
            _fetchCustomers();
            setState(() {
              returnLoad = true;
            });
          } else {
            setState(() {
              returnLoad = false;
            });
            showToast("No Location found", context, color: false);
          }
          return true;
        }

        if (current is GetAllReturnsModel) {
          getAllReturnsModel = current;

          if (getAllReturnsModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }

          if (getAllReturnsModel.success == true) {
            totalItems = getAllReturnsModel.total?.toInt() ?? 0;
            totalPages = totalItems > 0 ? (totalItems / rowsPerPage).ceil() : 1;

            setState(() {
              returnLoad = false;
            });
          } else {
            setState(() {
              returnLoad = false;
            });
            String errorMsg =
                getAllReturnsModel.errorResponse?.message ?? "No Returns found";
            showToast(errorMsg, context, color: false);
          }
          return true;
        }

        if (current is GetCustomerModel) {
          getCustomerModel = current;
          if (getCustomerModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getCustomerModel.success == true) {
            setState(() {
              customerLoad = false;
            });
          } else {
            setState(() {
              customerLoad = false;
            });
          }
          return true;
        }

        if (current is GetBalanceModel) {
          getBalanceApiWithFilterModel = current;

          if (getBalanceApiWithFilterModel.errorResponse?.isUnauthorized ==
              true) {
            _handle401Error();
            return true;
          }

          setState(() {
            balanceLoad = false;
          });

          if (!getBalanceApiWithFilterModel.success!) {
            showToast(
                getBalanceApiWithFilterModel.errorResponse?.message ??
                    "Failed to fetch credit entries",
                context,
                color: false);
          }

          return true;
        }

        if (current is Map<String, dynamic>) {
          if (current['type'] == 'return_success') {
            postReturnModel = current['data'];

            showToast(
                current['message'] ?? "Return added successfully!", context,
                color: true);

            setState(() {
              currentPage = 1;
              saveLoad = false;
            });

            String fromDate = selectedFromDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
                : '';
            String toDate = selectedToDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
                : '';

            context.read<ReturnBloc>().add(FetchAllReturns(
                  fromDate: fromDate,
                  toDate: toDate,
                  search: searchController.text,
                  limit: rowsPerPage,
                  offset: 0,
                  locid: locationId ?? '', // Added locid parameter
                ));

            Future.delayed(Duration(milliseconds: 100), () {
              clearReturnForm();
            });

            return true;
          }

          if (current['type'] == 'return_error' ||
              current['type'] == 'return_exception') {
            setState(() {
              saveLoad = false;
            });

            showToast(current['message'] ?? "Failed to add return", context,
                color: false);

            return true;
          }
        }

        return false;
      }),
      builder: (context, dynamic) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Return Management",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Add Return Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add Return",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Row 1: Date and Location
                        Row(
                          children: [
                            // Date Field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: selectedReturnDate ??
                                            DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null &&
                                          picked != selectedReturnDate) {
                                        setState(() {
                                          selectedReturnDate = picked;
                                          dateController.text =
                                              DateFormat('dd-MM-yyyy')
                                                  .format(picked);
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 20, color: appPrimaryColor),
                                          const SizedBox(width: 10),
                                          Text(
                                            dateController.text,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Location Field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Location",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  getLocationModel.data?.locationName != null
                                      ? Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 20,
                                                  color: appPrimaryColor),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  getLocationModel
                                                      .data!.locationName!,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: const Text(
                                            "No location selected",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Row 2: Customer and Credit Entry
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Customer",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedCustomerId,
                                        hint: const Text("Select Customer",
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        isExpanded: true,
                                        items: getCustomerModel.data
                                                ?.map((customer) {
                                              return DropdownMenuItem<String>(
                                                value: customer.id,
                                                child: Text(
                                                  customer.name ?? "",
                                                  style: const TextStyle(
                                                      color: Colors.black87),
                                                ),
                                              );
                                            }).toList() ??
                                            [],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedCustomerId = value;
                                            selectedCustomerName =
                                                getCustomerModel.data
                                                    ?.firstWhere(
                                                        (c) => c.id == value)
                                                    ?.name;
                                            selectedCreditEntryId = null;
                                            selectedCreditEntryBalance = null;
                                          });
                                          _fetchBalanceWithFilter();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Credit Entry Field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Credit Entry",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedCreditEntryId,
                                        hint: const Text(
                                            "Select a credit entry to see balance",
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        isExpanded: true,
                                        items: getBalanceApiWithFilterModel.data
                                                ?.map((entry) {
                                              return DropdownMenuItem<String>(
                                                value: entry.creditId,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "${entry.creditCode ?? 'N/A'}",
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                    Text(
                                                      "Balance: ${entry.balanceAmount?.toStringAsFixed(2) ?? '0.00'}",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList() ??
                                            [],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedCreditEntryId = value;
                                            final selectedEntry =
                                                getBalanceApiWithFilterModel
                                                    .data
                                                    ?.firstWhere((e) =>
                                                        e.creditId == value);
                                            selectedCreditEntryBalance =
                                                selectedEntry?.balanceAmount
                                                    ?.toStringAsFixed(2);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (selectedCreditEntryBalance != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "Balance: $selectedCreditEntryBalance",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Row 3: Amount and Description
                        Row(
                          children: [
                            // Amount Field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Amount *",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Enter amount",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: appPrimaryColor),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Description",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                      hintText: "Enter description",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: appPrimaryColor),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Save Button
                        Center(
                          child: saveLoad
                              ? SpinKitCircle(color: appPrimaryColor, size: 30)
                              : ElevatedButton(
                                  onPressed: () {
                                    if (selectedCustomerId == null ||
                                        selectedCustomerId!.isEmpty) {
                                      showToast(
                                          "Please select a customer", context,
                                          color: false);
                                    } else if (selectedCreditEntryId == null ||
                                        selectedCreditEntryId!.isEmpty) {
                                      showToast("Please select a credit entry",
                                          context,
                                          color: false);
                                    } else if (amountController.text.isEmpty) {
                                      showToast("Please enter amount", context,
                                          color: false);
                                    } else if (getLocationModel
                                            .data?.locationName ==
                                        null) {
                                      showToast("Location not found", context,
                                          color: false);
                                    } else if (selectedCustomerName == null ||
                                        selectedCustomerName!.isEmpty) {
                                      showToast(
                                          "Customer name not found", context,
                                          color: false);
                                    } else {
                                      setState(() {
                                        saveLoad = true;
                                      });

                                      String returnDate =
                                          selectedReturnDate != null
                                              ? DateFormat('yyyy-MM-dd')
                                                  .format(selectedReturnDate!)
                                              : DateFormat('yyyy-MM-dd')
                                                  .format(DateTime.now());

                                      context
                                          .read<ReturnBloc>()
                                          .add(CreateReturn(
                                            date: returnDate,
                                            locationId: locationId ?? "",
                                            customerId: selectedCustomerId!,
                                            creditId: selectedCreditEntryId!,
                                            price: double.parse(
                                                amountController.text),
                                            description:
                                                descriptionController.text,
                                          ));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appPrimaryColor,
                                    minimumSize: const Size(0, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: const Text(
                                    "SAVE RETURN",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Return List Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Return List",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Filters Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Filters",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Search Field
                            TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.grey),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: appPrimaryColor),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  currentPage = 1;
                                  returnLoad = true;
                                });
                                String fromDate = selectedFromDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(selectedFromDate!)
                                    : '';
                                String toDate = selectedToDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(selectedToDate!)
                                    : '';

                                context.read<ReturnBloc>().add(FetchAllReturns(
                                      fromDate: fromDate,
                                      toDate: toDate,
                                      search: value,
                                      limit: rowsPerPage,
                                      offset: 0,
                                      locid: locationId ??
                                          '', // Added locid parameter
                                    ));
                              },
                            ),

                            const SizedBox(height: 15),

                            // Date Range Filters
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "From Date",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () async {
                                          final DateTime? picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: selectedFromDate ??
                                                DateTime.now().subtract(
                                                    const Duration(days: 30)),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null &&
                                              picked != selectedFromDate) {
                                            setState(() {
                                              selectedFromDate = picked;
                                              fromDateController.text =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(picked);
                                              returnLoad = true;
                                            });
                                            _goToPage(1);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 20,
                                                  color: appPrimaryColor),
                                              const SizedBox(width: 10),
                                              Text(
                                                fromDateController.text,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "To Date",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () async {
                                          final DateTime? picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: selectedToDate ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null &&
                                              picked != selectedToDate) {
                                            setState(() {
                                              selectedToDate = picked;
                                              toDateController.text =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(picked);
                                              returnLoad = true;
                                            });
                                            _goToPage(1);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 20,
                                                  color: appPrimaryColor),
                                              const SizedBox(width: 10),
                                              Text(
                                                toDateController.text,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Clear Filters Button
                            Center(
                              child: ElevatedButton(
                                onPressed: _refreshData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: const Size(0, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  "CLEAR FILTERS",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Returns Table
                      returnLoad
                          ? Container(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.1,
                              ),
                              alignment: Alignment.center,
                              child: const SpinKitChasingDots(
                                color: appPrimaryColor,
                                size: 30,
                              ),
                            )
                          : getAllReturnsModel.data == null ||
                                  getAllReturnsModel.data!.isEmpty
                              ? Container(
                                  padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "No Returns Found !!!",
                                    style: MyTextStyle.f16(
                                      Colors.grey,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                40,
                                          ),
                                          child: DataTable(
                                            dataRowHeight: 50,
                                            headingRowHeight: 50,
                                            horizontalMargin: 20,
                                            columnSpacing: 32,
                                            headingRowColor:
                                                MaterialStateProperty.all(
                                                    Colors.grey.shade100),
                                            columns: const [
                                              DataColumn(
                                                label: Text(
                                                  'Date',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Location',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Code',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Customer',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Amount',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                            rows: _getCurrentPageItems()
                                                .map((returnItem) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.15,
                                                      ),
                                                      child: Text(
                                                        returnItem.date != null
                                                            ? DateFormat(
                                                                    'dd/MM/yyyy')
                                                                .format(DateTime
                                                                    .parse(returnItem
                                                                        .date!))
                                                            : 'N/A',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.15,
                                                      ),
                                                      child: Text(
                                                        returnItem.location
                                                                ?.name ??
                                                            'N/A',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.15,
                                                      ),
                                                      child: Text(
                                                        returnItem.returnCode ??
                                                            'N/A',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                      ),
                                                      child: Text(
                                                        returnItem.customer
                                                                ?.name ??
                                                            'N/A',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                      ),
                                                      child: Text(
                                                        '${returnItem.price?.toStringAsFixed(2) ?? '0.00'}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                        child: buildPaginationBar(),
                                      ),
                                    ],
                                  ),
                                ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
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
