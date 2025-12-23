import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Catering/catering_bloc.dart';
import 'package:simple/ModelClass/StockIn/getLocationModel.dart';
import 'package:simple/Reusable/color.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool isActive = true;
  bool addCus = false;
  bool locLoad = false;
  bool saveLoad = false;
  DateTime selectedDate = DateTime.now();
  String? selectedLocation;
  String? locationId;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<CateringBloc>().add(CateringLocation());
    setState(() {
      locLoad = true;
    });
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
                          TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Date",
                              suffixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
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
                            child: DropdownButtonFormField(
                              items: const [],
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                labelText: "Customer",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField(
                              items: const [],
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                labelText: "Package",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField(
                              items: const [],
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                labelText: "Items",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField(
                              items: const [],
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                labelText: "Addons",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField(
                              items: const [],
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                labelText: "Discount Type",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField(
                              items: const [],
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                labelText: "Payment Type",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          /// AMOUNTS ROW
                          Row(
                            children: [
                              Expanded(
                                  child: TextFormField(
                                readOnly: true,
                                initialValue: "0",
                                decoration: InputDecoration(
                                  labelText: "Package Amount",
                                  border: const OutlineInputBorder(),
                                ),
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: TextFormField(
                                readOnly: true,
                                initialValue: "0",
                                decoration: InputDecoration(
                                  labelText: "Addon Amount",
                                  border: const OutlineInputBorder(),
                                ),
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: TextFormField(
                                readOnly: true,
                                initialValue: "0",
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
                            initialValue: "0",
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
                          onPressed: () async {},
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
              // context
              //     .read<StockInBloc>()
              //     .add(StockInSupplier(locationId.toString()));
              // context
              //     .read<StockInBloc>()
              //     .add(StockInAddProduct(locationId.toString()));
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
