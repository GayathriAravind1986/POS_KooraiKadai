import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Catering/catering_bloc.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditBooking extends StatelessWidget {
  final bool isTablet;
  final String cusId;
  const EditBooking({super.key, required this.isTablet, required this.cusId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CateringBloc(),
      child: EditBookingView(isTablet: isTablet, cusId: cusId),
    );
  }
}

class EditBookingView extends StatefulWidget {
  final bool isTablet;
  final String cusId;
  const EditBookingView({
    super.key,
    required this.isTablet,
    required this.cusId,
  });

  @override
  State<EditBookingView> createState() => _EditBookingViewState();
}

class _EditBookingViewState extends State<EditBookingView> {
  final _formKey = GlobalKey<FormState>();
  bool isActive = true;
  bool customerLoad = false;
  bool editLoad = false;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  @override
  void initState() {
    super.initState();
    //context.read<CustomerBloc>().add(CustomerById(widget.cusId.toString()));
    setState(() {
      customerLoad = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );

    Widget mainContainer() {
      return customerLoad
          ? Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
              ),
              alignment: Alignment.center,
              child: const SpinKitFadingCube(color: appPrimaryColor, size: 30),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Edit Booking",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Name fields
                      widget.isTablet
                          ? Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'First name',
                                    firstNameController,
                                    inputDecoration,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTextField(
                                    'Last name',
                                    lastNameController,
                                    inputDecoration,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildTextField(
                                  'First name',
                                  firstNameController,
                                  inputDecoration,
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  'Last name',
                                  lastNameController,
                                  inputDecoration,
                                ),
                              ],
                            ),
                      const SizedBox(height: 12),

                      // Phone + Email
                      widget.isTablet
                          ? Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Phone',
                                    phoneController,
                                    inputDecoration,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTextField(
                                    'Email',
                                    emailController,
                                    inputDecoration,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildTextField(
                                  'Phone',
                                  phoneController,
                                  inputDecoration,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  'Email',
                                  emailController,
                                  inputDecoration,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ],
                            ),
                      const SizedBox(height: 12),

                      // Address
                      _buildTextField(
                        'Address',
                        addressController,
                        inputDecoration,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),

                      // Active checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: isActive,
                            activeColor: appPrimaryColor,
                            onChanged: (v) =>
                                setState(() => isActive = v ?? true),
                          ),
                          const Text('Active'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: appPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          editLoad
                              ? const SpinKitCircle(
                                  color: appPrimaryColor,
                                  size: 30,
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // context.read<CustomerBloc>().add(
                                      //       UpdateCustomer(
                                      //         widget.cusId,
                                      //         firstNameController.text,
                                      //         lastNameController.text,
                                      //         phoneController.text,
                                      //         emailController.text,
                                      //         addressController.text,
                                      //         isActive,
                                      //       ),
                                      //     );
                                      setState(() {
                                        editLoad = true;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appPrimaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'UPDATE',
                                    style: TextStyle(color: whiteColor),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
    }

    return Scaffold(
      backgroundColor: whiteColor,
      body: BlocBuilder<CateringBloc, dynamic>(
        buildWhen: ((previous, current) {
          // if (current is GetCustomerByIdModel) {
          //   getCustomerByIdModel = current;
          //   if (getCustomerByIdModel.success == true) {
          //     setState(() {
          //       customerLoad = false;
          //       firstNameController.text =
          //           getCustomerByIdModel.result!.firstName.toString();
          //       lastNameController.text =
          //           getCustomerByIdModel.result!.lastName.toString();
          //       phoneController.text =
          //           getCustomerByIdModel.result!.phone.toString();
          //       addressController.text =
          //           getCustomerByIdModel.result!.address.toString();
          //       emailController.text =
          //           getCustomerByIdModel.result!.email.toString();
          //       isActive = getCustomerByIdModel.result!.isActive ?? false;
          //     });
          //   } else if (getCustomerByIdModel.errorResponse != null) {
          //     debugPrint(
          //       "Error: ${getCustomerByIdModel.errorResponse?.message}",
          //     );
          //     setState(() {
          //       customerLoad = false;
          //     });
          //   }
          //   if (getCustomerByIdModel.errorResponse?.isUnauthorized == true) {
          //     _handle401Error();
          //     return true;
          //   }
          //   return true;
          // }
          // if (current is UpdateCustomerModel) {
          //   updateCustomerModel = current;
          //   if (updateCustomerModel.errorResponse?.isUnauthorized == true) {
          //     _handle401Error();
          //     return true;
          //   }
          //   if (updateCustomerModel.errorResponse?.statusCode == 500) {
          //     showToast(
          //       updateCustomerModel.message ?? "Server error occurred",
          //       context,
          //       color: false,
          //     );
          //     setState(() => editLoad = false);
          //     return true;
          //   }
          //   if (updateCustomerModel.success == true) {
          //     showToast(
          //       updateCustomerModel.message ?? "Customer Updated successfully",
          //       context,
          //       color: true,
          //     );
          //     setState(() {
          //       editLoad = false;
          //     });
          //     Future.microtask(() {
          //       Navigator.of(context).pushReplacement(
          //         MaterialPageRoute(
          //           builder: (context) => const DashBoardScreen(selectedTab: 1),
          //         ),
          //       );
          //     });
          //   } else if (updateCustomerModel.success == false) {
          //     showToast(
          //       updateCustomerModel.message.toString(),
          //       context,
          //       color: true,
          //     );
          //     setState(() {
          //       editLoad = false;
          //     });
          //   } else if (updateCustomerModel.errorResponse != null) {
          //     showToast(
          //       updateCustomerModel.errorResponse?.message ??
          //           "An error occurred",
          //       context,
          //       color: false,
          //     );
          //     setState(() => editLoad = false);
          //   }
          //   return true;
          // }
          return false;
        }),
        builder: (context, dynamic) {
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    InputDecoration decoration, {
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        TextSelectionTheme(
          data: const TextSelectionThemeData(
            cursorColor: appPrimaryColor,
            selectionColor: appPrimaryColor,
            selectionHandleColor: appPrimaryColor,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(color: appPrimaryColor, fontSize: 14),
            decoration: decoration.copyWith(
              hintText: hintText,
              hintStyle: const TextStyle(color: greyColor, fontSize: 14),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: appGreyColor),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appGreyColor),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: appPrimaryColor.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: redColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
          ),
        ),
      ],
    );
  }
}
