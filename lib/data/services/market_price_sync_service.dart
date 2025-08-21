import 'package:dartz/dartz.dart';
import '../datasources/market_price_local_data_source.dart';
import '../datasources/market_price_remote_data_source.dart';
import '../models/market_price_model.dart';
import '../../core/error/failures.dart';

class MarketPriceSyncService {
  final MarketPriceLocalDataSource localDataSource;
  final MarketPriceRemoteDataSource remoteDataSource;

  MarketPriceSyncService({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// Sync prices from all sources with pagination support
  Future<Either<Failure, SyncResult>> syncAllPrices({int maxPages = 3}) async {
    try {
      print('🔄 Starting market price sync with pagination...');

      // Check internet connection
      final hasConnection = await remoteDataSource.testConnection();
      if (!hasConnection) {
        return Left(NetworkFailure('No internet connection'));
      }

      // Get existing prices for comparison
      final existingPrices = await localDataSource.getAllMarketPrices();
      final existingPricesMap = <String, MarketPriceModel>{};
      for (final price in existingPrices) {
        existingPricesMap[_generateItemKey(price.itemName)] = price;
      }

      // Fetch new prices from remote sources with pagination
      final List<MarketPriceModel> allNewPrices = [];
      int totalFetched = 0;

      // Fetch multiple pages from Shwapno API
      for (int page = 1; page <= maxPages; page++) {
        try {
          final pagePrices = await remoteDataSource.fetchShwapnoPrices(
            page: page,
            limit: 20
          );

          if (pagePrices.isEmpty) {
            print('📄 No more products on page $page, stopping pagination');
            break;
          }

          allNewPrices.addAll(pagePrices);
          totalFetched += pagePrices.length;

          print('📄 Page $page: Fetched ${pagePrices.length} products');

          // Add delay between requests to be respectful
          await Future.delayed(const Duration(milliseconds: 500));

        } catch (e) {
          print('⚠️ Failed to fetch page $page: $e');
          break;
        }
      }

      if (allNewPrices.isEmpty) {
        return Left(NetworkFailure('No prices fetched from remote sources'));
      }

      // Process and compare prices
      final List<MarketPriceModel> updatedPrices = [];
      int newItems = 0;
      int updatedItems = 0;
      int unchangedItems = 0;

      for (final newPrice in allNewPrices) {
        final itemKey = _generateItemKey(newPrice.itemName);
        final existingPrice = existingPricesMap[itemKey];

        if (existingPrice == null) {
          // New item
          updatedPrices.add(newPrice);
          newItems++;
        } else {
          // Existing item - calculate price change
          final priceChange = newPrice.price - existingPrice.price;

          if (priceChange.abs() > 0.01) { // Only update if price changed significantly
            final updatedPrice = MarketPriceModel(
              id: existingPrice.id, // Keep existing ID
              itemName: newPrice.itemName,
              price: newPrice.price,
              unit: newPrice.unit,
              location: newPrice.location,
              lastUpdated: DateTime.now(),
              source: newPrice.source,
              previousPrice: existingPrice.price,
              priceChange: priceChange,
            );
            updatedPrices.add(updatedPrice);
            updatedItems++;
          } else {
            unchangedItems++;
          }
        }
      }

      // Update local database
      if (updatedPrices.isNotEmpty) {
        await localDataSource.insertMarketPrices(updatedPrices);
      }

      // Update last sync time
      await localDataSource.setLastSyncTime(DateTime.now());

      final result = SyncResult(
        totalFetched: totalFetched,
        newItems: newItems,
        updatedItems: updatedItems,
        unchangedItems: unchangedItems,
        syncTime: DateTime.now(),
        pagesProcessed: maxPages,
      );

      print('✅ Sync completed: ${result.summary}');
      return Right(result);

    } catch (e) {
      print('❌ Sync failed: $e');
      return Left(UnknownFailure('Sync failed: $e'));
    }
  }

  /// Sync specific page of prices
  Future<Either<Failure, SyncResult>> syncSpecificPage(int page, {int limit = 20}) async {
    try {
      print('🔄 Syncing page $page...');

      final hasConnection = await remoteDataSource.testConnection();
      if (!hasConnection) {
        return Left(NetworkFailure('No internet connection'));
      }

      final newPrices = await remoteDataSource.fetchShwapnoPrices(
        page: page,
        limit: limit
      );

      if (newPrices.isNotEmpty) {
        await localDataSource.insertMarketPrices(newPrices);
        await localDataSource.setLastSyncTime(DateTime.now());
      }

      final result = SyncResult(
        totalFetched: newPrices.length,
        newItems: newPrices.length,
        updatedItems: 0,
        unchangedItems: 0,
        syncTime: DateTime.now(),
        pagesProcessed: 1,
      );

      return Right(result);
    } catch (e) {
      return Left(UnknownFailure('Page sync failed: $e'));
    }
  }

  /// Sync prices for specific categories
  Future<Either<Failure, SyncResult>> syncSpecificCategories(List<String> categories) async {
    try {
      // This could be extended to sync only specific categories
      // For now, we'll sync all and filter later
      return await syncAllPrices();
    } catch (e) {
      return Left(UnknownFailure('Category sync failed: $e'));
    }
  }

  /// Check if sync is needed (based on last sync time)
  Future<bool> isSyncNeeded({Duration threshold = const Duration(hours: 6)}) async {
    try {
      final lastSync = await localDataSource.getLastSyncTime();
      if (lastSync == null) return true;

      final timeDifference = DateTime.now().difference(lastSync);
      return timeDifference > threshold;
    } catch (e) {
      return true; // If we can't determine, assume sync is needed
    }
  }

  /// Get sync status and statistics
  Future<SyncStatus> getSyncStatus() async {
    try {
      final lastSync = await localDataSource.getLastSyncTime();
      final totalPrices = await localDataSource.getAllMarketPrices();
      final hasConnection = await remoteDataSource.testConnection();

      return SyncStatus(
        lastSyncTime: lastSync,
        totalItems: totalPrices.length,
        hasInternetConnection: hasConnection,
        needsSync: await isSyncNeeded(),
      );
    } catch (e) {
      return SyncStatus(
        lastSyncTime: null,
        totalItems: 0,
        hasInternetConnection: false,
        needsSync: true,
      );
    }
  }

  String _generateItemKey(String itemName) {
    // Normalize item name for comparison
    return itemName.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ')    // Normalize spaces
        .trim();
  }
}

class SyncResult {
  final int totalFetched;
  final int newItems;
  final int updatedItems;
  final int unchangedItems;
  final DateTime syncTime;
  final int pagesProcessed;

  SyncResult({
    required this.totalFetched,
    required this.newItems,
    required this.updatedItems,
    required this.unchangedItems,
    required this.syncTime,
    this.pagesProcessed = 0,
  });

  String get summary => 'Fetched: $totalFetched, New: $newItems, Updated: $updatedItems, Unchanged: $unchangedItems';
}

class SyncStatus {
  final DateTime? lastSyncTime;
  final int totalItems;
  final bool hasInternetConnection;
  final bool needsSync;

  SyncStatus({
    required this.lastSyncTime,
    required this.totalItems,
    required this.hasInternetConnection,
    required this.needsSync,
  });

  String get lastSyncText {
    if (lastSyncTime == null) return 'Never synced';

    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} minutes ago';
    if (difference.inDays < 1) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }
}
