import 'dart:io';
import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/space.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/imin_abstract.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/mock_imin_printer_chrome.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/real_device_printer.dart';
import 'package:simple/UI/IminHelper/printer_helper.dart';
import 'package:simple/UI/KOT_printer_helper/printer_kot_helper.dart';

class ThermalReceiptDialog extends StatefulWidget {
  final GetViewOrderModel getViewOrderModel;

  const ThermalReceiptDialog(this.getViewOrderModel, {super.key});

  @override
  State<ThermalReceiptDialog> createState() => _ThermalReceiptDialogState();
}

class _ThermalReceiptDialogState extends State<ThermalReceiptDialog> {
  late IPrinterService printerService;
  GlobalKey normalReceiptKey = GlobalKey();
  GlobalKey kotReceiptKey = GlobalKey();
  final TextEditingController ipController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Fixed Bluetooth manager declaration
  List<BluetoothInfo> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    ipController.text = "192.168.1.4";
    if (kIsWeb) {
      printerService = MockPrinterService();
    } else if (Platform.isAndroid) {
      printerService = RealPrinterService();
    } else {
      printerService = MockPrinterService();
    }
  }

  Future<void> _scanBluetoothDevices() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    try {
      // Check if Bluetooth is enabled
      final bool result = await PrintBluetoothThermal.bluetoothEnabled;
      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bluetooth is not enabled"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isScanning = false);
        return;
      }

      // Get paired Bluetooth devices
      final List<BluetoothInfo> bluetooths =
          await PrintBluetoothThermal.pairedBluetooths;
      setState(() {
        _devices = bluetooths;
        _isScanning = false;
      });
    } catch (e) {
      debugPrint("Error scanning Bluetooth devices: $e");
      setState(() => _isScanning = false);
    }
  }

  Future<void> _selectBluetoothPrinter(BuildContext context) async {
    await _scanBluetoothDevices();

    if (_devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "No paired Bluetooth printers found. Please pair your printer first."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Select Bluetooth Printer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _devices.length,
                itemBuilder: (_, index) {
                  final printer = _devices[index];
                  return ListTile(
                    leading: const Icon(Icons.print),
                    title: Text(
                        printer.name), // Changed from printer.name ?? "Unknown"
                    subtitle: Text(printer
                        .macAdress), // Changed from printer.address ?? ""
                    onTap: () {
                      Navigator.pop(context);
                      _startKOTPrintingBluetoothOnly(context, printer);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _ensureIminServiceReady() async {
    try {
      await printerService.init();
    } catch (e) {
      debugPrint("Error reinitializing IMIN service: $e");
    }
  }

  /// LAN KOT Print
  Future<void> _startKOTPrintingThermalOnly(
      BuildContext context, String printerIp) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: appPrimaryColor),
              SizedBox(height: 16),
              Text("Preparing KOT for thermal printer...",
                  style: TextStyle(color: whiteColor)),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;

      Uint8List? imageBytes = await captureMonochromeKOTReceipt(kotReceiptKey);

      if (imageBytes != null) {
        final printer = PrinterNetworkManager(printerIp);
        final result = await printer.connect();

        if (result == PosPrintResult.success) {
          final profile = await CapabilityProfile.load();
          final generator = Generator(PaperSize.mm58, profile);

          final decodedImage = img.decodeImage(imageBytes);
          if (decodedImage != null) {
            final resizedImage = img.copyResize(
              decodedImage,
              width: 384, // 58mm = ~384 dots at 203 DPI
              maintainAspect: true,
            );
            List<int> bytes = [];
            bytes += generator.reset();
            bytes += generator.imageRaster(
              resizedImage,
              align: PosAlign.center,
              highDensityHorizontal: true, // Better quality
              highDensityVertical: true,
            );
            bytes += generator.feed(2);
            bytes += generator.cut();
            await printer.printTicket(bytes);
          }

          await printer.disconnect();

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("KOT printed to thermal printer only!"),
              backgroundColor: greenColor,
            ),
          );
        } else {
          // ❌ Failed to connect
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to connect to printer ($result)"),
              backgroundColor: redColor,
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
        throw Exception("Failed to capture KOT receipt image");
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("KOT Print failed: $e"),
          backgroundColor: redColor,
        ),
      );
    }
  }

  /// BT KOT Print
  Future<void> _startKOTPrintingBluetoothOnly(
      BuildContext context, BluetoothInfo printer) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: appPrimaryColor),
              SizedBox(height: 16),
              Text("Preparing KOT for Bluetooth printer...",
                  style: TextStyle(color: whiteColor)),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;

      Uint8List? imageBytes = await captureMonochromeKOTReceipt(kotReceiptKey);

      if (imageBytes != null) {
        final bool connectionResult = await PrintBluetoothThermal.connect(
            macPrinterAddress: printer.macAdress);

        if (!connectionResult) {
          throw Exception("Failed to connect to printer");
        }

        final profile = await CapabilityProfile.load();
        final generator = Generator(PaperSize.mm58, profile);

        final decodedImage = img.decodeImage(imageBytes);
        if (decodedImage != null) {
          // Updated API for image package v4.x
          final resizedImage = img.copyResize(
            decodedImage,
            width: 384,
            maintainAspect: true,
          );

          List<int> bytes = [];
          bytes += generator.reset();

          // For image v4.x, the imageRaster method signature may be different
          // Check the documentation, but this should work:
          bytes += generator.imageRaster(resizedImage);

          bytes += generator.feed(2);
          bytes += generator.cut();

          final bool printResult =
              await PrintBluetoothThermal.writeBytes(bytes);
          await PrintBluetoothThermal.disconnect;

          Navigator.of(context).pop();

          if (printResult) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("KOT printed to Bluetooth printer!"),
                backgroundColor: greenColor,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to send data to printer"),
                backgroundColor: redColor,
              ),
            );
          }
        }
      } else {
        Navigator.of(context).pop();
        throw Exception("Failed to capture KOT receipt image");
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("KOT Print failed: $e"),
          backgroundColor: redColor,
        ),
      );
    }
  }

  Future<void> _printBillToIminOnly(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: appPrimaryColor,
              ),
              SizedBox(height: 16),
              Text("Printing to IMIN device...",
                  style: TextStyle(color: whiteColor)),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await WidgetsBinding.instance.endOfFrame;

      Uint8List? imageBytes = await captureMonochromeReceipt(normalReceiptKey);

      if (imageBytes != null) {
        await printerService.init();
        await printerService.printBitmap(imageBytes);
        await printerService.fullCut();

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bill printed successfully to IMIN device!"),
            backgroundColor: greenColor,
          ),
        );
      } else {
        throw Exception("Image capture failed: normalReceiptKey returned null");
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("IMIN Print failed: $e"),
          backgroundColor: redColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.getViewOrderModel.data!;
    final invoice = order.invoice!;
    var size = MediaQuery.of(context).size;
    List<Map<String, dynamic>> items = invoice.invoiceItems!
        .map((e) => {
              'name': e.tamilname,
              'qty': e.qty,
              'price': (e.basePrice ?? 0).toDouble(),
              'total': ((e.qty ?? 0) * (e.basePrice ?? 0)).toDouble(),
            })
        .toList();

    String businessName = invoice.businessName ?? '';
    String address = invoice.address ?? '';
    String gst = invoice.gstNumber ?? '';
    debugPrint("gst:$gst");
    double taxAmount = (order.tax ?? 0.0).toDouble();
    String orderNumber = order.orderNumber ?? 'N/A';
    String paymentMethod = invoice.paidBy ?? '';
    String phone = invoice.phone ?? '';
    double subTotal = (invoice.subtotal ?? 0.0).toDouble();
    double total = (invoice.total ?? 0.0).toDouble();
    String orderType = order.orderType ?? '';
    String orderStatus = order.orderStatus ?? '';
    String tableName = orderType == 'LINE' || orderType == 'AC'
        ? (invoice.tableNum ?? 'N/A')
        : 'N/A';
    String waiterName = orderType == 'LINE' || orderType == 'AC'
        ? (invoice.waiterNum ?? 'N/A')
        : 'N/A';
    String date = DateFormat('dd/MM/yyyy hh:mm a').format(
        DateFormat('M/d/yyyy, h:mm:ss a').parse(invoice.date.toString()));

    return widget.getViewOrderModel.data == null
        ? Container(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
            alignment: Alignment.center,
            child: Text(
              "No Orders found",
              style: MyTextStyle.f16(
                greyColor,
                weight: FontWeight.w500,
              ),
            ))
        : Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: SingleChildScrollView(
              child: Container(
                width: size.width * 0.4,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: const Text(
                            "Order Receipt",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      key: normalReceiptKey,
                      child: getThermalReceiptWidget(
                        businessName: businessName,
                        address: address,
                        gst: gst,
                        items: items,
                        tax: taxAmount,
                        paidBy: paymentMethod,
                        tamilTagline: '',
                        phone: phone,
                        subtotal: subTotal,
                        total: total,
                        orderNumber: orderNumber,
                        tableName: tableName,
                        waiterName: waiterName,
                        orderType: orderType,
                        date: date,
                        status: orderStatus,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (order.orderType == "PARCEL")
                      RepaintBoundary(
                        key: kotReceiptKey,
                        child: getThermalReceiptKOTWidget(
                          businessName: businessName,
                          address: address,
                          gst: gst,
                          items: items,
                          paidBy: paymentMethod,
                          tamilTagline: '',
                          phone: phone,
                          subtotal: subTotal,
                          tax: taxAmount,
                          total: total,
                          orderNumber: orderNumber,
                          tableName: tableName,
                          waiterName: waiterName,
                          orderType: orderType,
                          date: date,
                          status: orderStatus,
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // if (order.orderType == "PARCEL")
                        //   ElevatedButton.icon(
                        //     onPressed: () {
                        //       _startKOTPrintingThermalOnly(
                        //         context,
                        //         ipController.text.trim(),
                        //       );
                        //     },
                        //     icon: const Icon(Icons.print),
                        //     label: const Text("KOT(LAN)"),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: greenColor,
                        //       foregroundColor: whiteColor,
                        //     ),
                        //   ),
                        // horizontalSpace(width: 10),
                        if (order.orderType == "PARCEL")
                          ElevatedButton.icon(
                            onPressed: () {
                              _selectBluetoothPrinter(context);
                            },
                            icon: const Icon(Icons.bluetooth),
                            label: const Text("KOT(BT)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              foregroundColor: whiteColor,
                            ),
                          ),
                        horizontalSpace(width: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) async {
                              await _ensureIminServiceReady();
                              await _printBillToIminOnly(context);
                            });
                          },
                          icon: const Icon(Icons.print),
                          label: const Text("Print Bill"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            foregroundColor: whiteColor,
                          ),
                        ),
                        horizontalSpace(width: 10),
                        SizedBox(
                          width: size.width * 0.09,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "CLOSE",
                              style: TextStyle(color: appPrimaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
  }
}
