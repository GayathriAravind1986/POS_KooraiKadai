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
import 'package:simple/ModelClass/Customer/GetCustomerModel.dart' hide Data;
import 'package:simple/ModelClass/StockIn/getLocationModel.dart' hide Data;
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';

import '../../Bloc/Customer/customer_bloc.dart' hide FetchLocations;

// Add import for the new model
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
  GetCustomerModel getCustomerModel = GetCustomerModel();
  GetCustomerByCreditIdModel getCustomerByCreditIdModel = GetCustomerByCreditIdModel(); // Add this

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

  // Pagination variables
  int currentPage = 1;
  int rowsPerPage = 10;
  num totalItems = 0;
  int totalPages = 1;

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  DateTime? selectedCreditDate;

  // Function to get current page items
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

  // Catering-style UI for pagination bar
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

  // Page navigation function
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
    });
  }

  // Function to handle edit icon click
  void _onEditCredit(String creditId) {
    setState(() {
      isEdit = true;
      this.creditId = creditId;
      editLoad = true;
    });

    // Fetch credit details for editing
    context.read<CreditBloc>().add(FetchCreditById(creditId: creditId));
  }

  @override
  void initState() {
    super.initState();
    // Set default dates
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
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add/Edit Credit Section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isEdit ? "Edit Credit" : "Add Credit",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

                      const SizedBox(height: 20),

                      // Row 1: Date and Location in one row
                      Row(
                        children: [
                          // Date Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date*",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
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
                                      border: Border.all(color: greyColor),
                                      borderRadius: BorderRadius.circular(4),
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

                          const SizedBox(width: 15),

                          // Location Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Location",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
                                getLocationModel.data?.locationName != null
                                    ? Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: greyColor),
                                    borderRadius: BorderRadius.circular(4),
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
                                    border: Border.all(color: greyColor),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text("No location selected"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Customer*",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: greyColor),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCustomerId,
                                      hint: const Text("Select Customer"),
                                      isExpanded: true,
                                      items: getCustomerModel.data?.map((customer) {
                                        return DropdownMenuItem<String>(
                                          value: customer.id,
                                          child: Text(customer.name ?? ""),
                                        );
                                      }).toList() ?? [],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCustomerId = value;
                                          // Find and store the customer name
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

                          const SizedBox(width: 15),

                          // Amount Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Amount*",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: amountController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: "Enter amount",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Row 3: Description
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Description",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              hintText: "Enter description",
                              border: OutlineInputBorder(),
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
                          onPressed: () {
                            // TODO: Implement update functionality
                            showToast("Update functionality to be implemented", context, color: false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appPrimaryColor,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "UPDATE CREDIT",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                          ),
                          child: const Text(
                            "SAVE CREDIT",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Credit Management Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Credit Management",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              // Filters Section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 15),

                      // Search
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by customer name...',
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(),
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
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
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
                                      border: Border.all(color: greyColor),
                                      borderRadius: BorderRadius.circular(4),
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

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To Date",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
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
                                      border: Border.all(color: greyColor),
                                      borderRadius: BorderRadius.circular(4),
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
                            backgroundColor: appPrimaryColor,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "CLEAR FILTERS",
                            style: TextStyle(color: whiteColor),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  top: MediaQuery.of(context).size.height * 0.1,
                ),
                alignment: Alignment.center,
                child: Text(
                  "No Credits Found !!!",
                  style: MyTextStyle.f16(
                    greyColor,
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
                      child: Card(
                        elevation: 2,
                        child: Column(
                          children: [
                            DataTable(
                              headingRowColor: MaterialStateProperty.all(greyColor200),
                              columnSpacing: 32,
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
                                            child: const Icon(
                                              Icons.edit,
                                              color: appPrimaryColor,
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
            // Fetch credits after getting location
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
            // Fetch customers for dropdown
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
            // Refresh credits after adding
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

        // Add handler for GetCustomerByCreditIdModel
        if (current is GetCustomerByCreditIdModel) {
          getCustomerByCreditIdModel = current;

          if (getCustomerByCreditIdModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }

          if (getCustomerByCreditIdModel.success == true) {
            // Populate form fields with the fetched credit data
            if (getCustomerByCreditIdModel.data != null) {
              final creditData = getCustomerByCreditIdModel.data!;

              setState(() {
                // Set date
                if (creditData.date != null) {
                  try {
                    selectedCreditDate = DateTime.parse(creditData.date!);
                    dateController.text = DateFormat('dd-MM-yyyy').format(selectedCreditDate!);
                  } catch (e) {
                    dateController.text = '';
                  }
                }

                // Set customer
                selectedCustomerId = creditData.customerId?.id;
                selectedCustomerName = creditData.customerId?.name;

                // Set amount
                amountController.text = creditData.price?.toString() ?? '';

                // Set description
                descriptionController.text = creditData.description ?? '';

                // Update location display if needed
                if (creditData.locationId != null && getLocationModel.data == null) {
                  // getLocationModel.data = GetLocationModelData(
                  //   locationId: creditData.locationId!.id,
                  //   locationName: creditData.locationId!.name,
                  // );
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