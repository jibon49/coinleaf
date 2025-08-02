import 'package:dartz/dartz.dart';
import '../entities/market_price.dart';
import '../../core/error/failures.dart';

abstract class MarketPriceRepository {
  Future<Either<Failure, List<MarketPrice>>> getAllMarketPrices();
  Future<Either<Failure, List<MarketPrice>>> getMarketPricesByCategory(String category);
  Future<Either<Failure, MarketPrice>> getMarketPriceById(String id);
  Future<Either<Failure, MarketPrice>> getMarketPriceByItem(String itemName);
  Future<Either<Failure, void>> updateMarketPrice(MarketPrice marketPrice);
  Future<Either<Failure, void>> syncMarketPrices();
  Future<Either<Failure, DateTime>> getLastSyncTime();
}
