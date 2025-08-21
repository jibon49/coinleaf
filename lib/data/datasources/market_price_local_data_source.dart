import 'package:sqflite/sqflite.dart';
import '../models/market_price_model.dart';
import 'database_helper.dart';
import '../../core/error/failures.dart';

abstract class MarketPriceLocalDataSource {
  Future<List<MarketPriceModel>> getAllMarketPrices();
  Future<List<MarketPriceModel>> getMarketPricesByCategory(String category);
  Future<MarketPriceModel> getMarketPriceById(String id);
  Future<MarketPriceModel> getMarketPriceByItem(String itemName);
  Future<void> updateMarketPrice(MarketPriceModel marketPrice);
  Future<void> insertMarketPrices(List<MarketPriceModel> prices);
  Future<DateTime?> getLastSyncTime();
  Future<void> setLastSyncTime(DateTime syncTime);
}

class MarketPriceLocalDataSourceImpl implements MarketPriceLocalDataSource {
  final DatabaseHelper databaseHelper;

  MarketPriceLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<MarketPriceModel>> getAllMarketPrices() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'market_prices',
        orderBy: 'item_name ASC',
      );
      return maps.map((map) => MarketPriceModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get all market prices: $e');
    }
  }

  @override
  Future<List<MarketPriceModel>> getMarketPricesByCategory(String category) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'market_prices',
        where: 'item_name LIKE ?',
        whereArgs: ['%$category%'],
        orderBy: 'item_name ASC',
      );
      return maps.map((map) => MarketPriceModel.fromJson(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get market prices by category: $e');
    }
  }

  @override
  Future<MarketPriceModel> getMarketPriceById(String id) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'market_prices',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        throw DatabaseFailure('Market price not found');
      }

      return MarketPriceModel.fromJson(maps.first);
    } catch (e) {
      throw DatabaseFailure('Failed to get market price by id: $e');
    }
  }

  @override
  Future<MarketPriceModel> getMarketPriceByItem(String itemName) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'market_prices',
        where: 'item_name = ?',
        whereArgs: [itemName],
      );

      if (maps.isEmpty) {
        throw DatabaseFailure('Market price not found for item: $itemName');
      }

      return MarketPriceModel.fromJson(maps.first);
    } catch (e) {
      throw DatabaseFailure('Failed to get market price by item: $e');
    }
  }

  @override
  Future<void> updateMarketPrice(MarketPriceModel marketPrice) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'market_prices',
        marketPrice.toJson(),
        where: 'id = ?',
        whereArgs: [marketPrice.id],
      );
    } catch (e) {
      throw DatabaseFailure('Failed to update market price: $e');
    }
  }

  @override
  Future<void> insertMarketPrices(List<MarketPriceModel> prices) async {
    try {
      final db = await databaseHelper.database;
      final batch = db.batch();

      for (final price in prices) {
        batch.insert(
          'market_prices',
          price.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw DatabaseFailure('Failed to insert market prices: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final db = await databaseHelper.database;
      final result = await db.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: ['last_market_sync'],
      );

      if (result.isEmpty) return null;

      final timeString = result.first['value'] as String;
      return DateTime.parse(timeString);
    } catch (e) {
      // If settings table doesn't exist, return null
      return null;
    }
  }

  @override
  Future<void> setLastSyncTime(DateTime syncTime) async {
    try {
      final db = await databaseHelper.database;

      // Create settings table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.insert(
        'app_settings',
        {
          'key': 'last_market_sync',
          'value': syncTime.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseFailure('Failed to set last sync time: $e');
    }
  }
}
