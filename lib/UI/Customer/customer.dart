import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Customer/customer_bloc.dart';
import 'package:simple/ModelClass/Customer/GetCustomerByIdModel.dart';
import 'package:simple/ModelClass/Customer/GetCustomerModel.dart';
import 'package:simple/ModelClass/Customer/PostCustomerModel.dart';
import 'package:simple/ModelClass/Customer/PutCustomerByIdModel.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';

// Import the Customer model if it exists
// import 'package:simple/ModelClass/Customer/CustomerModel.dart'; // Uncomment if you have this

class CustomerView extends StatelessWidget {
  final GlobalKey<CustomerViewViewState>? customerKey;
  bool? hasRefreshedCustomer;
  CustomerView({
    super.key,
    this.customerKey,
    this.hasRefreshedCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerViewView(
        customerKey: customerKey, hasRefreshedCustomer: hasRefreshedCustomer);
  }
}

class CustomerViewView extends StatefulWidget {
  final GlobalKey<CustomerViewViewState>? customerKey;
  bool? hasRefreshedCustomer;
  CustomerViewView({
    super.key,
    this.customerKey,
    this.hasRefreshedCustomer,
  });

  @override
  CustomerViewViewState createState() => CustomerViewViewState();
}

class CustomerViewViewState extends State<CustomerViewView> {
  GetLocationModel getLocationModel = GetLocationModel();
  GetCustomerModel getCustomerModel = GetCustomerModel();
  PostCustomerModel postCustomerModel = PostCustomerModel();
  GetCustomerByIdModel getCustomerByIdModel = GetCustomerByIdModel();
  PutCustomerByIdModel putCustomerByIdModel = PutCustomerByIdModel();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  String? locationId;
  bool saveLoad = false;
  bool editLoad = false;
  bool customerLoad = false;
  bool customerShowLoad = false;
  bool isEdit = false;
  String? errorMessage;
  String? customerId;

  int currentPage = 1;
  int rowsPerPage = 10;
  num totalItems = 0;
  int totalPages = 1;

  // Define a local type for customer items if CustomerItem doesn't exist
  List<dynamic> _getCurrentPageItems() {
    if (getCustomerModel.data == null || getCustomerModel.data!.isEmpty) {
      return [];
    }

    final startIndex = (currentPage - 1) * rowsPerPage;
    var endIndex = startIndex + rowsPerPage;

    if (endIndex > getCustomerModel.data!.length) {
      endIndex = getCustomerModel.data!.length;
    }

    if (startIndex >= getCustomerModel.data!.length) {
      return [];
    }

    return getCustomerModel.data!.sublist(startIndex, endIndex);
  }

  void refreshCustomer() {
    if (!mounted || !context.mounted) return;
    context.read<CustomerBloc>().add(FetchLocations());
    context.read<CustomerBloc>().add(FetchAllCustomers(
        searchController.text,
        locationId ?? "",
        rowsPerPage,
        (currentPage - 1) * rowsPerPage));
    setState(() {
      customerLoad = true;
    });
  }

  void clearCustomerForm() {
    setState(() {
      nameController.clear();
      phoneController.clear();
      emailController.clear();
      addressController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint("🔵 CustomerView initState");
    debugPrint("🔵 hasRefreshedCustomer: ${widget.hasRefreshedCustomer}");

    if (widget.hasRefreshedCustomer == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint("🔵 Post frame callback - refreshing");
        setState(() {
          customerLoad = true;
        });
        widget.customerKey?.currentState?.refreshCustomer();
      });
    } else {
      debugPrint("🔵 Fetching locations and customers");
      context.read<CustomerBloc>().add(FetchLocations());
      context.read<CustomerBloc>().add(FetchAllCustomers(
          searchController.text,
          locationId ?? "",
          rowsPerPage,
          0));
      setState(() {
        customerLoad = true;
      });
    }
  }

  void _refreshData() {
    setState(() {
      currentPage = 1;
      customerLoad = true;
    });
    context.read<CustomerBloc>().add(FetchLocations());
    context.read<CustomerBloc>().add(FetchAllCustomers(
        searchController.text,
        locationId ?? "",
        rowsPerPage,
        0));
    widget.customerKey?.currentState?.refreshCustomer();
  }

  void _refreshEditData() {
    setState(() {
      isEdit = false;
      nameController.clear();
      phoneController.clear();
      emailController.clear();
      addressController.clear();
    });
    context.read<CustomerBloc>().add(FetchLocations());
    widget.customerKey?.currentState?.refreshCustomer();
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        currentPage = page;
        customerLoad = true;
      });
      context.read<CustomerBloc>().add(FetchAllCustomers(
          searchController.text,
          locationId ?? "",
          rowsPerPage,
          (page - 1) * rowsPerPage));
    }
  }

  void _changeRowsPerPage(int? newValue) {
    if (newValue != null) {
      setState(() {
        rowsPerPage = newValue;
        currentPage = 1;
        customerLoad = true;
      });
      context.read<CustomerBloc>().add(FetchAllCustomers(
          searchController.text,
          locationId ?? "",
          newValue,
          0));
    }
  }

  @override
  void dispose() {
    super.dispose();
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
              Row(
                children: [
                  Text(
                    isEdit ? "Edit Customer" : "Add Customer",
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
                      tooltip: 'Refresh Customers',
                    ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
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
                      : const SizedBox.shrink()
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Customer Name *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email Address",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              TextField(
                controller: addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 30),

              isEdit == true
                  ? Center(
                child: editLoad
                    ? SpinKitCircle(color: appPrimaryColor, size: 30)
                    : ElevatedButton(
                  onPressed: () {
                    if (getLocationModel.data?.locationName ==
                        null) {
                      showToast("Location not found", context,
                          color: false);
                    } else if (nameController.text.isEmpty) {
                      showToast("Enter customer name", context,
                          color: false);
                    } else if (phoneController.text.isEmpty) {
                      showToast("Enter phone number", context,
                          color: false);
                    } else {
                      setState(() {
                        editLoad = true;
                        context.read<CustomerBloc>().add(
                            UpdateCustomer(
                                customerId.toString(),
                                nameController.text,
                                phoneController.text,
                                emailController.text,
                                addressController.text,
                                locationId.toString()));
                      });
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
                    "Update Customer",
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
                    if (getLocationModel.data?.locationName ==
                        null) {
                      showToast("Location not found", context,
                          color: false);
                    } else if (nameController.text.isEmpty) {
                      showToast("Enter customer name", context,
                          color: false);
                    } else if (phoneController.text.isEmpty) {
                      showToast("Enter phone number", context,
                          color: false);
                    } else {
                      setState(() {
                        saveLoad = true;
                        context.read<CustomerBloc>().add(SaveCustomer(
                            nameController.text,
                            phoneController.text,
                            emailController.text,
                            addressController.text,
                            locationId.toString()));
                      });
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
                    "SAVE CUSTOMER",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Customers List",
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
                      decoration: const InputDecoration(
                        hintText: 'Search by name or phone...',
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          currentPage = 1;
                          customerLoad = true;
                        });
                        context.read<CustomerBloc>().add(FetchAllCustomers(
                            value,
                            locationId ?? "",
                            rowsPerPage,
                            0));
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {
                      searchController.clear();
                      _refreshData();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        minimumSize: const Size(0, 50),
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

              customerLoad
                  ? Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1),
                  alignment: Alignment.center,
                  child: const SpinKitChasingDots(
                      color: appPrimaryColor, size: 30))
                  : getCustomerModel.data == null ||
                  getCustomerModel.data!.isEmpty
                  ? Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1),
                  alignment: Alignment.center,
                  child: Text(
                    "No Customers Found !!!",
                    style: MyTextStyle.f16(
                      greyColor,
                      weight: FontWeight.w500,
                    ),
                  ))
                  : Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          Colors.grey.shade200),
                      dataRowHeight: 55,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      columns: const [
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Phone")),
                        DataColumn(label: Text("Email")),
                        DataColumn(label: Text("Address")),
                        DataColumn(label: Text("Location")),
                        DataColumn(label: Text("Actions"),
                            numeric: true),
                      ],
                      rows: _getCurrentPageItems().map((item) {
                        // Cast item to the correct type or use dynamic
                        final customer = item as dynamic;
                        return DataRow(
                          cells: [
                            DataCell(Text(customer.name ?? "")),
                            DataCell(Text(customer.phone ?? "")),
                            DataCell(Text(customer.email ?? "N/A")),
                            DataCell(Text(customer.address ?? "N/A")),
                            DataCell(Text(
                                customer.location?.name ?? "")),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: appPrimaryColor,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isEdit = true;
                                        customerId =
                                            customer.id?.toString();
                                      });
                                      if (customer.id != null) {
                                        context
                                            .read<CustomerBloc>()
                                            .add(FetchCustomerById(
                                            customer.id!
                                                .toString()));
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints:
                                    const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Rows per page:"),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: rowsPerPage,
                              onChanged: _changeRowsPerPage,
                              items: [5, 10, 15, 20, 25]
                                  .map<DropdownMenuItem<int>>(
                                      (int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                        Text(
                          "${((currentPage - 1) * rowsPerPage) + 1} - ${currentPage * rowsPerPage > totalItems ? totalItems : currentPage * rowsPerPage} of $totalItems",
                          style: MyTextStyle.f14(
                            blackColor,
                            weight: FontWeight.normal,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: currentPage > 1
                                  ? () => _goToPage(currentPage - 1)
                                  : null,
                              color: currentPage > 1
                                  ? appPrimaryColor
                                  : Colors.grey,
                            ),
                            ...List.generate(
                              totalPages > 5 ? 5 : totalPages,
                                  (index) {
                                int pageNumber;
                                if (totalPages <= 5) {
                                  pageNumber = index + 1;
                                } else if (currentPage <= 3) {
                                  pageNumber = index + 1;
                                } else if (currentPage >=
                                    totalPages - 2) {
                                  pageNumber = totalPages - 4 + index;
                                } else {
                                  pageNumber = currentPage - 2 + index;
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _goToPage(pageNumber),
                                    child: Container(
                                      padding:
                                      const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: currentPage ==
                                            pageNumber
                                            ? appPrimaryColor
                                            : Colors.transparent,
                                        borderRadius:
                                        BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        pageNumber.toString(),
                                        style: TextStyle(
                                          color: currentPage ==
                                              pageNumber
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight:
                                          currentPage == pageNumber
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: currentPage < totalPages
                                  ? () => _goToPage(currentPage + 1)
                                  : null,
                              color: currentPage < totalPages
                                  ? appPrimaryColor
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    return BlocBuilder<CustomerBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetLocationModel) {
          getLocationModel = current;
          if (getLocationModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getLocationModel.success == true) {
            locationId = getLocationModel.data?.locationId;
            debugPrint("✅ Location ID: $locationId");
            context.read<CustomerBloc>().add(FetchAllCustomers(
                searchController.text,
                locationId ?? "",
                rowsPerPage,
                0));
            setState(() {
              customerLoad = true;
            });
          } else {
            setState(() {
              customerLoad = false;
            });
            showToast("No Location found", context, color: false);
          }
          return true;
        }

        if (current is GetCustomerModel) {
          getCustomerModel = current;

          debugPrint("=== GetCustomerModel Response ===");
          debugPrint("Success: ${getCustomerModel.success}");
          debugPrint("Data length: ${getCustomerModel.data?.length}");
          debugPrint("Total: ${getCustomerModel.total}");
          debugPrint("TotalCount: ${getCustomerModel.totalCount}");
          debugPrint(
              "Error Response: ${getCustomerModel.errorResponse?.message}");
          debugPrint("================================");

          if (getCustomerModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }

          if (getCustomerModel.success == true) {
            totalItems = getCustomerModel.total?.toInt() ?? 0;
            totalPages = totalItems > 0 ? (totalItems / rowsPerPage).ceil() : 1;

            debugPrint("Total Items: $totalItems");
            debugPrint("Total Pages: $totalPages");

            setState(() {
              customerLoad = false;
            });
          } else {
            setState(() {
              customerLoad = false;
            });

            String errorMsg = getCustomerModel.errorResponse?.message ??
                "No Customers found";
            debugPrint("Error Message: $errorMsg");
            showToast(errorMsg, context, color: false);
          }
          return true;
        }

        if (current is PostCustomerModel) {
          postCustomerModel = current;
          if (postCustomerModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (postCustomerModel.success == true) {
            showToast("Customer Added Successfully", context, color: true);
            context.read<CustomerBloc>().add(FetchAllCustomers(
                searchController.text,
                locationId ?? "",
                rowsPerPage,
                0));
            Future.delayed(Duration(milliseconds: 100), () {
              clearCustomerForm();
            });
            setState(() {
              saveLoad = false;
            });
          } else {
            setState(() {
              saveLoad = false;
            });
          }
          return true;
        }

        if (current is GetCustomerByIdModel) {
          getCustomerByIdModel = current;
          if (getCustomerByIdModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getCustomerByIdModel.success == true) {
            setState(() {
              if (getCustomerByIdModel.data != null) {
                nameController.text = getCustomerByIdModel.data!.name ?? "";
                phoneController.text = getCustomerByIdModel.data!.phone ?? "";
                emailController.text = getCustomerByIdModel.data!.email ?? "";
                addressController.text =
                    getCustomerByIdModel.data!.address ?? "";
              }
              customerShowLoad = false;
            });
          } else {
            setState(() {
              customerShowLoad = false;
            });
          }
          return true;
        }

        if (current is PutCustomerByIdModel) {
          putCustomerByIdModel = current;
          if (putCustomerByIdModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (putCustomerByIdModel.success == true) {
            showToast("Customer Updated Successfully", context, color: true);
            _refreshEditData();
            context.read<CustomerBloc>().add(FetchAllCustomers(
                searchController.text,
                locationId ?? "",
                rowsPerPage,
                0));
            Future.delayed(Duration(milliseconds: 100), () {
              clearCustomerForm();
            });
            setState(() {
              editLoad = false;
            });
          } else {
            setState(() {
              editLoad = false;
            });
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