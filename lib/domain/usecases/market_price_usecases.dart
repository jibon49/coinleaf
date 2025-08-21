import 'package:dartz/dartz.dart';
import '../entities/market_price.dart';
import '../repositories/market_price_repository.dart';
import '../../core/error/failures.dart';
import '../../data/services/market_price_sync_service.dart';

class GetAllMarketPrices {
  final MarketPriceRepository repository;

  GetAllMarketPrices(this.repository);

  Future<Either<Failure, List<MarketPrice>>> call() async {
    return await repository.getAllMarketPrices();
  }
}

class GetMarketPricesByCategory {
  final MarketPriceRepository repository;

  GetMarketPricesByCategory(this.repository);

  Future<Either<Failure, List<MarketPrice>>> call(String category) async {
    return await repository.getMarketPricesByCategory(category);
  }
}

class GetMarketPriceByItem {
  final MarketPriceRepository repository;

  GetMarketPriceByItem(this.repository);

  Future<Either<Failure, MarketPrice>> call(String itemName) async {
    return await repository.getMarketPriceByItem(itemName);
  }
}

class SyncMarketPrices {
  final MarketPriceSyncService syncService;

  SyncMarketPrices(this.syncService);

  Future<Either<Failure, SyncResult>> call() async {
    return await syncService.syncAllPrices();
  }
}

class SyncMarketPricesPage {
  final MarketPriceSyncService syncService;

  SyncMarketPricesPage(this.syncService);

  Future<Either<Failure, SyncResult>> call(int page) async {
    return await syncService.syncSpecificPage(page);
  }
}
