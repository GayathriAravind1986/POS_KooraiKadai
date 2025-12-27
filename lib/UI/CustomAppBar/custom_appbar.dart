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
  GetStockMaintanencesModel getStockMaintanencesModel = GetStockMaintanencesModel();
  bool stockLoad = false;

  // Track dropdown state
  bool _isCateringDropdownOpen = false;
  final GlobalKey _cateringButtonKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;

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
    _removeDropdownOverlay();
    super.dispose();
  }

  void _removeDropdownOverlay() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    setState(() {
      _isCateringDropdownOpen = false;
    });
  }

  void _toggleCateringDropdown() {
    if (_isCateringDropdownOpen) {
      _removeDropdownOverlay();
    } else {
      _showDropdownOverlay();
    }
  }

  void _showDropdownOverlay() {
    final RenderBox? renderBox = _cateringButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _dropdownOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _removeDropdownOverlay(),
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping inside dropdown
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customers option
                        _buildDropdownItem(
                          icon: Icons.people_outline,
                          label: "Customers",
                          onTap: () {
                            widget.onTabSelected(5);
                            _removeDropdownOverlay();
                          },
                          isSelected: widget.selectedIndex == 5,
                        ),
                        // Divider
                        const Divider(height: 1, color: Colors.grey),
                        // Catering Booking option
                        _buildDropdownItem(
                          icon: Icons.calendar_today_outlined,
                          label: "Catering Booking",
                          onTap: () {
                            widget.onTabSelected(6);
                            _removeDropdownOverlay();
                          },
                          isSelected: widget.selectedIndex == 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
    setState(() {
      _isCateringDropdownOpen = true;
    });
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
            final isCompactMode = constraints.maxWidth < 600;

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
                        if (getStockMaintanencesModel.data?.stockMaintenance == true) ...[
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
                        // Catering dropdown button
                        _buildCateringDropdownButton(isCompactMode),
                        SizedBox(width: isCompactMode ? 8 : 16),
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

  Widget _buildCateringDropdownButton(bool isCompactMode) {
    final isCateringSelected = widget.selectedIndex == 5 || widget.selectedIndex == 6;

    return Container(
      key: _cateringButtonKey,
      child: TextButton.icon(
        onPressed: _toggleCateringDropdown,
        icon: Icon(
          Icons.restaurant,
          size: 24,
          color: isCateringSelected ? appPrimaryColor : greyColor,
        ),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Catering",
              style: MyTextStyle.f16(
                weight: FontWeight.bold,
                isCateringSelected ? appPrimaryColor : greyColor,
              ).copyWith(fontSize: 15),
            ),
            const SizedBox(width: 4),
            Icon(
              _isCateringDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 20,
              color: isCateringSelected ? appPrimaryColor : greyColor,
            ),
          ],
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isCompactMode ? 4 : 6,
            vertical: 8,
          ),
        ),
      ),
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

  Widget _buildDropdownItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? appPrimaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? appPrimaryColor : greyColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: MyTextStyle.f14(
                weight: FontWeight.w500,
                isSelected ? appPrimaryColor : greyColor,
              ),
            ),
          ],
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