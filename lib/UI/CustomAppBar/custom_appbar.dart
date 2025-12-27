import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLogout;
  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodCategoryBloc(),
      child: CustomAppBarView(
        selectedIndex: selectedIndex,
        onTabSelected: onTabSelected,
        onLogout: onLogout,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class CustomAppBarView extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLogout;
  const CustomAppBarView({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  CustomAppBarViewState createState() => CustomAppBarViewState();
}

class CustomAppBarViewState extends State<CustomAppBarView> {
  GetStockMaintanencesModel getStockMaintanencesModel =
      GetStockMaintanencesModel();
  bool stockLoad = false;
  @override
  void initState() {
    super.initState();
    context.read<FoodCategoryBloc>().add(StockDetails());
    setState(() {
      stockLoad = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Widget mainContainer() {
      return AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if we need compact mode based on available width
            final isCompactMode = constraints.maxWidth < 600;
            debugPrint("layoutidth:$isCompactMode");
            return Row(
              children: [
                // Store/Restaurant Name
                if (getStockMaintanencesModel.data?.name != null)
                  Flexible(
                    flex: 3,
                    child: Text(
                      getStockMaintanencesModel.data!.name.toString(),
                      style: TextStyle(
                        fontSize: isCompactMode ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: appPrimaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const SizedBox.shrink(),

                const SizedBox(width: 30),

                // Navigation Tabs
                Expanded(
                  flex: isCompactMode ? 5 : 15,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildNavButton(
                          icon: Icons.home_outlined,
                          label: "Home",
                          index: 0,
                          isSelected: widget.selectedIndex == 0,
                          onPressed: () => widget.onTabSelected(0),
                          isCompact: isCompactMode,
                        ),
                        SizedBox(width: isCompactMode ? 8 : 16),
                        _buildNavButton(
                          icon: Icons.shopping_cart_outlined,
                          label: "Orders",
                          index: 1,
                          isSelected: widget.selectedIndex == 1,
                          onPressed: () => widget.onTabSelected(1),
                          isCompact: isCompactMode,
                        ),
                        SizedBox(width: isCompactMode ? 8 : 16),
                        _buildNavButton(
                          icon: Icons.note_alt_outlined,
                          label: "Report",
                          index: 2,
                          isSelected: widget.selectedIndex == 2,
                          onPressed: () => widget.onTabSelected(2),
                          isCompact: isCompactMode,
                        ),
                        SizedBox(width: isCompactMode ? 8 : 16),
                        if (getStockMaintanencesModel.data?.stockMaintenance ==
                            true) ...[
                          _buildNavButton(
                            icon: Icons.inventory,
                            label: "Stockin",
                            index: 3,
                            isSelected: widget.selectedIndex == 3,
                            onPressed: () => widget.onTabSelected(3),
                            isCompact: isCompactMode,
                          ),
                          SizedBox(width: isCompactMode ? 8 : 16),
                        ],
                        _buildNavButton(
                          icon: Icons.restaurant,
                          label: "Catering",
                          index: 4,
                          isSelected: widget.selectedIndex == 4,
                          onPressed: () => widget.onTabSelected(4),
                          isCompact: isCompactMode,
                        ),
                        SizedBox(width: isCompactMode ? 8 : 16),
                        _buildNavButton(
                          icon: Icons.people,
                          label: "Customers",
                          index: 5,
                          isSelected: widget.selectedIndex == 5,
                          onPressed: () => widget.onTabSelected(5),
                          isCompact: isCompactMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.logout, color: appPrimaryColor),
              onPressed: widget.onLogout,
              tooltip: 'Logout',
            ),
          ),
        ],
      );
      //   AppBar(
      //   backgroundColor: whiteColor,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   title: Container(
      //     margin: EdgeInsets.only(left: 10),
      //     child: Row(
      //       children: [
      //         getStockMaintanencesModel.data?.name != null
      //             ? Text(
      //                 getStockMaintanencesModel.data!.name.toString(),
      //                 style: TextStyle(
      //                   fontSize: 20,
      //                   fontWeight: FontWeight.bold,
      //                   color: appPrimaryColor,
      //                 ),
      //               )
      //             : Text(""),
      //         SizedBox(width: size.width * 0.2),
      //         Row(
      //           children: [
      //             TextButton.icon(
      //               onPressed: () => widget.onTabSelected(0),
      //               icon: Icon(
      //                 Icons.home_outlined,
      //                 size: 30,
      //                 color: widget.selectedIndex == 0
      //                     ? appPrimaryColor
      //                     : greyColor,
      //               ),
      //               label: Text(
      //                 "Home",
      //                 style: MyTextStyle.f16(
      //                   weight: FontWeight.bold,
      //                   widget.selectedIndex == 0 ? appPrimaryColor : greyColor,
      //                 ),
      //               ),
      //             ),
      //             SizedBox(width: 16),
      //             TextButton.icon(
      //               onPressed: () => widget.onTabSelected(1),
      //               icon: Icon(
      //                 Icons.shopping_cart_outlined,
      //                 size: 30,
      //                 color: widget.selectedIndex == 1
      //                     ? appPrimaryColor
      //                     : greyColor,
      //               ),
      //               label: Text(
      //                 "Orders",
      //                 style: MyTextStyle.f16(
      //                   weight: FontWeight.bold,
      //                   widget.selectedIndex == 1 ? appPrimaryColor : greyColor,
      //                 ),
      //               ),
      //             ),
      //             SizedBox(width: 16),
      //             TextButton.icon(
      //               onPressed: () => widget.onTabSelected(2),
      //               icon: Icon(
      //                 Icons.note_alt_outlined,
      //                 size: 30,
      //                 color: widget.selectedIndex == 2
      //                     ? appPrimaryColor
      //                     : greyColor,
      //               ),
      //               label: Text(
      //                 "Report",
      //                 style: MyTextStyle.f16(
      //                   weight: FontWeight.bold,
      //                   widget.selectedIndex == 2 ? appPrimaryColor : greyColor,
      //                 ),
      //               ),
      //             ),
      //             SizedBox(width: 16),
      //             (getStockMaintanencesModel.data?.stockMaintenance == true)
      //                 ? TextButton.icon(
      //                     onPressed: () => widget.onTabSelected(3),
      //                     icon: Icon(
      //                       Icons.inventory,
      //                       size: 30,
      //                       color: widget.selectedIndex == 3
      //                           ? appPrimaryColor
      //                           : greyColor,
      //                     ),
      //                     label: Text(
      //                       "Stockin",
      //                       style: MyTextStyle.f16(
      //                         weight: FontWeight.bold,
      //                         widget.selectedIndex == 3
      //                             ? appPrimaryColor
      //                             : greyColor,
      //                       ),
      //                     ),
      //                   )
      //                 : Container(),
      //             SizedBox(width: 16),
      //             TextButton.icon(
      //               onPressed: () => widget.onTabSelected(4),
      //               icon: Icon(
      //                 Icons.restaurant,
      //                 size: 30,
      //                 color: widget.selectedIndex == 4
      //                     ? appPrimaryColor
      //                     : greyColor,
      //               ),
      //               label: Text(
      //                 "Catering",
      //                 style: MyTextStyle.f16(
      //                   weight: FontWeight.bold,
      //                   widget.selectedIndex == 4 ? appPrimaryColor : greyColor,
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      //   actions: [
      //     Container(
      //       padding: EdgeInsets.only(right: 20),
      //       child: IconButton(
      //         icon: Icon(Icons.logout, color: appPrimaryColor),
      //         onPressed: widget.onLogout,
      //       ),
      //     ),
      //   ],
      // );
    }

    return BlocBuilder<FoodCategoryBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetStockMaintanencesModel) {
          getStockMaintanencesModel = current;
          if (getStockMaintanencesModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getStockMaintanencesModel.success == true) {
            setState(() {
              stockLoad = false;
            });
          } else {
            setState(() {
              stockLoad = false;
            });
            showToast("No Stock found", context, color: false);
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

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onPressed,
    required bool isCompact,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 24,
        color: isSelected ? appPrimaryColor : greyColor,
      ),
      label: Text(
        label,
        style: MyTextStyle.f16(
          weight: FontWeight.bold,
          isSelected ? appPrimaryColor : greyColor,
        ).copyWith(fontSize: 15),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 4 : 6,
          vertical: 8,
        ),
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
