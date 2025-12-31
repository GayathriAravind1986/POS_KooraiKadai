import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:simple/Bloc/Report/accounts_report_bloc.dart';
import 'package:simple/ModelClass/Accounts/GetReportModel.dart';
import 'package:simple/Reusable/color.dart';
import '../../Bloc/Report/report_bloc.dart';

class ReturnReportView extends StatefulWidget {
  const ReturnReportView({super.key});

  @override
  State<ReturnReportView> createState() => ReturnReportViewState();
}

class ReturnReportViewState extends State<ReturnReportView> {
  ReturnReportModel reportModel = ReturnReportModel();
  final TextEditingController searchController = TextEditingController();
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  int currentPage = 1;
  int rowsPerPage = 10;
  num totalItems = 0;
  int totalPages = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  void refreshReturnReport() {
    setState(() {
      currentPage = 1;
      searchController.clear();
    });
    _fetchReport();
  }

  void _fetchReport() {
    setState(() => isLoading = true);
    int offset = (currentPage - 1) * rowsPerPage;
    context.read<ReportBloc>().add(FetchReturnReport(
      fromDate: formatter.format(fromDate),
      toDate: formatter.format(toDate),
      search: searchController.text,
      limit: rowsPerPage,
      offset: offset, locid: '',
    ));
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
        if (fromDate.isAfter(toDate)) {
          toDate = fromDate;
        }
        currentPage = 1;
      });
      _fetchReport();
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
        currentPage = 1;
      });
      _fetchReport();
    }
  }

  Widget _buildSummaryCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, dynamic>(
      builder: (context, state) {
        print("🏗️ Building UI - State type: ${state.runtimeType}");

        // Update model when new data arrives
        if (state is ReturnReportModel) {
          print("✅ Received ReturnReportModel");
          print("📊 Data count: ${state.data?.length}");
          print("📊 Total records: ${state.totalRecords}");

          reportModel = state;
          totalItems = state.totalRecords ?? 0;
          totalPages = totalItems > 0 ? (totalItems / rowsPerPage).ceil() : 1;
          isLoading = false;

          // Check for errors
          if (state.errorResponse != null) {
            print("❌ Error in response: ${state.errorResponse?.message}");
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Credit & Return Report",
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Date Pickers & Search
                  Row(
                    children: [
                      _dateSelector(
                          "From", fromDate, () => _selectFromDate(context)),
                      const SizedBox(width: 15),
                      _dateSelector("To", toDate, () => _selectToDate(context)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: "Search customer...",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() => currentPage = 1);
                            _fetchReport();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary Cards
                  Row(
                    children: [
                      _buildSummaryCard("Total Credit Amount",
                          "₹${reportModel.summary?.totalCreditAmount ?? 0}"),
                      _buildSummaryCard("Total Return Amount",
                          "₹${reportModel.summary?.totalReturnAmount ?? 0}"),
                      _buildSummaryCard("Total Balance Due",
                          "₹${reportModel.summary?.totalBalanceDue ?? 0}"),
                      _buildSummaryCard("Customers with Due",
                          "${reportModel.summary?.customersWithDue ?? 0}"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Full Screen Responsive Table
                  if (isLoading)
                    Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.1,
                          ),
                          child: const SpinKitChasingDots(
                              color: appPrimaryColor, size: 40),
                        ))
                  else if (reportModel.data == null ||
                      reportModel.data!.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05,
                        ),
                        child: const Text(
                          "No data available",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Width Responsive Table
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width - 40,
                            ),
                            child: DataTable(
                              headingRowColor:
                              MaterialStateProperty.all(Colors.grey[100]),
                              columnSpacing: 24,
                              dataRowMinHeight: 48,
                              dataRowMaxHeight: 60,
                              columns: const [
                                DataColumn(
                                    label: Text('Customer Name',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Total Credit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Total Return',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Balance Due',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Credit Count',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Return Count',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                              ],
                              rows: reportModel.data!.map((item) {
                                return DataRow(cells: [
                                  DataCell(Text(item.customerName ?? "")),
                                  DataCell(Text("₹${item.totalCredit ?? 0}")),
                                  DataCell(Text("₹${item.totalReturn ?? 0}")),
                                  DataCell(Text("₹${item.balanceDue ?? 0}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          ))),
                                  DataCell(Text("${item.creditCount ?? 0}")),
                                  DataCell(Text("${item.returnCount ?? 0}")),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),

                        // Pagination centered below table
                        const SizedBox(height: 16),
                        _buildPaginationBar(),
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

  Widget _dateSelector(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(DateFormat('dd-MM-yyyy').format(date)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationBar() {
    int start = ((currentPage - 1) * rowsPerPage) + 1;
    int end = currentPage * rowsPerPage;

    if (end > totalItems) {
      end = totalItems.toInt();
    }

    if (totalItems == 0) {
      start = 0;
      end = 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Rows per page: "),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: rowsPerPage,
          items: [5, 10, 20, 50]
              .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
              .toList(),
          onChanged: (value) {
            setState(() {
              rowsPerPage = value!;
              currentPage = 1;
            });
            _fetchReport();
          },
        ),
        const SizedBox(width: 20),
        Text("$start - $end of $totalItems"),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () {
            setState(() => currentPage--);
            _fetchReport();
          }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () {
            setState(() => currentPage++);
            _fetchReport();
          }
              : null,
        ),
      ],
    );
  }
}