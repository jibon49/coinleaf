import 'package:dartz/dartz.dart';
import '../entities/market_price.dart';
import '../repositories/market_price_repository.dart';
import '../../core/error/failures.dart';

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
  final MarketPriceRepository repository;

  SyncMarketPrices(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.syncMarketPrices();
  }
}
