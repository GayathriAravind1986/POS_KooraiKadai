import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:simple/ModelClass/Table/Get_table_model.dart' as table;
import 'package:simple/ModelClass/ShopDetails/getStockMaintanencesModel.dart'
    as stock;
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_stock_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_table_model.dart';

class HiveStockTableService {
  static const String _stockBox = 'stock_maintenance';
  static const String _tablesBox = 'tables';
  static const String _appStateBox = 'app_state';

  // Stock Maintenance Methods (unchanged)
  static Future<void> saveStockMaintenance(
      stock.GetStockMaintanencesModel stockModel) async {
    final box = Hive.box<HiveStockMaintenance>(_stockBox);
    final hiveStock = HiveStockMaintenance.fromApiModel(stockModel);
    await box.put('current_stock_info', hiveStock);
    print('Saved stock maintenance to Hive: ${hiveStock.stockMaintenance}');
  }

  static Future<HiveStockMaintenance?> getStockMaintenance() async {
    final box = Hive.box<HiveStockMaintenance>(_stockBox);
    return box.get('current_stock_info');
  }

  static Future<stock.GetStockMaintanencesModel?>
      getStockMaintenanceAsApiModel() async {
    final hiveStock = await getStockMaintenance();
    return hiveStock?.toApiModel();
  }

  static Future<void> updateStockMaintenanceStatus(bool status) async {
    final box = Hive.box<HiveStockMaintenance>(_stockBox);
    final existing = box.get('current_stock_info');
    if (existing != null) {
      existing.stockMaintenance = status;
      existing.lastUpdated = DateTime.now();
      await existing.save();
    }
  }

  // Updated Table Methods with proper type conversion
  static Future<void> saveTables(List<table.Data> tablesData) async {
    final box = Hive.box<HiveTable>(_tablesBox);
    await box.clear();

    for (final tableData in tablesData) {
      final hiveTable = HiveTable.fromApiModel(tableData);

      if (hiveTable.id!.isNotEmpty) {
        await box.put(hiveTable.id, hiveTable); // ✅ KEY = TABLE ID
      }
    }

    final appStateBox = Hive.box(_appStateBox);
    await appStateBox.put(
      'tables_last_updated',
      DateTime.now().toIso8601String(),
    );
    await appStateBox.put('tables_count', tablesData.length);

    debugPrint('✅ Saved ${tablesData.length} tables with ID as key');
  }


  static Future<List<HiveTable>> getTables() async {
    final box = Hive.box<HiveTable>(_tablesBox);
    return box.values.toList();
  }

  static Future<List<table.Data>> getTablesAsApiFormat() async {
    final hiveTables = await getTables();
    return hiveTables.map((hiveTable) => hiveTable.toApiModel()).toList();
  }

  static Future<List<Map<String, dynamic>>> getTablesAsMapFormat() async {
    final hiveTables = await getTables();
    return hiveTables.map((table) => table.toMap()).toList();
  }

  static Future<HiveTable?> getTableById(String tableId) async {
    final box = Hive.box<HiveTable>(_tablesBox);

    // 1️⃣ Try direct ID match
    final direct = box.get(tableId);
    if (direct != null) return direct;

    // 2️⃣ Try match by tableNo or name
    for (final table in box.values) {
      if (table.id.toString() == tableId ||
          table.name?.toString() == tableId) {
        return table;
      }
    }

    debugPrint("❌ TABLE NOT FOUND FOR: $tableId");
    return null;
  }


  static Future<void> updateTableStatus(String tableId, String status) async {
    final box = Hive.box<HiveTable>(_tablesBox);
    final tables = box.values.toList();

    for (int i = 0; i < tables.length; i++) {
      if (tables[i].id == tableId) {
        tables[i].status = status;
        tables[i].isAvailable = status == 'AVAILABLE';
        tables[i].lastUpdated = DateTime.now();
        await tables[i].save();
        break;
      }
    }
  }

  // Utility Methods (unchanged)
  static Future<DateTime?> getLastStockUpdateTime() async {
    final stock = await getStockMaintenance();
    return stock?.lastUpdated;
  }

  static Future<DateTime?> getLastTablesUpdateTime() async {
    final appStateBox = Hive.box(_appStateBox);
    final dateString = appStateBox.get('tables_last_updated');
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  static Future<bool> isStockDataStale() async {
    final lastUpdate = await getLastStockUpdateTime();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inHours > 24; // Consider stale after 24 hours
  }

  static Future<bool> isTablesDataStale() async {
    final lastUpdate = await getLastTablesUpdateTime();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inHours > 6; // Consider stale after 6 hours
  }

  // Clear methods (unchanged)
  static Future<void> clearStockData() async {
    final box = Hive.box<HiveStockMaintenance>(_stockBox);
    await box.clear();
  }

  static Future<void> clearTablesData() async {
    final box = Hive.box<HiveTable>(_tablesBox);
    await box.clear();
  }
}
