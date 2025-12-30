import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Accounts/credit_bloc.dart';
import 'package:simple/ModelClass/Accounts/GetAllCreditsModel.dart';
import 'package:simple/ModelClass/Accounts/PostCreditModel.dart' hide Data;
import 'package:simple/ModelClass/Accounts/PutCreditModel.dart' hide Data;
import 'package:simple/ModelClass/Customer/GetCustomerModel.dart' hide Data;
import 'package:simple/ModelClass/StockIn/getLocationModel.dart' hide Data;
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:simple/ModelClass/Accounts/GetCustomerByCreditIdModel.dart' hide Data;

class CreditView extends StatelessWidget {
  final GlobalKey<CreditViewViewState>? creditKey;
  bool? hasRefreshedCredit;
  CreditView({
    super.key,
    this.creditKey,
    this.hasRefreshedCredit,
  });

  @override
  Widget build(BuildContext context) {
    return CreditViewView(
        creditKey: creditKey, hasRefreshedCredit: hasRefreshedCredit);
  }
}

class CreditViewView extends StatefulWidget {
  final GlobalKey<CreditViewViewState>? creditKey;
  bool? hasRefreshedCredit;
  CreditViewView({
    super.key,
    this.creditKey,
    this.hasRefreshedCredit,
  });

  @override
  CreditViewViewState createState() => CreditViewViewState();
}

class CreditViewViewState extends State<CreditViewView> {
  GetLocationModel getLocationModel = GetLocationModel();
  GetAllCreditsModel getAllCreditsModel = GetAllCreditsModel();
  PostCreditModel postCreditModel = PostCreditModel();
  PutCreditModel putCreditModel = PutCreditModel();
  GetCustomerModel getCustomerModel = GetCustomerModel();
  GetCustomerByCreditIdModel getCustomerByCreditIdModel = GetCustomerByCreditIdModel();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  String? locationId;
  bool saveLoad = false;
  bool editLoad = false;
  bool creditLoad = false;
  bool customerLoad = false;
  bool isEdit = false;
  String? errorMessage;
  String? creditId;
  String? selectedCustomerId;
  String? selectedCustomerName;

  int currentPage = 1;
  int rowsPerPage = 10;
  num totalItems = 0;
  int totalPages = 1;

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  DateTime? selectedCreditDate;

  List<Data> _getCurrentPageItems() {
    if (getAllCreditsModel.data == null || getAllCreditsModel.data!.isEmpty) {
      return [];
    }

    final startIndex = (currentPage - 1) * rowsPerPage;
    var endIndex = startIndex + rowsPerPage;

    if (endIndex > getAllCreditsModel.data!.length) {
      endIndex = getAllCreditsModel.data!.length;
    }

    if (startIndex >= getAllCreditsModel.data!.length) {
      return [];
    }

    return getAllCreditsModel.data!.sublist(startIndex, endIndex);
  }

  Widget buildPaginationBar() {
    int start = ((currentPage - 1) * rowsPerPage) + 1;
    int end = currentPage * rowsPerPage;

    if (end > totalItems) {
      end = totalItems.toInt();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
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
        creditLoad = true;
      });
      String fromDate = selectedFromDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
          : '';
      String toDate = selectedToDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
          : '';

      context.read<CreditBloc>().add(FetchAllCredits(
        fromDate: fromDate,
        toDate: toDate,
        search: searchController.text,
        limit: rowsPerPage,
        offset: (page - 1) * rowsPerPage,
      ));
    }
  }

  void refreshCredit() {
    if (!mounted || !context.mounted) return;
    context.read<CreditBloc>().add(FetchLocations());
    setState(() {
      creditLoad = true;
    });
  }

  void clearCreditForm() {
    setState(() {
      dateController.clear();
      amountController.clear();
      descriptionController.clear();
      selectedCustomerId = null;
      selectedCustomerName = null;
      selectedCreditDate = DateTime.now();
      dateController.text = DateFormat('dd-MM-yyyy').format(selectedCreditDate!);
      isEdit = false;
      creditId = null;
      editLoad = false;
      saveLoad = false;
    });
  }

  void _onEditCredit(String creditId) {
    setState(() {
      isEdit = true;
      this.creditId = creditId;
      editLoad = true;
    });

    context.read<CreditBloc>().add(FetchCreditById(creditId: creditId));
  }

  void _updateCredit() {
    if (selectedCustomerId == null || selectedCustomerId!.isEmpty) {
      showToast("Please select a customer", context, color: false);
      return;
    }

    if (amountController.text.isEmpty) {
      showToast("Please enter amount", context, color: false);
      return;
    }

    if (getLocationModel.data?.locationName == null) {
      showToast("Location not found", context, color: false);
      return;
    }

    if (selectedCustomerName == null || selectedCustomerName!.isEmpty) {
      showToast("Customer name not found", context, color: false);
      return;
    }

    if (creditId == null || creditId!.isEmpty) {
      showToast("Credit ID not found", context, color: false);
      return;
    }

    setState(() {
      editLoad = true;
    });

    String creditDate = selectedCreditDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedCreditDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      double.parse(amountController.text);
    } catch (e) {
      showToast("Please enter a valid amount", context, color: false);
      setState(() {
        editLoad = false;
      });
      return;
    }

    context.read<CreditBloc>().add(UpdateCredit(
      creditId: creditId!,
      date: creditDate,
      locationId: locationId ?? "",
      customerId: selectedCustomerId!,
      customerName: selectedCustomerName!,
      price: double.parse(amountController.text),
      description: descriptionController.text,
    ));
  }

  @override
  void initState() {
    super.initState();
    selectedFromDate = DateTime.now().subtract(const Duration(days: 30));
    selectedToDate = DateTime.now();
    selectedCreditDate = DateTime.now();

    fromDateController.text = DateFormat('dd-MM-yyyy').format(selectedFromDate!);
    toDateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
    dateController.text = DateFormat('dd-MM-yyyy').format(selectedCreditDate!);

    if (widget.hasRefreshedCredit == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          creditLoad = true;
        });
        widget.creditKey?.currentState?.refreshCredit();
      });
    } else {
      context.read<CreditBloc>().add(FetchLocations());
      setState(() {
        creditLoad = true;
      });
    }
  }

  void _refreshData() {
    setState(() {
      searchController.clear();
      currentPage = 1;
      creditLoad = true;
      clearCreditForm();
    });
    context.read<CreditBloc>().add(FetchLocations());
    widget.creditKey?.currentState?.refreshCredit();
  }

  void _refreshEditData() {
    clearCreditForm();
    context.read<CreditBloc>().add(FetchLocations());
    widget.creditKey?.currentState?.refreshCredit();
  }

  void _fetchCustomers() {
    if (locationId != null && locationId!.isNotEmpty) {
      context.read<CreditBloc>().add(FetchCustomersForCredit(
        locationId: locationId!,
        search: '',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContainer() {
      return Container(
        color: Colors.grey.shade50, // Light grey background for the page
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add/Edit Credit Section Card
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isEdit ? "Edit Credit" : "Add Credit",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (isEdit)
                            IconButton(
                              onPressed: () {
                                _refreshEditData();
                              },
                              icon: const Icon(
                                Icons.refresh,
                                color: appPrimaryColor,
                                size: 28,
                              ),
                              tooltip: 'Refresh Form',
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Row 1: Date and Location in one row
                      Row(
                        children: [
                          // Date Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Date*",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedCreditDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null && picked != selectedCreditDate) {
                                      setState(() {
                                        selectedCreditDate = picked;
                                        dateController.text = DateFormat('dd-MM-yyyy').format(picked);
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 20, color: appPrimaryColor),
                                        const SizedBox(width: 10),
                                        Text(
                                          dateController.text,
                                          style: const TextStyle(fontSize: 16),
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
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 20, color: appPrimaryColor),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          getLocationModel.data!.locationName!,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: const Text(
                                    "No location selected",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Customer*",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCustomerId,
                                      hint: const Text("Select Customer", style: TextStyle(color: Colors.grey)),
                                      isExpanded: true,
                                      items: getCustomerModel.data?.map((customer) {
                                        return DropdownMenuItem<String>(
                                          value: customer.id,
                                          child: Text(
                                            customer.name ?? "",
                                            style: const TextStyle(color: Colors.black87),
                                          ),
                                        );
                                      }).toList() ?? [],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCustomerId = value;
                                          selectedCustomerName = getCustomerModel.data
                                              ?.firstWhere((c) => c.id == value)
                                              ?.name;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Amount Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Amount*",
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
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: appPrimaryColor),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
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

                      const SizedBox(height: 20),

                      // Description
                      Column(
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
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: appPrimaryColor),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Save/Update Button
                      Center(
                        child: isEdit
                            ? editLoad
                            ? SpinKitCircle(color: appPrimaryColor, size: 30)
                            : ElevatedButton(
                          onPressed: _updateCredit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appPrimaryColor,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            "UPDATE CREDIT",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                            : saveLoad
                            ? SpinKitCircle(color: appPrimaryColor, size: 30)
                            : ElevatedButton(
                          onPressed: () {
                            if (selectedCustomerId == null || selectedCustomerId!.isEmpty) {
                              showToast("Please select a customer", context, color: false);
                            } else if (amountController.text.isEmpty) {
                              showToast("Please enter amount", context, color: false);
                            } else if (getLocationModel.data?.locationName == null) {
                              showToast("Location not found", context, color: false);
                            } else if (selectedCustomerName == null || selectedCustomerName!.isEmpty) {
                              showToast("Customer name not found", context, color: false);
                            } else {
                              setState(() {
                                saveLoad = true;
                              });

                              String creditDate = selectedCreditDate != null
                                  ? DateFormat('yyyy-MM-dd').format(selectedCreditDate!)
                                  : DateFormat('yyyy-MM-dd').format(DateTime.now());

                              context.read<CreditBloc>().add(CreateCredit(
                                date: creditDate,
                                locationId: locationId ?? "",
                                customerId: selectedCustomerId!,
                                customerName: selectedCustomerName!,
                                price: double.parse(amountController.text),
                                description: descriptionController.text,
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
                            "SAVE CREDIT",
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
              ),

              // Credit Management Section Card
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Credit Management",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Filters Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
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

                            // Search
                            TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search by customer name...',
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: appPrimaryColor),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  currentPage = 1;
                                  creditLoad = true;
                                });
                                String fromDate = selectedFromDate != null
                                    ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
                                    : '';
                                String toDate = selectedToDate != null
                                    ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
                                    : '';

                                context.read<CreditBloc>().add(FetchAllCredits(
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  search: value,
                                  limit: rowsPerPage,
                                  offset: 0,
                                ));
                              },
                            ),

                            const SizedBox(height: 15),

                            // Date Range Filters
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          final DateTime? picked = await showDatePicker(
                                            context: context,
                                            initialDate: selectedFromDate ?? DateTime.now().subtract(const Duration(days: 30)),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null && picked != selectedFromDate) {
                                            setState(() {
                                              selectedFromDate = picked;
                                              fromDateController.text = DateFormat('dd-MM-yyyy').format(picked);
                                              creditLoad = true;
                                            });
                                            _goToPage(1);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 20, color: appPrimaryColor),
                                              const SizedBox(width: 10),
                                              Text(
                                                fromDateController.text,
                                                style: const TextStyle(fontSize: 16),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          final DateTime? picked = await showDatePicker(
                                            context: context,
                                            initialDate: selectedToDate ?? DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null && picked != selectedToDate) {
                                            setState(() {
                                              selectedToDate = picked;
                                              toDateController.text = DateFormat('dd-MM-yyyy').format(picked);
                                              creditLoad = true;
                                            });
                                            _goToPage(1);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 20, color: appPrimaryColor),
                                              const SizedBox(width: 10),
                                              Text(
                                                toDateController.text,
                                                style: const TextStyle(fontSize: 16),
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
                                    side: BorderSide(color: Colors.grey.shade300),
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

                      // Credits Table
                      creditLoad
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
                          : getAllCreditsModel.data == null || getAllCreditsModel.data!.isEmpty
                          ? Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "No Credits Found !!!",
                          style: MyTextStyle.f16(
                            Colors.grey,
                            weight: FontWeight.w500,
                          ),
                        ),
                      )
                          : LayoutBuilder(
                        builder: (context, constraints) {
                          final currentPageItems = _getCurrentPageItems();

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    DataTable(
                                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                                      columnSpacing: 32,
                                      dataRowMinHeight: 48,
                                      dataRowMaxHeight: 60,
                                      headingTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('Date')),
                                        DataColumn(label: Text('Location')),
                                        DataColumn(label: Text('Code')),
                                        DataColumn(label: Text('Customer')),
                                        DataColumn(label: Text('Amount')),
                                        DataColumn(label: Text('Action')),
                                      ],
                                      rows: currentPageItems.map((credit) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                              credit.date != null
                                                  ? DateFormat('dd/MM/yyyy').format(
                                                  DateTime.parse(credit.date!))
                                                  : 'N/A',
                                            )),
                                            DataCell(Text(credit.location?.name ?? 'N/A')),
                                            DataCell(Text(credit.creditCode ?? 'N/A')),
                                            DataCell(Text(credit.customer?.name ?? 'N/A')),
                                            DataCell(Text(
                                              '${credit.price?.toStringAsFixed(2) ?? '0.00'}',
                                            )),
                                            DataCell(
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      _onEditCredit(credit.id!);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: appPrimaryColor.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: const Icon(
                                                        Icons.edit,
                                                        color: appPrimaryColor,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: buildPaginationBar(),
                                    ),
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
              ),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<CreditBloc, dynamic>(
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

            context.read<CreditBloc>().add(FetchAllCredits(
              fromDate: fromDate,
              toDate: toDate,
              search: searchController.text,
              limit: rowsPerPage,
              offset: 0,
            ));
            _fetchCustomers();
            setState(() {
              creditLoad = true;
            });
          } else {
            setState(() {
              creditLoad = false;
            });
            showToast("No Location found", context, color: false);
          }
          return true;
        }

        if (current is GetAllCreditsModel) {
          getAllCreditsModel = current;

          if (getAllCreditsModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }

          if (getAllCreditsModel.success == true) {
            totalItems = getAllCreditsModel.total?.toInt() ?? 0;
            totalPages = totalItems > 0 ? (totalItems / rowsPerPage).ceil() : 1;

            setState(() {
              creditLoad = false;
            });
          } else {
            setState(() {
              creditLoad = false;
            });
            String errorMsg = getAllCreditsModel.errorResponse?.message ??
                "No Credits found";
            showToast(errorMsg, context, color: false);
          }
          return true;
        }

        if (current is PostCreditModel) {
          postCreditModel = current;
          if (postCreditModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (postCreditModel.success == true) {
            showToast("Credit Added Successfully", context, color: true);
            setState(() {
              currentPage = 1;
            });
            String fromDate = selectedFromDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
                : '';
            String toDate = selectedToDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
                : '';

            context.read<CreditBloc>().add(FetchAllCredits(
              fromDate: fromDate,
              toDate: toDate,
              search: searchController.text,
              limit: rowsPerPage,
              offset: 0,
            ));
            Future.delayed(Duration(milliseconds: 100), () {
              clearCreditForm();
            });
            setState(() {
              saveLoad = false;
            });
          } else {
            setState(() {
              saveLoad = false;
            });
            showToast(postCreditModel.errorResponse?.message ?? "Failed to add credit", context, color: false);
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

        if (current is GetCustomerByCreditIdModel) {
          getCustomerByCreditIdModel = current;

          if (getCustomerByCreditIdModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }

          if (getCustomerByCreditIdModel.success == true) {
            if (getCustomerByCreditIdModel.data != null) {
              final creditData = getCustomerByCreditIdModel.data!;

              setState(() {
                if (creditData.date != null) {
                  try {
                    selectedCreditDate = DateTime.parse(creditData.date!);
                    dateController.text = DateFormat('dd-MM-yyyy').format(selectedCreditDate!);
                  } catch (e) {
                    dateController.text = '';
                  }
                }

                selectedCustomerId = creditData.customerId?.id;
                selectedCustomerName = creditData.customerId?.name;

                amountController.text = creditData.price?.toString() ?? '';

                descriptionController.text = creditData.description ?? '';

                if (creditData.locationId != null && getLocationModel.data == null) {
                  locationId = creditData.locationId!.id;
                }
              });
            }

            setState(() {
              editLoad = false;
            });
          } else {
            setState(() {
              editLoad = false;
            });
            showToast(getCustomerByCreditIdModel.errorResponse?.message ?? "Failed to fetch credit details", context, color: false);
          }
          return true;
        }

        if (current is Map<String, dynamic>) {
          if (current['type'] == 'update_success') {
            putCreditModel = current['data'];

            showToast(current['message'] ?? "Credit updated successfully!", context, color: true);

            setState(() {
              currentPage = 1;
              editLoad = false;
            });

            String fromDate = selectedFromDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
                : '';
            String toDate = selectedToDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
                : '';

            context.read<CreditBloc>().add(FetchAllCredits(
              fromDate: fromDate,
              toDate: toDate,
              search: searchController.text,
              limit: rowsPerPage,
              offset: 0,
            ));

            Future.delayed(Duration(milliseconds: 100), () {
              clearCreditForm();
            });

            return true;
          }

          if (current['type'] == 'update_error' || current['type'] == 'update_exception') {
            setState(() {
              editLoad = false;
            });

            showToast(current['message'] ?? "Failed to update credit", context, color: false);

            return true;
          }
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