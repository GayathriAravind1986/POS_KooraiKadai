import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Catering/catering_bloc.dart';
import 'package:simple/ModelClass/Catering/getAllCateringModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:simple/UI/Catering/add_booking.dart';
import 'package:simple/UI/Catering/edit_booking.dart';

class CateringViewBooking extends StatelessWidget {
  final GlobalKey<CateringViewViewBookingState>? cateringKey;
  bool? hasRefreshedCatering;
  CateringViewBooking({
    super.key,
    this.cateringKey,
    this.hasRefreshedCatering,
  });

  @override
  Widget build(BuildContext context) {
    return CateringViewViewBooking(
        cateringKey: cateringKey, hasRefreshedCatering: hasRefreshedCatering);
  }
}

class CateringViewViewBooking extends StatefulWidget {
  final GlobalKey<CateringViewViewBookingState>? cateringKey;
  bool? hasRefreshedCatering;
  CateringViewViewBooking({
    super.key,
    this.cateringKey,
    this.hasRefreshedCatering,
  });

  @override
  CateringViewViewBookingState createState() => CateringViewViewBookingState();
}

class CateringViewViewBookingState extends State<CateringViewViewBooking> {
  GetCateringModel getCateringModel = GetCateringModel();
  String? errorMessage;
  bool cateringLoad = false;
  bool? isEdit = false;
  void refreshCatering() {
    if (!mounted || !context.mounted) return;
    //context.read<CateringBloc>().add(CateringBooking());
    setState(() {
      cateringLoad = true;
    });
  }

  void showAddBookingDialog(BuildContext context, String? cusId) {
    showDialog(
      context: context,
      barrierColor: greyColor.withOpacity(0.85),
      builder: (context) {
        final isTablet = MediaQuery.of(context).size.width > 600;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 100 : 16,
            vertical: isTablet ? 60 : 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: isEdit == true
                ? EditBooking(isTablet: isTablet, cusId: cusId.toString())
                : AddBooking(isTablet: isTablet, from: ""),
          ),
        );
      },
    );
  }

  void clearStockInForm() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.hasRefreshedCatering == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.cateringKey?.currentState?.refreshCatering();
        setState(() {
          cateringLoad = true;
        });
      });
    } else {
      //context.read<CateringBloc>().add(CateringBooking());
      setState(() {
        cateringLoad = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget mainContainer() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Catering Booking',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showAddBookingDialog(context, "");
                    },
                    icon: const Icon(Icons.add, color: whiteColor),
                    label:
                        Text('ADD BOOKING', style: MyTextStyle.f14(whiteColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 16),

              /// TABLE
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
                                  child: DataTable(
                                    headingRowColor:
                                        MaterialStateProperty.all(greyColor200),
                                    columnSpacing: 32,
                                    columns: const [
                                      DataColumn(label: Text('Date')),
                                      DataColumn(label: Text('Customer')),
                                      DataColumn(label: Text('Location')),
                                      DataColumn(label: Text('Amount')),
                                      DataColumn(label: Text('Payment Type')),
                                      DataColumn(label: Text('Balance')),
                                      DataColumn(label: Text('Payment Mode')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: getCateringModel.data!.map((item) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(DateFormat('dd-MM-yyyy')
                                              .format(
                                                  DateTime.parse(item.date!)))),
                                          DataCell(
                                              Text(item.customer?.name ?? "")),
                                          DataCell(
                                              Text(item.location?.name ?? "")),
                                          DataCell(Text(
                                              item.finalamount?.toString() ??
                                                  "-")),
                                          DataCell(Text(
                                              item.paymenttype.toString() ??
                                                  "")),
                                          DataCell(Text(
                                              item.balanceamount?.toString() ??
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
                                                  child: const Icon(Icons.edit,
                                                      color: appPrimaryColor),
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
        if (current is GetCateringModel) {
          getCateringModel = current;
          if (getCateringModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getCateringModel.success == true) {
            setState(() {
              cateringLoad = false;
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
