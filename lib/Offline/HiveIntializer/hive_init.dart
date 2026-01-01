import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive() async {
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }
}
