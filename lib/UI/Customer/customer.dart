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
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  String? locationId;
  bool saveLoad = false;
  bool editLoad = false;
  bool customerLoad = false;
  bool customerShowLoad = false;
  bool isEdit = false;
  String? errorMessage;
  String? customerId;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  int currentPage = 1;
  int rowsPerPage = 10;
  num totalItems = 0;
  int totalPages = 1;

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? selectedFromDate ?? DateTime.now() : selectedToDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          selectedFromDate = picked;
          fromDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          selectedToDate = picked;
          toDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });

      if (selectedFromDate != null && selectedToDate != null) {
        setState(() {
          currentPage = 1;
          customerLoad = true;
        });
        context.read<CustomerBloc>().add(FetchAllCustomers(
          searchController.text,
          locationId ?? "",
          rowsPerPage,
          0,
          _formatDate(selectedFromDate!),
          _formatDate(selectedToDate!),
        ));
      }
    }
  }

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
        customerLoad = true;
      });
      context.read<CustomerBloc>().add(FetchAllCustomers(
        searchController.text,
        locationId ?? "",
        rowsPerPage,
        (page - 1) * rowsPerPage,
        selectedFromDate != null ? _formatDate(selectedFromDate!) : "",
        selectedToDate != null ? _formatDate(selectedToDate!) : "",
      ));
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
        0,
        selectedFromDate != null ? _formatDate(selectedFromDate!) : "",
        selectedToDate != null ? _formatDate(selectedToDate!) : "",
      ));
    }
  }

  void refreshCustomer() {
    if (!mounted || !context.mounted) return;
    context.read<CustomerBloc>().add(FetchLocations());
    setState(() {
      customerLoad = true;
    });

    context.read<CustomerBloc>().add(FetchAllCustomers(
      searchController.text,
      locationId ?? "",
      rowsPerPage,
      (currentPage - 1) * rowsPerPage,
      selectedFromDate != null ? _formatDate(selectedFromDate!) : "",
      selectedToDate != null ? _formatDate(selectedToDate!) : "",
    ));
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

    selectedFromDate = DateTime.now().subtract(const Duration(days: 30));
    selectedToDate = DateTime.now();
    fromDateController.text = DateFormat('dd/MM/yyyy').format(selectedFromDate!);
    toDateController.text = DateFormat('dd/MM/yyyy').format(selectedToDate!);

    if (widget.hasRefreshedCustomer == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          customerLoad = true;
        });
        widget.customerKey?.currentState?.refreshCustomer();
      });
    } else {
      context.read<CustomerBloc>().add(FetchLocations());
      setState(() {
        customerLoad = true;
      });
    }
  }

  void _refreshData() {
    setState(() {
      searchController.clear();
      fromDateController.clear();
      toDateController.clear();
      selectedFromDate = null;
      selectedToDate = null;
      currentPage = 1;
      customerLoad = true;
    });
    context.read<CustomerBloc>().add(FetchAllCustomers(
      "",
      locationId ?? "",
      rowsPerPage,
      0,
      "",
      "",
    ));
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

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    searchController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            context.read<CustomerBloc>().add(FetchAllCustomers(
              searchController.text,
              locationId ?? "",
              rowsPerPage,
              0,
              selectedFromDate != null ? _formatDate(selectedFromDate!) : "",
              selectedToDate != null ? _formatDate(selectedToDate!) : "",
            ));
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

          if (getCustomerModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }

          if (getCustomerModel.success == true) {
            totalItems = getCustomerModel.total?.toInt() ?? 0;
            totalPages = totalItems > 0 ? (totalItems / rowsPerPage).ceil() : 1;

            setState(() {
              customerLoad = false;
            });
          } else {
            setState(() {
              customerLoad = false;
            });
            String errorMsg = getCustomerModel.errorResponse?.message ??
                "No Customers found";
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
            setState(() {
              currentPage = 1;
            });
            context.read<CustomerBloc>().add(FetchAllCustomers(
              searchController.text,
              locationId ?? "",
              rowsPerPage,
              0,
              selectedFromDate != null ? _formatDate(selectedFromDate!) : "",
              selectedToDate != null ? _formatDate(selectedToDate!) : "",
            ));
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
              (currentPage - 1) * rowsPerPage,
              selectedFromDate != null ? _formatDate(selectedFromDate!) : "",
              selectedToDate != null ? _formatDate(selectedToDate!) : "",
            ));
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
                              locationId.toString(),
                            ),
                          );
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
                        color: Colors.white,
                      ),
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
                          context.read<CustomerBloc>().add(
                            SaveCustomer(
                              nameController.text,
                              phoneController.text,
                              emailController.text,
                              addressController.text,
                              locationId.toString(),
                            ),
                          );
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
                        color: Colors.white,
                      ),
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
                            0,
                            selectedFromDate != null ? _formatDate(selectedFromDate!) : "",
                            selectedToDate != null ? _formatDate(selectedToDate!) : "",
                          ));
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: fromDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'From Date',
                          prefixIcon: Icon(Icons.calendar_today, color: appPrimaryColor),
                          border: const OutlineInputBorder(),
                        ),
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: toDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'To Date',
                          prefixIcon: Icon(Icons.calendar_today, color: appPrimaryColor),
                          border: const OutlineInputBorder(),
                        ),
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        _refreshData();
                      },
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
                  ],
                ),
                const SizedBox(height: 20),
                customerLoad
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
                    : getCustomerModel.data == null ||
                    getCustomerModel.data!.isEmpty
                    ? Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "No Customers Found !!!",
                    style: MyTextStyle.f16(
                      greyColor,
                      weight: FontWeight.w500,
                    ),
                  ),
                )
                    : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - 40,
                          ),
                          child: DataTable(
                            dataRowHeight: 50,
                            headingRowHeight: 50,
                            horizontalMargin: 20,
                            columnSpacing: 32,
                            headingRowColor:
                            MaterialStateProperty.all(greyColor200),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Phone',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Email',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Address',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Location',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: _getCurrentPageItems().map((item) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.15,
                                      ),
                                      child: Text(
                                        item.name ?? "",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(item.phone ?? "")),
                                  DataCell(
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.15,
                                      ),
                                      child: Text(
                                        item.email ?? "N/A",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.2,
                                      ),
                                      child: Text(
                                        item.address ?? "N/A",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.15,
                                      ),
                                      child: Text(
                                        item.location?.name ?? "",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              isEdit = true;
                                              customerId =
                                                  item.id?.toString();
                                            });
                                            if (item.id != null) {
                                              context
                                                  .read<
                                                  CustomerBloc>()
                                                  .add(
                                                FetchCustomerById(
                                                  item.id!
                                                      .toString(),
                                                ),
                                              );
                                            }
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
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: buildPaginationBar(),
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