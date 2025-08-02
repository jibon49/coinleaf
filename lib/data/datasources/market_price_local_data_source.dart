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

      await batch.commit();
    } catch (e) {
      throw DatabaseFailure('Failed to insert market prices: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT MAX(last_updated) as last_sync FROM market_prices',
      );

      final lastSyncString = result.first['last_sync'] as String?;
      return lastSyncString != null ? DateTime.parse(lastSyncString) : null;
    } catch (e) {
      throw DatabaseFailure('Failed to get last sync time: $e');
    }
  }

  @override
  Future<void> setLastSyncTime(DateTime syncTime) async {
    try {
      final db = await databaseHelper.database;
      await db.rawUpdate(
        'UPDATE market_prices SET last_updated = ?',
        [syncTime.toIso8601String()],
      );
    } catch (e) {
      throw DatabaseFailure('Failed to set last sync time: $e');
    }
  }
}
