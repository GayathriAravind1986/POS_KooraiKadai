import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:simple/ModelClass/Catering/putCateringBookingModel.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/image.dart';
import 'package:simple/UI/Order/Helper/time_formatter.dart';

Widget getPutCateringReceiptWidget({
  required String businessName,
  required String address,
  required String gst,
  required String phone,
  required PutCateringBookingModel booking,
}) {
  final bool isFullyPaid = booking.data!.paymenttype == "FULLY";

  return Container(
    width: 384,
    color: whiteColor,
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              Images.logoWithName,
              width: 120, // circle size
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// HEADER
        Center(
          child: Column(
            children: [
              Text(
                businessName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(address,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center),
              if (gst.isNotEmpty)
                Text("GST: $gst", style: const TextStyle(fontSize: 18)),
              Text(
                "Phone: $phone",
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),

        _divider(),

        /// BOOKING DETAILS

        _labelRow("Date", formatDate(booking.data!.date.toString())),
        _labelRow("Location", booking.data!.locationName ?? ''),
        _labelRow("Customer Name", booking.data!.customerName ?? ''),
        _labelRow("Package Name", booking.data!.packageName ?? ''),

        _divider(),

        /// AMOUNTS
        _totalRow("Package", booking.data!.packageamount ?? 0),
        _totalRow("Qty", booking.data!.quantity ?? 0),
        _totalRow("Addons", booking.data!.addonsamount ?? 0),
        _totalRow("Discount", booking.data!.discountamount ?? 0),
        _divider(),
        _totalRow("TOTAL", booking.data!.totalamount ?? 0, isBold: true),

        _divider(),

        /// PAYMENT SECTION

        const SizedBox(height: 4),

        if (isFullyPaid) ...[
          _labelRow("Payment Type", "FULLY"),
          _labelRow("Mode", booking.data!.paymentmode ?? "-"),
          _labelRow("Paid Amount", "₹${booking.data!.paidamount}"),
        ] else ...[
          _labelRow("Payment Type", "PARTIALLY"),
          ...(booking.data!.paymentdetails ?? []).map((p) {
            return _labelRow(
              p.mode ?? '',
              "₹${p.amount}  ${formatDate(p.date.toString())}",
            );
          }).toList(),
        ],

        _labelRow("Balance", "₹${booking.data!.balanceamount}"),

        _divider(),
        // const SizedBox(height: 8),
        // const Center(
        //   child: Text(
        //     "Powered By",
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       fontSize: 14, // Keep smaller for footer
        //       color: blackColor,
        //     ),
        //   ),
        // ),
        // const Center(
        //   child: Text(
        //     "www.sentinixtechsolutions.com",
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       fontSize: 14,
        //       color: blackColor,
        //     ),
        //   ),
        // ),
        const Center(
          child: Text(
            "Thank You, Visit Again!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 30),
      ],
    ),
  );
}

Widget _divider() {
  return Container(
    height: 2,
    color: blackColor,
    margin: const EdgeInsets.symmetric(vertical: 6),
  );
}

Widget _labelRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 20, color: blackColor, fontWeight: FontWeight.bold)),
        Text(value,
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
      ],
    ),
  );
}

Widget _totalRow(String label, num? amount, {bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style: TextStyle(
              fontSize: 20, fontWeight: isBold ? FontWeight.bold : null)),
      Text(
        "₹${amount ?? 0}",
        style: TextStyle(
            fontSize: 20, fontWeight: isBold ? FontWeight.bold : null),
      ),
    ],
  );
}

Future<Uint8List?> captureMonochromePutCateringReceipt(GlobalKey key) async {
  try {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Capture the widget as an image
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (byteData == null) return null;

    Uint8List pixels = byteData.buffer.asUint8List();
    int width = image.width;
    int height = image.height;

    // Convert to monochrome (black and white only)
    List<int> monochromePixels = [];

    for (int i = 0; i < pixels.length; i += 4) {
      int r = pixels[i];
      int g = pixels[i + 1];
      int b = pixels[i + 2];
      int a = pixels[i + 3];

      // Calculate luminance
      double luminance = (0.299 * r + 0.587 * g + 0.114 * b);

      // Convert to black or white based on threshold
      int value = luminance > 128 ? 255 : 0;

      monochromePixels.addAll([value, value, value, a]);
    }

    // Create new image from monochrome pixels
    ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
        Uint8List.fromList(monochromePixels));

    ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );

    ui.Codec codec = await descriptor.instantiateCodec();
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image monochromeImage = frameInfo.image;

    ByteData? finalByteData =
        await monochromeImage.toByteData(format: ui.ImageByteFormat.png);

    return finalByteData?.buffer.asUint8List();
  } catch (e) {
    debugPrint("Error creating monochrome image: $e");
    return null;
  }
}
