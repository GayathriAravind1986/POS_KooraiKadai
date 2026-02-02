import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/product_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart'
as product;

// Helper method to get all category IDs from categories box
Future<List<String>> _getAllCategoryIds() async {
  try {
    final categoriesBox = await Hive.openBox<HiveCategory>('categories');
    final allCategories = categoriesBox.values.toList();

    final categoryIds = allCategories
        .map((category) => category.id)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();

    debugPrint("📂 Found ${categoryIds.length} categories in categories box");
    return categoryIds;
  } catch (e) {
    debugPrint('❌ Error getting category IDs: $e');
    return ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  }
}

/// ✅ UPDATED: Uses HiveProduct.fromApi to ensure acPrice and parcelPrice are never zero
Future<void> saveProductsToHive(
    String categoryId,
    List<product.Rows> products,
    ) async {
  try {
    final box = await Hive.openBox<HiveProduct>('products_$categoryId');

    for (var item in products) {
      // 🚀 Use the factory! It handles double conversion and fallbacks to basePrice
      final hiveProduct = HiveProduct.fromApi(item);

      // Save or update by ID
      await box.put(hiveProduct.id, hiveProduct);

      debugPrint(
          '✅ Saved product ${hiveProduct.name} — AC: ${hiveProduct.acPrice} in category $categoryId');
    }

    debugPrint('✅ Saved ${products.length} products for category: $categoryId');

    // Also save to master products box
    await _saveToMasterBox(products);
  } catch (e, stack) {
    debugPrint('❌ Error saving products to Hive: $e');
    debugPrint(stack.toString());
  }
}

/// ✅ UPDATED: Uses HiveProduct.fromApi for the Master Box as well
Future<void> _saveToMasterBox(List<product.Rows> products) async {
  try {
    final masterBox = await Hive.openBox<HiveProduct>('master_products');

    for (var item in products) {
      final hiveProduct = HiveProduct.fromApi(item);
      await masterBox.put(hiveProduct.id, hiveProduct);
    }

    debugPrint('✅ Saved ${products.length} products to master box');
  } catch (e) {
    debugPrint('❌ Error saving to master box: $e');
  }
}

// CORRECTED: Load products from category boxes or master box
Future<List<HiveProduct>> loadProductsFromHive(
    String categoryId, {
      String searchKey = "",
      String searchCode = "",
    }) async {
  try {
    final boxName =
    categoryId.isEmpty ? 'master_products' : 'products_$categoryId';
    final box = await Hive.openBox<HiveProduct>(boxName);
    List<HiveProduct> products = box.values.toList();

    if (searchKey.isNotEmpty || searchCode.isNotEmpty) {
      products = products.where((product) {
        final name = product.name?.toLowerCase() ?? "";
        final code = product.shortCode?.toLowerCase() ?? "";
        final key = searchKey.toLowerCase();
        final codeKey = searchCode.toLowerCase();
        final matchesName = key.isEmpty ? false : name.contains(key);
        final matchesCode = codeKey.isEmpty ? false : code.contains(codeKey);

        return matchesName || matchesCode;
      }).toList();
    }

    return products;
  } catch (e) {
    debugPrint('❌ Error loading products from Hive: $e');
    return [];
  }
}

// UPDATED METHOD: Direct quantity update for a specific product
Future<bool> updateProductQuantityDirectly(
    String productId, int quantityToDeduct) async {
  try {
    debugPrint(
        "🔄 Direct quantity update for: $productId, deduct: $quantityToDeduct");

    bool updated = false;

    final masterBox = await Hive.openBox<HiveProduct>('master_products');
    final masterProduct = masterBox.get(productId);
    if (masterProduct != null) {
      final currentQty = masterProduct.availableQuantity ?? 0;
      masterProduct.availableQuantity =
      (currentQty - quantityToDeduct) > 0 ? (currentQty - quantityToDeduct) : 0;
      await masterBox.put(productId, masterProduct);
      updated = true;
    }

    final categoryIds = await _getAllCategoryIds();
    for (var categoryId in categoryIds) {
      final boxName = 'products_$categoryId';
      try {
        final categoryBox = await Hive.openBox<HiveProduct>(boxName);
        final categoryProduct = categoryBox.get(productId);
        if (categoryProduct != null) {
          final currentQty = categoryProduct.availableQuantity ?? 0;
          categoryProduct.availableQuantity = (currentQty - quantityToDeduct) > 0
              ? (currentQty - quantityToDeduct)
              : 0;
          await categoryBox.put(productId, categoryProduct);
          updated = true;
        }
      } catch (e) {
        continue;
      }
    }
    return updated;
  } catch (e) {
    debugPrint('❌ Error in direct quantity update: $e');
    return false;
  }
}

// UPDATED METHOD: Get current quantity of a product
Future<int?> getProductQuantity(String productId) async {
  try {
    final masterBox = await Hive.openBox<HiveProduct>('master_products');
    final masterProduct = masterBox.get(productId);
    if (masterProduct != null) {
      return masterProduct.availableQuantity;
    }

    final categoryIds = await _getAllCategoryIds();
    for (var categoryId in categoryIds) {
      try {
        final categoryBox =
        await Hive.openBox<HiveProduct>('products_$categoryId');
        final categoryProduct = categoryBox.get(productId);
        if (categoryProduct != null) {
          return categoryProduct.availableQuantity;
        }
      } catch (e) {
        continue;
      }
    }

    return null;
  } catch (e) {
    debugPrint('❌ Error getting product quantity: $e');
    return null;
  }
}

// NEW METHOD: Find which category a product belongs to
Future<String?> findProductCategory(String productId) async {
  try {
    final categoryIds = await _getAllCategoryIds();

    for (var categoryId in categoryIds) {
      final boxName = 'products_$categoryId';
      try {
        final categoryBox = await Hive.openBox<HiveProduct>(boxName);
        final categoryProduct = categoryBox.get(productId);
        if (categoryProduct != null) {
          return categoryId;
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  } catch (e) {
    debugPrint('❌ Error finding product category: $e');
    return null;
  }
}

// Method: Save products to master box (Wrapper for _saveToMasterBox)
Future<void> saveProductsToMasterBox(List<product.Rows> products) async {
  await _saveToMasterBox(products);
}

// Method: Get product by ID from master box
Future<HiveProduct?> getProductFromMasterBox(String productId) async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    return box.get(productId);
  } catch (e) {
    debugPrint('❌ Error getting product from master box: $e');
    return null;
  }
}

// Method: Update product quantity in master box
Future<void> updateProductQuantityInMasterBox(
    String productId, int newQuantity) async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    final product = box.get(productId);

    if (product != null) {
      product.availableQuantity = newQuantity > 0 ? newQuantity : 0;
      await box.put(productId, product);
    }
  } catch (e) {
    debugPrint('❌ Error updating product quantity in master box: $e');
  }
}

// Method: Decrease product quantity in master box
Future<void> decreaseProductQuantityInMasterBox(
    String productId, int quantityToDecrease) async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    final product = box.get(productId);

    if (product != null) {
      final currentQuantity = product.availableQuantity ?? 0;
      final newQuantity = currentQuantity - quantityToDecrease;
      product.availableQuantity = newQuantity > 0 ? newQuantity : 0;
      await box.put(productId, product);
    }
  } catch (e) {
    debugPrint('❌ Error decreasing product quantity in master box: $e');
  }
}

// Method: Get all products from master box
Future<List<HiveProduct>> getAllProductsFromMasterBox() async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    return box.values.toList();
  } catch (e) {
    debugPrint('❌ Error getting all products from master box: $e');
    return [];
  }
}

// Method: Search products in master box
Future<List<HiveProduct>> searchProductsInMasterBox(String searchQuery) async {
  try {
    final box = await Hive.openBox<HiveProduct>('master_products');
    final allProducts = box.values.toList();

    if (searchQuery.isEmpty) return allProducts;

    final query = searchQuery.toLowerCase();
    return allProducts.where((product) {
      final name = product.name?.toLowerCase() ?? "";
      final code = product.shortCode?.toLowerCase() ?? "";
      return name.contains(query) || code.contains(query);
    }).toList();
  } catch (e) {
    debugPrint('❌ Error searching products in master box: $e');
    return [];
  }
}